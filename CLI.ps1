##  CLI

#   - show options
#   - navigate options into other functions analysis, searchbystring, help
#   - implement exit function

. "$PSScriptRoot\functions\analysis.ps1"
. "$PSScriptRoot\functions\searchbystr.ps1"
. "$PSScriptRoot\functions\help.ps1"

function Show-Menu {
    Clear-Host
    Write-Host "====================="
    Write-Host "   readmyGPOs Menu   "
    Write-Host "====================="
    Write-Host ""
    Write-Host "1. Count GPOs"
    Write-Host "2. Search GPOs"
    Write-Host "3. Help"
    Write-Host "4. Exit"
    Write-Host ""
}

function Run-CLI {
    do {
        Show-Menu
        $choice = Read-Host "Enter your choice (1-4)"

        switch ($choice) {
            "1" {
                Write-Host "`nCounting GPOs ...`n"
                Write-Host ""
                Analysis
                Pause
            }
            "2" {
                Write-Host "`nReferring you to the Search Menu ...`n"
                Write-Host ""
                SearchByStr
                Pause
            }
            "3" {
                Write-Host "`n Need some help?`n"
                Write-Host ""
                Help
                Pause
            }
            "4" {
                Write-Host "`nExiting ..."
            }
            default {
                Write-Host "`nInvalid selection. Please try again.`n"
                Pause
            }
        }
    } while ($choice -ne "4")
}

Run-CLI