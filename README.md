# readmyGPOs

`readmyGPOs` is a PowerShell-based tool designed to assist with the analysis and searching of Group Policy Objects (GPOs) within an Active Directory environment. 

---

## Features

### 1. Count GPOs

Performs a comprehensive analysis of GPOs across different Active Directory levels:

* Provides total count of all GPOs in the domain
* Displays counts of GPOs linked at:
  * Domain level
  * Organizational Unit (OU) level
  * Site level
* Reports the number of currently **enabled** GPO links

### 2. Search Menu

Allows you to scan all GPOs for a specific user-defined string:

* Searches across all GPOs in Active Directory
* Optionally ranks the GPOs by score, based on
  * Number of hits on the search term
  * Number of hits in GPO titles with weight
* Optionally saves the results to a `.txt` file


## Requirements

* PowerShell
* GroupPolicy module
* Active Directory domain access


## Usage

Launch readmyGPOs.ps1 in a PowerShell environment with appropriate privileges. Use the on-screen menu to select and interact with the desired features.
The scripts rely on relative paths so save all four scripts in the same folder!!

