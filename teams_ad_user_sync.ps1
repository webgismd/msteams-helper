#author: Michelle.Douville@gov.bc.ca 
#date: June 11, 2020
#description: The scripts can do two things: ADD or REMOVE a list of members within an AD Group to/from a MS Teams TEAM.
#usage: teams_ad_user_sync.ps1 <Team Group ID> <Active Directory Group than contain Members to add or remove from MS Teams TEAM> <Add or Remove flag>
#example: c:\sw_nt\Git\msteams-helper\teams_ad_user_sync.ps1 "1f6cded9-2277-49d6-8d5c-2ec7fc9d6639" "CSNRIMIT" "Add"

$TeamGroupID=$args[0]
$ADGroup=$args[1]
$Action=$args[2]
write-host "This script will read a list of members in the Active Directory Group $ADGroup and $Action them to the MS Team $TeamGroupID " 

## 1. Install powershell modules via powershell prompt (this took way too long, requires admin access):
#Install-Module -Name MicrosoftTeams
#Install-module Microsoft.Graph
 
## 2.	This may be a one time step, to allow powershell via the device:
#Connect-Graph
 
## 3.	Connect to MS Teams"
#Connect-MicrosoftTeams

## 4.	Find the Team (I sniffed my web traffic to find the GroupID for the IIT All staff Team)
#Get-TeamChannel -GroupId 1f6cded9-2277-49d6-8d5c-2ec7fc9d6639  

## 5.	Lists all the users in the Teams Channel:
# Get-TeamUser -GroupId 1f6cded9-2277-49d6-8d5c-2ec7fc9d6639
 
## 6.	Add user's email from an LDAP group in powershell – do a loop of users and feed the userid into this command:
##Active Directory call: *you would have to do a recursive loop to get users and groups within the AD group
##https://docs.microsoft.com/en-us/powershell/module/addsadministration/get-adgroupmember?view=win10-ps
#Get-AdGroupMember -identity "CSNRIMIT"  
##https://community.spiceworks.com/topic/444390-get-adgroupmembers-emails

#builds a CSV list of emails in the given AD Group (recursively into sub groups too)
$filenameFormat = "EmailList"+$ADGroup+"_"+$TeamGroupID+"_"+$ACTION +"_"+ (Get-Date -Format "yyyy-MM-dd") + ".csv"

Get-ADGroupMember -Identity $ADGroup  -Recursive | Get-ADUser -Properties Mail | Select-Object Mail | Export-CSV -Path $filenameFormat  -NoTypeInformation

## 7.	The command in the recursive loop: (note previous step deals with the recursive issue)
##https://docs.microsoft.com/en-us/powershell/module/teams/add-teamuser?view=teams-ps
# Add-TeamUser -GroupId 1f6cded9-2277-49d6-8d5c-2ec7fc9d6639 -User Kevin.Netherton@gov.bc.ca  

#Get-Content -path $filenameFormat | 
$mail_list = Import-Csv $filenameFormat
$i = 0
foreach ($member in $mail_list) {
    if($Action -eq "Add") {
        #Add-TeamUser -GroupId $TeamGroupID -User $($member.Mail)
        Write-Host "Add-TeamUser -GroupId $TeamGroupID -User $($member.Mail)"
     }
    if($Action -eq "Remove") {
        #Remove-TeamUser -GroupId $TeamGroupID -User $($member.Mail)
        Write-Host "Remove-TeamUser -GroupId $TeamGroupID -User $($member.Mail)"
     } 
     $i++  
}
Write-Host "There were $i members $Action from the MS Teams $TeamGroupID" 
#References:
#https://github.com/microsoftgraph/msgraph-sdk-powershell/blob/dev/samples/4-UsersAndGroups.ps1
#https://petri.com/microsoft-launches-preview-powershell-module-graph
#http://www.thatlazyadmin.com/install-microsoft-teams-powershell-module/
