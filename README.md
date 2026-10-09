# PowerShell AD User Lifecycle Management

## Project Overview

This project demonstrates PowerShell-based automation for managing the employee lifecycle in a Windows Server Active Directory environment.

The project simulates common IAM and IT operations for a fictional organization, Northstar Medical Group (NMG):

- **JOINER** — Provision a new employee
- **MOVER** — Update an employee when their department or job changes
- **LEAVER** — Disable and isolate an employee during offboarding

The goal is to demonstrate practical Active Directory administration, role-based access control (RBAC), PowerShell automation, validation, error handling, and audit logging.

> **Lab project:** This repository was developed in a controlled Windows Server Active Directory lab using fictional employee data. It is not intended to represent a production implementation.

## Objectives

The project was designed to demonstrate the ability to:

- Automate Active Directory user provisioning
- Place users in the correct organizational unit (OU)
- Assign department-based security groups
- Update users during department transfers
- Remove obsolete department access
- Disable accounts during offboarding
- Move disabled accounts to a dedicated Disabled Users OU
- Prevent duplicate account creation
- Validate target OUs and security groups
- Handle errors without stopping the entire batch
- Maintain basic audit logs
- Verify the final state after lifecycle operations

## Environment

| Component | Configuration |
|---|---|
| Operating System | Windows Server 2022 |
| Directory Service | Active Directory Domain Services |
| Domain | NMG.com |
| Lab Organization | Northstar Medical Group |
| Virtualization | VirtualBox |
| Automation | PowerShell |
| Version Control | Git / GitHub |

### Active Directory Structure

Organizational Units:

- HR
- Operations
- Finance
- IT
- Sales
- Disabled Users

Department security groups:

- HR-Users
- Operations-Users
- Finance-Users
- IT-Users
- Sales-Users

## Repository Structure

```text
PowerShell-AD-User-Lifecycle-Management/
│
├── data/
│   ├── employees.csv
│   ├── movers.csv
│   └── leavers.csv
│
├── logs/
│   └── Local execution logs are excluded from Git
│
├── scripts/
│   ├── New-NMGEmployee.ps1
│   ├── Move-NMGEmployee.ps1
│   └── Disable-NMGEmployee.ps1
│
├── .gitignore
└── README.md

## JOINER — Employee Onboarding

### Script

```text
scripts/New-NMGEmployee.ps1

### Security Consideration

The script does not contain a hard-coded password.

Instead, the administrator is prompted to enter the temporary password securely:

```powershell
$tempPassword = Read-Host "Enter temporary password" -AsSecureString

---

## MOVER — Department and Job Changes

### Script

`scripts/Move-NMGEmployee.ps1`

The MOVER process reads employee changes from `movers.csv`.

It supports:

- Department transfers
- Job title changes
- Department security group changes
- Organizational unit (OU) movement
- Validation of target OUs and security groups
- Error handling and audit logging

### Example: Finance to IT

When an employee transfers from Finance to IT, the script:

1. Validates the target IT OU and IT-Users group.
2. Removes the employee from Finance-Users.
3. Adds the employee to IT-Users.
4. Updates the employee's department and job title.

5. Moves the employee to the IT OU.
6. Records the outcome in the local log.

The script also handles same-department title changes without unnecessarily changing group membership or OU placement.

---

## LEAVER — Employee Offboarding

### Script

`scripts/Disable-NMGEmployee.ps1`

The LEAVER process reads employee information from `leavers.csv`.

The process:

1. Identifies the employee in Active Directory.
2. Determines the employee's current department.
3. Resolves the corresponding department security group.
4. Disables the employee's account.
5. Removes the employee from the department security group.
6. Moves the account to the Disabled Users OU.
7. Verifies the final account state.
8. Records the outcome in the local audit log.

### Expected Offboarding State

```text
Active Employee
      ↓
Account Disabled
      ↓
Department Access Removed
      ↓
Moved to Disabled Users OU
      ↓
Final State Verified

---

## Validation and Testing

The lifecycle scripts were tested using fictional employees in the NMG Active Directory lab.

### JOINER Tests

- Successful account creation
- Correct OU placement and department attributes
- Correct email address and department group membership
- Duplicate account protection

Example duplicate test result:

```text
User ejohnson already exists. No account was created.


---

## Error Handling and Audit Logging

The scripts validate required Active Directory objects and handle common operational errors, including:

- Duplicate user accounts
- Missing target organizational units
- Missing department security groups
- Missing current department groups
- Failed group membership changes
- Failed Active Directory updates or OU moves
- Failed final verification

The MOVER and LEAVER scripts write execution details and outcomes to local log files:

- `logs/mover.log`
- `logs/leaver.log`

These logs help an administrator review operations and troubleshoot failures. The `logs/` directory is excluded from Git so that local execution logs are not published with the source code.

Error handling is designed to allow batch processing to continue when an individual record encounters a handled error. It does not guarantee rollback if a multi-step operation partially succeeds.

---

## IAM Concepts Demonstrated

### Identity Lifecycle Management

The project models three key stages of the employee identity lifecycle:

`JOINER → MOVER → LEAVER`

### Role-Based Access Control (RBAC)

Department security groups represent role-based access assignments:

- HR → `HR-Users`
- Finance → `Finance-Users`
- IT → `IT-Users`
- Operations → `Operations-Users`
- Sales → `Sales-Users`

### Least Privilege

During a department transfer, the script removes the employee from the previous department group before assigning the new department group.

### Account Isolation

During offboarding, the account is disabled, department-specific access is removed, and the account is moved to a dedicated Disabled Users OU.

### Automation and Verification

PowerShell automates repeatable administrative tasks, while validation and post-operation checks help confirm that the intended Active Directory changes occurred.

---

## Lessons Learned

### 1. Validate Before Making Changes

Automation should verify that required OUs and security groups exist before attempting directory operations.

### 2. Keep Access Aligned with Job Responsibilities

When an employee changes departments, obsolete department group membership should be removed to reduce unnecessary access.

### 3. Offboarding Requires Multiple Controls

Disabling an account is only one part of offboarding. Removing department-specific access, isolating the account, and verifying the final state are also important.

### 4. Prevent Duplicate Provisioning

Checking for an existing account before creating a new one helps avoid duplicate identities.

### 5. Verify the Outcome

A command completing without an obvious error does not necessarily prove that the desired directory state was achieved. Post-operation verification helps catch problems.

### 6. Protect Credentials

Passwords should not be hard-coded into scripts or committed to source control. This project uses a secure password prompt rather than storing the lab password in the source code.

### 7. Plan for Partial Failures

Multi-step operations can partially succeed. Production automation should include appropriate recovery or rollback procedures, monitoring, and escalation paths.

---

## Future Improvements

Potential enhancements for a more production-oriented implementation include:

- Centralized configuration management
- Structured logging and standardized audit reports
- Rollback or recovery handling for partially completed operations
- Integration with a ticketing system and approval workflows
- Microsoft Entra ID and Microsoft 365 provisioning
- Secrets management through an approved enterprise solution
- Least-privilege service accounts and delegated permissions
- Automated testing and PowerShell code quality checks
- Monitoring and alerting for failed lifecycle operations

These are potential future enhancements, not features claimed as completed in this project.

---

## Skills Demonstrated

- Active Directory administration
- PowerShell scripting and automation
- Windows Server
- Identity and Access Management (IAM)
- User lifecycle management
- Role-Based Access Control (RBAC)
- Least-privilege principles
- Organizational unit management
- Security group management
- User provisioning and deprovisioning
- Input validation and error handling
- Audit logging and post-operation verification
- Git and GitHub fundamentals

## Project Scope and Limitations

This is a portfolio lab project built with fictional employee data in a controlled Active Directory environment.

It demonstrates foundational IAM automation concepts, but it is not a production-ready identity management solution. Production deployment would require additional security controls, formal testing, change management, monitoring, and operational safeguards.

## Author

IT / IAM Portfolio Project

**Career focus:** IT Support → Identity and Access Management → Cybersecurity