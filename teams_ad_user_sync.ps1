#author: Michelle.Douville@gov.bc.ca 
#date: June 11, 2020
#description: The script syncs members between a specified MS Teams TEAM and an Active Directory Group. 
#Removing members from a MS Teams TEAM is an optional flag <WithRemove>
#optional <TestOnly> Flag can be used to do a test run from sync to get a report of changes and a CSV lists of AD and MS Teams TEAM current members.

#usage: teams_ad_user_sync.ps1 <Team Group ID> <Active Directory Group that contain Members to add or remove from MS Teams TEAM> <WithRemove flag>
#example: c:\sw_nt\Git\msteams-helper\teams_ad_user_sync.ps1 "1f6cded9-2277-49d6-8d5c-2ec7fc9d6639" "CSNRIMIT" "WithRemove" "TestOnly"

#References:
#https://github.com/microsoftgraph/msgraph-sdk-powershell/blob/dev/samples/4-UsersAndGroups.ps1
#https://petri.com/microsoft-launches-preview-powershell-module-graph
#http://www.thatlazyadmin.com/install-microsoft-teams-powershell-module/
#https://docs.microsoft.com/en-us/powershell/module/addsadministration/get-adgroupmember?view=win10-ps
#https://community.spiceworks.com/topic/444390-get-adgroupmembers-emails
#https://docs.microsoft.com/en-us/powershell/module/teams/add-teamuser?view=teams-ps

## DEPENDENCIES Install powershell modules via powershell prompt (this took way too long, requires admin access):
#Install-Module -Name MicrosoftTeams
#Install-module Microsoft.Graph

##This may be a one time step, to allow powershell via the device:
#Connect-Graph
 
##Connect to MS Teams this is required on session startup"
#Connect-MicrosoftTeams

## HELPER COMANDS
## Find the Team (I sniffed my web traffic to find the GroupID for the IIT All staff Team)
#Get-TeamChannel -GroupId 1f6cded9-2277-49d6-8d5c-2ec7fc9d6639  
## Lists all the users in the Teams Channel:
# Get-TeamUser -GroupId 1f6cded9-2277-49d6-8d5c-2ec7fc9d6639

$TeamGroupID=$args[0]
$ADGroup=$args[1]
$Action=$args[2]
$TestOnly=$args[3]

write-host "This script will read a list of members in the Active Directory Group $ADGroup and sync them to the MS Team $TeamGroupID " 
 
## Add user's email from an LDAP group in powershell – do a loop of users and feed the userid into this command:

#builds a CSV list of emails in the given AD Group (recursively into sub groups too)
$filenameFormat = "ADList"+$ADGroup+"_"+$TeamGroupID+"_"+$ACTION +"_"+ (Get-Date -Format "yyyy-MM-dd") + ".csv"
Get-ADGroupMember -Identity $ADGroup  -Recursive | Get-ADUser -Properties Mail | Select-Object Mail | Export-CSV -Path $filenameFormat  -NoTypeInformation

#builds a CSV list of emails in the given MS Teams Team (recursively into sub groups too)
$teamlistFormat = "TeamList"+$ADGroup+"_"+$TeamGroupID+"_"+$ACTION +"_"+ (Get-Date -Format "yyyy-MM-dd") + ".csv"
Get-TeamUser -GroupId $TeamGroupID | Select-Object User | Export-CSV -Path $teamlistFormat  -NoTypeInformation

#open the CSVs
$mail_list = Import-Csv $filenameFormat
$team_list = Import-Csv $teamlistFormat

#prepare for loop, set counter and find members in AD not already in MS Teams
$i = 0
$team_addlist = $mail_list | ? { $team_list.User -notcontains $_."Mail" } 

# adds users from a CSV generated from the AD Group list
foreach ($member in $team_addlist) {
       
        if {$TestOnly -eq "TestOnly") {
          Write-Host "Add-TeamUser -GroupId $TeamGroupID -User $($member.Mail)"
        } elseif {    
          Add-TeamUser -GroupId $TeamGroupID -User $($member.Mail)
        }
        $i++  
          
}

if($Action -eq "WithRemove") {
    #prepare for loop, set counter and find members in MS Teams not Active Directory
    $r = 0
    $team_removelist = $team_list | ? { $mail_list.Mail -notcontains $_."User" } 

    #removes users from the MS Teams TEAM if they are not found in the CSV/AD Group list
    foreach ($teammember in $team_removelist) {
        #Remove-TeamUser -GroupId $TeamGroupID -User $($member.Mail)
         if {$TestOnly -eq "TestOnly") {
           Write-Host "Remove-TeamUser -GroupId $TeamGroupID -User $($teammember.User)"
         } elseif { 
           Remove-TeamUser -GroupId $TeamGroupID -User $($teammember.User)
         }
        $r++
    }
    Write-Host "There were $r members removed from the MS Teams $TeamGroupID" 
 }

Write-Host "There were $i members added to the MS Teams $TeamGroupID" 
