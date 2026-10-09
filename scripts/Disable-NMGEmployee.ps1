$leavers = Import-Csv "C:\NMG-IAM\data\leavers.csv"
$disabledOU = Get-ADOrganizationalUnit -Filter "Name -eq 'Disabled Users'"
$logFile = "C:\NMG-IAM\logs\leaver.log"

Add-Content -Path $logFile -Value "===== LEAVER PROCESS STARTED: $(Get-Date) ====="

foreach ($leaver in $leavers) {

    $user = Get-ADUser -Identity $leaver.SamAccountName `
        -Properties Department,Title,DistinguishedName

    Add-Content -Path $logFile `
        -Value "$(Get-Date) - Processing LEAVER: $($user.SamAccountName) - Reason: $($leaver.Reason)"

    if (-not $user.Department) {
        Write-Host "ERROR: $($user.SamAccountName) has no department. Skipping."
        Add-Content -Path $logFile `
            -Value "$(Get-Date) - ERROR: $($user.SamAccountName) has no department. Skipping."
        continue
    }

    $departmentGroup = "$($user.Department)-Users"

    $departmentGroupObject = Get-ADGroup `
        -Filter "Name -eq '$departmentGroup'" `
        -ErrorAction SilentlyContinue

    if (-not $departmentGroupObject) {
        Write-Host "ERROR: Department group $departmentGroup does not exist. Skipping $($user.SamAccountName)."
        Add-Content -Path $logFile `
            -Value "$(Get-Date) - ERROR: Department group $departmentGroup does not exist. Skipping $($user.SamAccountName)."
        continue
    }

    try {

        Disable-ADAccount -Identity $user -ErrorAction Stop

        $groupMembership = Get-ADGroupMember -Identity $departmentGroupObject |
            Where-Object { $_.SamAccountName -eq $user.SamAccountName }

        if ($groupMembership) {
            Remove-ADGroupMember `
                -Identity $departmentGroupObject `
                -Members $user `
                -Confirm:$false `
                -ErrorAction Stop

            Write-Host "Removed $($user.SamAccountName) from $($departmentGroupObject.Name)."
            Add-Content -Path $logFile `
                -Value "$(Get-Date) - Removed $($user.SamAccountName) from $($departmentGroupObject.Name)."
        }

        Move-ADObject `
            -Identity $user.DistinguishedName `
            -TargetPath $disabledOU.DistinguishedName `
            -ErrorAction Stop

        $finalUser = Get-ADUser `
            -Identity $user.SamAccountName `
            -Properties Enabled,DistinguishedName

        if (
            $finalUser.Enabled -eq $false -and
            $finalUser.DistinguishedName -eq $disabledOU.DistinguishedName.Replace("OU=Disabled Users", "CN=$($finalUser.Name),OU=Disabled Users")
        ) {
            Write-Host "SUCCESS: $($user.SamAccountName) has been offboarded and moved to Disabled Users."
            Add-Content -Path $logFile `
                -Value "$(Get-Date) - SUCCESS: $($user.SamAccountName) offboarded and moved to Disabled Users."
        }
        else {
            throw "Final verification failed for $($user.SamAccountName)."
        }

    }
    catch {
        Write-Host "ERROR: LEAVER failed for $($user.SamAccountName): $($_.Exception.Message)"
        Add-Content -Path $logFile `
            -Value "$(Get-Date) - ERROR: LEAVER failed for $($user.SamAccountName): $($_.Exception.Message)"
        continue
    }
}

Add-Content -Path $logFile -Value "===== LEAVER PROCESS COMPLETED: $(Get-Date) ====="