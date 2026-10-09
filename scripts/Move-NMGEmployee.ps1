$logFile = "C:\NMG-IAM\logs\mover.log"
Add-Content -Path $logFile -Value "===== MOVER PROCESS STARTED: $(Get-Date) ====="

$movers = Import-Csv "C:\NMG-IAM\data\movers.csv"

foreach ($mover in $movers) {

    Write-Host "Processing MOVER: $($mover.SamAccountName)"

    Add-Content -Path $logFile -Value "$(Get-Date) - Processing MOVER: $($mover.SamAccountName) - Target Department: $($mover.NewDepartment) - Target Title: $($mover.NewTitle)"

    $user = Get-ADUser -Identity $mover.SamAccountName -Properties Department,Title,DistinguishedName

    $newDepartment = $mover.NewDepartment
    $newTitle = $mover.NewTitle

    $targetOU = Get-ADOrganizationalUnit -Filter "Name -eq '$newDepartment'"
    $targetGroup = Get-ADGroup -Filter "Name -eq '$newDepartment-Users'"

    if (-not $targetOU) {
        Write-Host "ERROR: Target OU for $newDepartment does not exist. Skipping $($mover.SamAccountName)."
        Add-Content -Path $logFile -Value "$(Get-Date) - ERROR: Target OU for $newDepartment does not exist. Skipping $($mover.SamAccountName)."
        continue
    }

    if (-not $targetGroup) {
        Write-Host "ERROR: Target group $newDepartment-Users does not exist. Skipping $($mover.SamAccountName)."
        Add-Content -Path $logFile -Value "$(Get-Date) - ERROR: Target group $newDepartment-Users does not exist. Skipping $($mover.SamAccountName)."
        continue
    }

    Write-Host "Target Group: $($targetGroup.Name)"
    Write-Host "Target OU: $($targetOU.DistinguishedName)"

    Write-Host "Current Department: $($user.Department) | Current Title: $($user.Title)"

    $oldDepartmentGroup = "$($user.Department)-Users"
    $oldDepartmentGroupObject = Get-ADGroup -Filter "Name -eq '$oldDepartmentGroup'" -ErrorAction SilentlyContinue

    Write-Host "Old Group: $oldDepartmentGroup"
    if (-not $oldDepartmentGroupObject) {
    Write-Host "ERROR: Current department group $oldDepartmentGroup does not exist. Skipping $($mover.SamAccountName)."
    Add-Content -Path $logFile -Value "$(Get-Date) - ERROR: Current department group $oldDepartmentGroup does not exist. Skipping $($mover.SamAccountName)."
    continue
}

    if ($user.Department -eq $newDepartment) {

        Write-Host "No department change required for $($user.SamAccountName)."

        try {
            Set-ADUser -Identity $user `
                -Title $newTitle `
                -ErrorAction Stop

            Write-Host "Updated Title: $newTitle"

            Add-Content -Path $logFile -Value "$(Get-Date) - No department change. Title verified/updated for $($mover.SamAccountName): $newTitle"
        }
        catch {
            Write-Host "ERROR: Failed to update $($mover.SamAccountName): $($_.Exception.Message)"
            Add-Content -Path $logFile -Value "$(Get-Date) - ERROR: Failed to update $($mover.SamAccountName): $($_.Exception.Message)"
            continue
        }
    }
    else {

        try {
            Remove-ADGroupMember -Identity $oldDepartmentGroupObject -Members $user -Confirm:$false -ErrorAction Stop

            Add-ADGroupMember -Identity $targetGroup -Members $user -ErrorAction Stop

            Write-Host "Group membership updated: $oldDepartmentGroup -> $($targetGroup.Name)"

            Add-Content -Path $logFile -Value "$(Get-Date) - Group membership updated: $oldDepartmentGroup -> $($targetGroup.Name)"

            Set-ADUser -Identity $user `
                -Department $newDepartment `
                -Title $newTitle `
                -ErrorAction Stop

            Write-Host "Updated Department: $newDepartment | Updated Title: $newTitle"

            Add-Content -Path $logFile -Value "$(Get-Date) - Attributes updated for $($mover.SamAccountName): Department=$newDepartment, Title=$newTitle"

            Move-ADObject -Identity $user.DistinguishedName `
                -TargetPath $targetOU.DistinguishedName `
                -ErrorAction Stop

            Write-Host "Moved $($mover.SamAccountName) to $($targetOU.DistinguishedName)"

            Add-Content -Path $logFile -Value "$(Get-Date) - SUCCESS: $($mover.SamAccountName) moved to $($targetOU.DistinguishedName)"
        }
        catch {
            Write-Host "ERROR: MOVER failed for $($mover.SamAccountName): $($_.Exception.Message)"

            Add-Content -Path $logFile -Value "$(Get-Date) - ERROR: MOVER failed for $($mover.SamAccountName): $($_.Exception.Message)"

            continue
        }
    }
}

Add-Content -Path $logFile -Value "===== MOVER PROCESS COMPLETED: $(Get-Date) ====="