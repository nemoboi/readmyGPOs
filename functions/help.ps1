##  HELP FUNCTION

#   explain all CLI options 
#   be concise about it

. "$PSScriptRoot\readmyGPOs.ps1"


function Help-Me
{
    Write-Host "===== HELP MENU =====" -BackgroundColor DarkGreen -ForegroundColor White
    Write-Host "This tool provides a set of utilities for GPO analysis and searching.`n"

    Write-Host "1. Count GPOs" -BackgroundColor DarkGreen -ForegroundColor White
    Write-Host "   Runs a detailed analysis of Group Policy Objects (GPOs) across domain, OU, and site levels."
    Write-Host "   Outputs counts of:"
    Write-Host "     - Total GPOs in the domain"
    Write-Host "     - GPOs linked at domain, OU, and site levels"
    Write-Host "     - GPO links that are currently enabled"
    Write-Host "   Note: Requires the GroupPolicy module and Active Directory access.`n"

    Write-Host "2. Search Menu" -BackgroundColor DarkGreen -ForegroundColor White
    Write-Host "   Scans all GPOs in Active Directory for a user-specified string."
    Write-Host "   You can choose to prioritize multiple mentions and give different weight to matches in"
    Write-Host "   GPO titles."
    Write-Host "   Each GPO is scored based on the number of matches and sorted accordingly."
    Write-Host "   Results are displayed and can optionally be saved to a .txt file.`n"

    Write-Host "3. Help" -BackgroundColor DarkGreen -ForegroundColor White
    Write-Host "   Displays this help menu with descriptions of each option.`n"

    Write-Host "4. Exit" -BackgroundColor DarkGreen -ForegroundColor White
    Write-Host "   Exits readmyGPOs.`n"

    Write-Host "5. Clear" -BackgroundColor DarkGreen -ForegroundColor White
    Write-Host "   Clears the console display for better readability.`n"

    Write-Host ""

    Run-CLI
}
