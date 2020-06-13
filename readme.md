
# teams_ad_user_sync.ps1 ... and other MS Teams helper files

### Author: Michelle.Douville@gov.bc.ca

### Date: June 11, 2020

### Description

This powershell script syncs members of a specified MS Teams TEAM with a specified authoritative Active Directory Group.<BR>
<BR>  
NOTE: The Active Directory Group is considered the authoritative membership to base all changes off of, no changes to the AD Group will occur with this script.<BR><BR>
(WithRemove) is an optional flag for removing members from a MS Teams TEAM (ie. leave out if you only want to ADD users)<BR>
(TestOnly or Update) is a flag that can be used to do a test run for a sync, to get a report of potential changes, and to create CSV lists of AD and MS Teams TEAM current members.<BR>

### Usage

``` powershell
  teams_ad_user_sync.ps1 (Team Group ID) (Active Directory Group that contain Members to add or remove from MS Teams TEAM) (WithRemove flag) (TestOnly or Update flag)
```

### Example

``` powershell
  teams_ad_user_sync.ps1 "1f6cded9-2277-49d6-8d5c-2ec7fc9d6639" "CSNRIMIT" "WithRemove" "TestOnly"
```

### References

<https://github.com/microsoftgraph/msgraph-sdk-powershell/blob/dev/samples/4-UsersAndGroups.ps1><BR>
<https://petri.com/microsoft-launches-preview-powershell-module-graph><BR>
<http://www.thatlazyadmin.com/install-microsoft-teams-powershell-module/><BR>
<https://docs.microsoft.com/en-us/powershell/module/addsadministration/get-adgroupmember?view=win10-ps><BR>
<https://community.spiceworks.com/topic/444390-get-adgroupmembers-emails><BR>
<https://docs.microsoft.com/en-us/powershell/module/teams/add-teamuser?view=teams-ps><BR>

### **** NEEDS TO BE COMPLETED ONCE ON DEVICE**** DEPENDENCIES

Install powershell modules via powershell prompt (this took way too long, requires admin access):

 ``` powershell
 Install-Module -Name MicrosoftTeams
 Install-module Microsoft.Graph
 ```

### **** NEEDS TO BE COMPLETED ONCE ON DEVICE****

This may be a one time step, to allow powershell via the device:

``` powershell
 Connect-Graph
 ```

### **** NEEDS TO BE COMPLETED ONCE ON DEVICE PER SESSION****

Connect to MS Teams this is required on session startup -

``` powershell
 Connect-MicrosoftTeams
 ```

### HELPER COMANDS

Find the Team (I sniffed my web traffic to find the GroupID for the IIT All staff Team)

``` powershell
 Get-TeamChannel -GroupId 1f6cded9-2277-49d6-8d5c-2ec7fc9d6639  
 ```

Lists all the users in the Teams Channel:

``` powershell
 Get-TeamUser -GroupId 1f6cded9-2277-49d6-8d5c-2ec7fc9d6639
 ```
