# PowerShell-AD-User-Lifecycle-Management
PowerShell-based Active Directory user lifecycle automation for IAM portfolio development

# PowerShell AD User Lifecycle Management

## Project Overview

This project demonstrates PowerShell-based automation for managing the employee lifecycle in a Windows Server Active Directory environment.

The project simulates common IAM and IT operations for a fictional organization, Northstar Medical Group (NMG):

- **JOINER** — Provision a new employee
- **MOVER** — Update an employee when their department or job changes
- **LEAVER** — Disable and isolate an employee during offboarding

The goal is to demonstrate practical Active Directory administration, role-based access control (RBAC), PowerShell automation, validation, error handling, and audit logging.

> **Lab project:** This repository was developed in a controlled Windows Server Active Directory lab using fictional employee data. It is not intended to represent a production implementation.

---

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

---

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

---

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
