##  ANALYSIS FUNCTION

#   give count of
#     - all available GPOs
#     - all GPOs in use (linked to OU)
#     - all GPOs in active use (linked to OU and link Enabled)


# site level GPOs cause GPInheritance is a bitch and doesn't like sites
function GetSiteLevel
{
    $siteDNprefix = "CN=Sites,"+([ADSI]"LDAP://RootDSE").configurationNamingContext
    $sites = Get-ADObject -SearchBase $siteDNprefix -Filter 'objectClass -eq "site"' -Properties gPLink

    $siteGPOlinks = @()
    foreach ($site in $sites) {
        if ($site.gPLink) {
            $site.gPLink -split '\[LDAP://' | ForEach-Object {
                if ($_ -match '^CN={(.*?)}.*;([01])\]') {
                    $gpoGuid = $matches[1]
                    $enabled = [int]$matches[2]
                    $gpo = Get-GPO -Guid $gpoGuid -ErrorAction SilentlyContinue
                    if ($gpo) {
                        $siteGPOlinks += [PSCustomObject]@{
                            DisplayName = $gpo.DisplayName
                            Guid        = $gpo.Id
                            Enabled     = $enabled
                            Site        = $site.Name }
                    }
                }
            }
        }
    }
    return $siteGPOlinks
}

function Analysis  
{
    # check and import GPO module

    if (-Not (Get-Module -ListAvailable -Name GroupPolicy))
    {
        Write-Error "Please make sure you have installed the GroupPolicy Module! Otherwise this will be a very unhelpful time."
        return
    }
    Import-Module GroupPolicy


    # ANALYSIS
    # lists
    
    # domain level
    $domain = ([ADSI]"LDAP://RootDSE").defaultNamingContext[0]
    $domainlinkedGPOs = (Get-GPInheritance -Target $domain).GpoLinks
    $domainlinkedGPOsACTIVE = $domainlinkedGPOs | Where-Object {$_.Enabled -ne "None"}

    # OU level
    $ouGPOlinks = @()
    $oulinkedGPOs = @()
    Get-ADOrganizationalUnit -Filter * | ForEach-Object {
        $ouGPOlinks += (Get-GPInheritance -Target $_.DistinguishedName).GpoLinks }
    $oulinkedGPOs = $ouGPOlinks | Where-Object { $_.DisplayName -ne $null }
    $oulinkedGPOs = $oulinkedGPOs | Sort-Object -Property Guid, @{Expression = {$_."Enabled" -eq "None"}; Descending=$true} -Unique
    $oulinkedGPOsACTIVE = $oulinkedGPOs | Where-Object {$_.Enabled -ne "None"}

    # site level
    #$siteGPOlinks = @()
    $sitelinkedGPOs = @()
    #Get-ADReplicationSite -Filter * | ForEach-Object {
    #    $siteGPOlinks += Get-GPLink -Target ("CN=" + $_.Name + ",CN=Sites,CN=Configuration," + ([ADSI]"LDAP://RootDSE").configurationNamingContext) }
    $siteGPOlinks = GetSiteLevel
    #$sitelinkedGPOsACTIVE = $sitelinkedGPOs | Where-Object {$_.Enabled == 1}

    # total
    $allGPOsCount = (Get-ADObject -Filter { objectClass -eq "groupPolicyContainer" } -SearchBase "CN=Policies,CN=System,$((Get-ADDomain).DistinguishedName)").Count
    $alllinkedGPOs = @()
    $alllinkedGPOs += $domainlinkedGPOs
    $alllinkedGPOs += $oulinkedGPOs
    $alllinkedGPOs += $sitelinkedGPOs
    $alllinkedGPOs = $alllinkedGPOs | Where-Object { $_.DisplayName -ne $null } 
    $alllinkedGPOs = $alllinkedGPOs | Sort-Object -Property Guid, @{Expression = {$_."Enabled" -eq "None"}; Descending=$true} -Unique
    $alllinkedGPOsACTIVE = $alllinkedGPOs | Where-Object {$_.Enabled -ne "None"}


    # output print
    Write-Output "===== GPO use ====="
    
    Write-Output ""
    Write-Output "Total GPOs: $($allGPOsCount)"
    Write-Output "Total linked GPOs: $($alllinkedGPOs.Count)"
    Write-Output "Total linked GPOs with Enabled links: $($alllinkedGPOsACTIVE.Count)"

    Write-Output ""
    Write-Output "Domain-level linked GPOs: $($domainlinkedGPOs.Count)"
    Write-Output "Domain-level linked GPOs with Enabled links: $($domainlinkedGPOsACTIVE.Count)"

    Write-Output ""
    Write-Output "OU-level links to GPOs: $($ouGPOlinks.Count)"
    Write-Output "OU-level linked GPOs: $($oulinkedGPOs.Count)"
    Write-Output "OU-level linked GPOs with Enabled links: $($oulinkedGPOsACTIVE.Count)"

    Write-Output ""
    Write-Output "Site-level links to GPOs: $($siteGPOlinks.Count)"
    Write-Output "Site-level linked GPOs: $($sitelinkedGPOs.Count)"
    Write-Output "Site-level linked GPOs with Enabled links: $($sitelinkedGPOsACTIVE.Count)"

    }

Analysis
