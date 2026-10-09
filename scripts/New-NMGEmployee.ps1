$employees = Import-Csv "C:\NMG-IAM\data\employees.csv"
foreach ($employee in $employees) {
$fullName = "$($employee.FirstName) $($employee.LastName)"
$samAccountName = ($employee.FirstName.Substring(0,1) + $employee.LastName).ToLower()
$email = "$samAccountName@NMG.com"
$userPrincipalName = $email
$ou = Get-ADOrganizationalUnit -Filter "Name -eq '$($employee.Department)'"
if (-not $ou) {
    Write-Host "ERROR: OU $($employee.Department) does not exist. Skipping $fullName."
    continue
}
$ouPath = $ou.DistinguishedName
$group = Get-ADGroup -Filter "Name -eq '$($employee.Department)-Users'" -ErrorAction SilentlyContinue
if (-not $group) {
    Write-Host "ERROR: Group $($employee.Department)-Users does not exist. Skipping $fullName."
    continue
}
$tempPassword = Read-Host "Enter temporary password" -AsSecureString
$existingUser = Get-ADUser -Filter "SamAccountName -eq '$samAccountName'"
if ($existingUser) {
    Write-Host "User $samAccountName already exists. No account was created."
    continue
}
New-ADUser `
    -Name $fullName `
    -GivenName $employee.FirstName `
    -Surname $employee.LastName `
    -SamAccountName $samAccountName `
    -UserPrincipalName $userPrincipalName `
    -EmailAddress $email `
    -Department $employee.Department `
    -Title $employee.Title `
    -Path $ouPath `
    -AccountPassword $tempPassword `
    -Enabled $true

try {
    Add-ADGroupMember -Identity $group -Members $samAccountName -ErrorAction Stop
}
catch {
    Write-Host "ERROR: Failed to add $samAccountName to $($employee.Department)-Users."
    continue
}
$membership = Get-ADGroupMember -Identity $group |
    Where-Object { $_.SamAccountName -eq $samAccountName }

if (-not $membership) {
    Write-Host "ERROR: $samAccountName was not found in the $($employee.Department)-Users group."
    continue
}
Write-Host "SUCCESS: $fullName has been provisioned in the $($employee.Department) department."
}