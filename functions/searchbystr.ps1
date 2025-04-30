## SEARCHBYSTR FUNCTION

#   idfk give me some time to figure shit out

# building the gpostruct for the list

class GPOstruct {
    [string]$Name
    [int]$Titlecount = 0
    [int]$Bodycount = 0
    [double]$Value = 0

    GPOstruct([string]$name) { $this.Init(@{Name = $name}) }

    [string] print() 
    {
        $str = $this.name
        $str += ", Titlecount: " + [string]([bool]$this.titlecount)
        $str += ", Value:" + $this.value

        return $str
    }
}

function SearchByStr
{
    # prep
    #####################################
    
    # attributes
    $gpoList = @()
    $prioritymult = 1
    $valid = $false  # we need this for the switch rounds
    
    # 20 questions
    $filterstr = Read-Host "`nPlease enter the intended filter string: "

    do {
        $multimentions = Read-Host "`nDo you want to prioritise multiple mentions of $($filterstr) in one GPO? [y/n] "
        switch ($multimentions) {
            "y" {
                    $multimentions = [bool]1
                    Write-Host "Your output will be sorted by number of mentions.`n"
                    $valid = $true
                }
            "n" {
                    $multimentions = [bool]0
                    Write-Host "Your output will not be sorted by number of mentions.`n"
                    $valid = $true
                }
            default {
                    Write-Host "`nInvalid input. Please use 'y' for yes or 'n' for no.`n"
                }
        }
    } until ($valid)
    $valid = $false

    do {
        $titleprio = Read-Host "`nDo you want to prioritise mentions of $($filterstr) in the GPO title? [y/n] "
        switch ($titleprio) {
            "y" {
                    $prioritymult =  
                        Read-Host "Please give athe factor of priority (e.g. if a mention of $($filterstr) is twice
                        as important as a mention in the body, use '2'): "
                    try {
                        [double]$prioritymult = $prioritymult
                        $valid = $true
                    } catch { Write-Error "`nInvalid input. Please use a number." }
                }
            "n" {
                    Write-Host "Mentions of $($filterstr) in GPO titles will not be prioritised.`n"
                    $valid = $true
                }
            default {
                    Write-Host "`nInvalid input. Please use 'y' for yes or 'n' for no.`n"
                }
        }
    } until ($valid)
    $valid = $false

    # input confirmation
    Write-Host "`nYour chosen filter string is: $($filterstr)"
    Write-Host "Your output will be sorted by number of mentions: $($multimentions)"
    Write-Host "Mentions of $($filterstr) in GPO titles will be weighted with a factor $($prioritymult).`n"

    Write-Host "Starting search ..."

    # get a list of all GPOs
    $allGPOs = Get-ADObject -Filter { objectClass -eq "groupPolicyContainer" } -SearchBase "CN=Policies,CN=System,$((Get-ADDomain).DistinguishedName)"
    # might need this
    # $allGPOs = $allGPOs | Sort-Object -Property DisplayName -Unique

    Write-Host "Searching through $($allGPOs.Count) GPOs"


    # main point of this whole thing
    #####################################
    
    # search through all GPOs
    for ($i=0; $i -lt $allGPOs.Length; $i++)
    {
        Start-Sleep -Milliseconds 20
        # show progress
        Write-Progress -Activity "Reading GPOs ..." -PercentComplete ($i / $allGPOs.Length * 100)

        $iteratorid = $allGPOs[$i].Name
        $iterator = Get-GPO -Guid $iteratorid
        $title = $iterator.DisplayName
        Write-Host "$($title)"
        $titlecount = 0

        # title search first
        while ($name -match $filterstr) {
            $title = $title.Substring($title.IndexOf($filterstr) + $filterstr.Length)
            $titlecount ++
            Write-Host "$($titlecount)"
        }

        # check if body search is necessary
        if ($multimentions -or ($titlecount -eq 0))
        {
            # get xml
            # $dataxml = Get-GPOReport -GUID $iterator.Id -ReportType Xml
            # body search
        }
        
    }
}