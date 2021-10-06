
# Source: https://pnp.github.io/script-samples/spo-get-list-library-permission-export-to-csv/README.html?tabs=pnpps

$adminSiteURL = "https://domain-admin.sharepoint.com/"
$username = "user@domain.onmicrosoft.com"
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$Creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$global:permissions = @()
$BasePath = "E:\Contribution\PnP-Scripts\ListOrLibraryPermission\"
$DateTime = "{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$CSVPath = $BasePath + "\permissions" + $DateTime + ".csv"

Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Creds)     
    Write-Host "Connecting to Tenant Admin Site '$($adminSiteURL)'" -f Yellow 
    Connect-PnPOnline -Url $adminSiteURL -Credentials $Creds
    Write-Host "Connection Successfull" -f Green 
}

#Login to SharePoint Site
Function ConnectToSPSite() {
    try {
        $SiteUrl = Read-Host "Please enter SiteURL"
        if ($SiteUrl) {
            Write-Host "Connecting to Site :'$($SiteUrl)'..." -ForegroundColor Yellow  
            Connect-PnPOnline -Url $SiteUrl -Credentials $Creds
            Write-Host "Connection Successfull to site: '$($SiteUrl)'" -ForegroundColor Green              
            GetPermissions
        }
        else {
            Write-Host "Site URL is empty" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error in connecting to Site:'$($SiteUrl)'" $_.Exception.Message -ForegroundColor Red               
    } 
}

#Connect to list and get permissions
Function GetPermissions() {
    try {
        $ListName = Read-Host "Please enter list title"
        if ($ListName) {
            Write-Host "Connecting to List :'$($ListName)'..." -ForegroundColor Yellow  
            $List = Get-PnpList -Identity $ListName -Includes RoleAssignments

            Get-PnPProperty -ClientObject $List -Property HasUniqueRoleAssignments, RoleAssignments      
            $HasUniquePermissions = $List.HasUniqueRoleAssignments
            
            Write-Host "Getting permission for the List :'$($ListName)'..." -ForegroundColor Yellow  

            Foreach ($RoleAssignment in $List.RoleAssignments) {                
                Get-PnPProperty -ClientObject $RoleAssignment -Property RoleDefinitionBindings, Member
                  
                $PermissionType = $RoleAssignment.Member.PrincipalType
                     
                $PermissionLevels = $RoleAssignment.RoleDefinitionBindings | Select -ExpandProperty Name
                
                If ($PermissionLevels.Length -eq 0) { Continue } 

                If ($PermissionType -eq "SharePointGroup") {
                    
                    $GroupMembers = Get-PnPGroupMembers -Identity $RoleAssignment.Member.LoginName                                  
                    If ($GroupMembers.count -eq 0) { Continue }
                    ForEach ($User in $GroupMembers) {
                        $global:permissions += New-Object PSObject -Property ([ordered]@{
                                Title                = $User.Title 
                                PermissionType       = $PermissionType
                                PermissionLevels     = $PermissionLevels -join ","
                                Member               = $RoleAssignment.Member.Title     
                                HasUniquePermissions = $HasUniquePermissions                                     
                            })  
                    }
                }                        
                Else {                                        
                    $global:permissions += New-Object PSObject -Property ([ordered]@{
                            Title                = $RoleAssignment.Member.Title 
                            PermissionType       = $PermissionType
                            PermissionLevels     = $PermissionLevels -join ","
                            Member               = "Direct Permission"      
                            HasUniquePermissions = $HasUniquePermissions                             
                        })  
                }                            
            }   
            Write-Host "Getting permission successfully!" -ForegroundColor Green                         
            BindingtoCSV($global:permissions)
        }
        else {
            Write-Host "list title is empty" -ForegroundColor Red
        }
        $global:permissions = @()
    }
    catch {
        Write-Host "Error in getting list:'$($ListName)'" $_.Exception.Message -ForegroundColor Red               
    } 
}

Function BindingtoCSV {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Global)   
    $global:permissions | Export-Csv $CSVPath -NoTypeInformation -Append
    Write-Host "Exported successfully" -ForegroundColor Green
}

Function StartProcessing {
    Login($Creds);   
    ConnectToSPSite 
}

StartProcessing
