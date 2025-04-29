## HELP FUNCTION

#   explain all CLI options 
#   be concise about it


function Help
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
    Write-Host "   tbd`n"

    Write-Host "3. Help" -BackgroundColor DarkGreen -ForegroundColor White
    Write-Host "   Displays this help menu with descriptions of each option.`n"

    Write-Host "4. Exit" -BackgroundColor DarkGreen -ForegroundColor White
    Write-Host "   Exits readmyGPOs.`n"

    Write-Host "5. Clear" -BackgroundColor DarkGreen -ForegroundColor White
    Write-Host "   Clears the console display for better readability.`n"

    Write-Host ""
}
