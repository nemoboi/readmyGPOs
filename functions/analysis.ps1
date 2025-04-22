##  ANALYSIS FUNCTION

#   give count of
#     - all available GPOs
#     - all GPOs in use (linked to OU)
#     - all GPOs in active use (linked to OU and link Enabled)


function Analysis  
{
    # check and import GPO module

    if (-Not (Get-Module -ListAvailable -Name GroupPolicy))
    {
        return false
    }
    Import-Module Group-Policy


    # ANALYSIS
    # lists
    
    # domain level
    $domain = ([ADSI]"LDAP://RootDSE").defaultNamingContext
    $domainlinkedGPOs = (Get-GPInheritance -Target $domain).GpoLinks
    $domainlinkedGPOsACTIVE = $domainlinkedGPOs | Where-Object {$_.Enabled -eq $true}

    # OU level
    $oulinkedGPOs = @()
    Get-ADOrganizationalUnit -Filter * | ForEach-Object 
        { $oulinkedGPOs += (Get-GPInheritance -Target $_.DistinguishedName).GpoLinks }
    $oulinkedGPOsACTIVE = $oulinkedGPOs | Where-Object {$_.Enabled -eq $true}

    # site level
    $sitelinkedGPOs = @()
    Get-ADReplicationSite -Filter * | ForEach-Object
        { $sitelinkedGPOs += (Get-GPInheritance -Target $_.DistinguishedName).GpoLinks }
    $sitelinkedGPOsACTIVE = $sitelinkedGPOs | Where-Object {$_.Enabled -eq $true}

    # total
    $allGPOs = Get-GPO -All
    $alllinkedGPOs = $domainlinkedGPOs + $oulinkedGPOs + $sitelinkedGPOs
    $alllinkedGPOs = $alllinkedGPOs | Where-Object { $_.DisplayName -ne $null } | Select-Object -ExpandProperty Guid -Unique
    $alllinkedGPOsACTIVE = $alllinkedGPOs | Where-Object {$_.Enabled -eq $true}


    # output print
    Write-Output "===== GPO use ====="
    
    Write-Output ""
    Write-Output "Total GPOs: $($allGPOs.Count)"
    Write-Output "Total linked GPOs: $($alllinkedGPOs.Count)"
    Write-Output "Total linked GPOs with Enabled links: $($alllinkedGPOsACTIVE.Count)"

    Write-Output ""
    Write-Output "Domain-level linked GPOs: $($domainlinkedGPOs.Count)"
    Write-Output "Domain-level linked GPOs with Enabled links: $($domainlinkedGPOsACTIVE.Count)"

    Write-Output ""
    Write-Output "OU-level linked GPOs: $($oulinkedGPOs.Count)"
    Write-Output "OU-level linked GPOs with Enabled links: $($oulinkedGPOsACTIVE.Count)"

    Write-Output ""
    Write-Output "Site-level linked GPOs: $($sitelinkedGPOs.Count)"
    Write-Output "Site-level linked GPOs with Enabled links: $($sitelinkedGPOsACTIVE.Count)"

    
}