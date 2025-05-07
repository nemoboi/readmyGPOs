## SEARCHBYSTR FUNCTION

#   idfk give me some time to figure shit out


. "$PSScriptRoot\CLI.ps1"

# building the gpostruct for the list
class GPOstruct {
    [string]$Name
    [int]$Titlecount = 0
    [int]$Bodycount = 0
    [double]$Value = 0

    GPOstruct([string] $name, [int] $titlecount, [int] $bodycount, [double] $value) { 
        $this.Name = $name
        $this.Titlecount = $titlecount
        $this.Bodycount = $bodycount
        $this.Value = $value
    }

    [string] print() 
    {
        $str = $this.name
        $str += ", Titlesearch: " + [string]$this.titlecount + "hits"
        #will leave off bodysearch cause it is weird when multimentions is disabled
        #$str += ", Bodysearch: " + [string]$this.bodycount + "hits"
        
        return $str
    }
    
    
}

function SearchByStr
{
    # prep
    #####################################
    
    $valid = $false  # we need this for the switch rounds
    $prioritymult = 1 # default multiplicator for titlecount
    
    # 20 questions
    $filterstr = Read-Host "`nPlease enter the intended filter string: "

    do {
        $multimentions = Read-Host "`nDo you want to prioritise multiple mentions of $($filterstr) in one GPO? [y/n] "
        switch ($multimentions) {
            "y" {
                    $multimentions = 1
                    Write-Host "Your output will be sorted by number of mentions.`n"
                    $valid = $true
                }
            "n" {
                    $multimentions = 0
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
    # might need this, might not
    # $allGPOs = $allGPOs | Sort-Object -Property DisplayName -Unique

    Write-Host "Today's GPOs are proudly presented to you by $((Get-ADDomainController -Discover).HostName)"
    Write-Host "Searching through $($allGPOs.Count) GPOs"


    # main point of this whole thing
    #####################################

    $filteredGPOs = @()
    
    # search through all GPOs
    for ($i=0; $i -lt $allGPOs.Length; $i++)
    {
        # show progress
        Write-Progress -Activity "Reading GPOs ..." -PercentComplete ($i / $allGPOs.Length * 100)
        
        $iteratorid = $allGPOs[$i].Name
        # patching for the 3 annoying gpos
        if ($iteratorid -match "`n") {
            $iteratorid = $iteratorid -split "`r?`n", 2 | Select-Object -First 1
        }
        $iterator = Get-GPO -Guid $iteratorid
        $title = $iterator.DisplayName
        Write-Debug "GPO: $($title)"
        
        $titlecount = 0
        $bodycount = 0

        # title search first
        $titlecount = ($title -split [regex]::Escape($filterstr)).Count - 1
        Write-Debug "Titlecount: $($titlecount)"
        try { $check = $titlecount -ge 0 }
        catch { "GPO title empty." }

        # check if body search is necessary
        if ($multimentions -or ($titlecount -eq 0))
        {
        # body search
            # get xml
            $dataxml = Get-GPOReport -GUID $iterator.Id -ReportType Xml
            
            # search
            $bodycount = ($dataxml -split [regex]::Escape($filterstr)).Count - 1
            Write-Debug "Bodycount: $($bodycount)"

        }
        
        # check if GPO is interesting
        if (($titlecount + $bodycount) -gt 0)
        {
            # calc value
            $value = 0
            if ($multimentions) { $value = $titlecount * $titleprio + $bodycount }
            # generate object
            $temp = [GPOstruct]::new($title, $titlecount, $bodycount, $value)
            # add object to list
            $filteredGPOs += $temp
        }
        
    }

    # sort list
    $filteredGPOs | Sort-Object -Property Value -Descending
    # output
    for ($i=0; $i -lt $filteredGPOs.Length; $i++)
    {
        $filteredGPOs[$i].print()
    }

    # options for saving to file
    do {
        $savetofile = Read-Host "`n`nDo you want to save this list to a file? [y/n] "
        switch ($savetofile) {
            "y" {
                    $savetofile = 1
                    $valid = $true
                }
            "n" {
                    $savetofile = 0
                    $valid = $true
                }
            default {
                    Write-Host "`nInvalid input. Please use 'y' for yes or 'n' for no.`n"
                }
        }
    } until ($valid)
    $valid = $false

    if ($savetofile -eq 1)
    {
        # generate a file name
        $date = Get-Date -Format "yyyyMMdd"
        $filename = "gpos-search-" + $filterstr + "-" + $date + ".txt"

        # get path
        do {
            Write-Host "`nPlease enter the path to the directory you wish to save the file in. "
            $path = Read-Host "If you leave the path empty, the file will be saved in your current directory: "
            if ($path -eq "") { $path = "." }
            $filepath = $path+"/"+$filename

            # make sure path is valid
            if (Test-Path -Path $filepath) { Write-Host "`nInvalid input. $($filename) already exists in that folder.`n" }
            elseif (Test-Path -Path $path) { $valid = $true }
            else { Write-Host "`nInvalid input. Please choose an existing directory.`n" }
        } until ($valid)
        $valid = $false

        # write $filteredGPOs into file 
        $filteredGPOs | Out-File -FilePath $filepath 

    }
    Run-CLI
}