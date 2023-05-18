
# https://pnp.github.io/script-samples/spo-file-version-trimmer/README.html?tabs=pnpps

$ClientId = "XXXXXX"
$TenantName = "contoso.onmicrosoft.com"
$thumbprint = "ZZZZZZZ"
$SharePointAdminSiteURL = "https://contoso-admin.sharepoint.com"

$conn = Connect-PnPOnline -Url $SharePointAdminSiteURL -ClientId $ClientId -Tenant $TenantName -CertificatePath "C:\Users\you\certificate.pfx" -CertificatePassword (ConvertTo-SecureString -AsPlainText -Force "CentificatePassword") -ReturnConnection



#Set Variables
$outputPath = "C:\temp\versiontrimmer\" 
$arraylist = New-Object System.Collections.ArrayList


function DeleteVersions($siteUrl, $ListName, $listitemID, $versionsToKeep)
{
    try 
    {
        $siteconn = Connect-PnPOnline -Url $siteUrl -ClientId $ClientId -Tenant $TenantName -CertificatePath "C:\Users\KasperLarsen\IAGovApp.pfx" -CertificatePassword (ConvertTo-SecureString -AsPlainText -Force "IAGovApp") -ReturnConnection

        #get list of all lists in this site
        if($ListName)
        {
            $list = Get-PnPList -Identity $ListName -Connection $siteconn -ErrorAction SilentlyContinue
            if($list)
            {
                $listitems = Get-PnPListItem -List $list -Connection $siteconn
                if($listitemID)
                {
                    $listitem = $listitems | Where-Object {$_.ID -eq $listitemID}
                    if($listitem)
                    {
                        $file = Get-PnPFile  -Url $listitem["FileRef"] -AsFileObject -ErrorAction SilentlyContinue -Connection $siteconn           
                        if($file)
                        {
                            $fileversions = Get-PnPFileVersion -Url $listitem["FileRef"] -Connection $siteconn
                            if($fileversions)
                            {
                                if($fileversions.Count -gt $versionsToKeep)
                                {
                                    $DeleteVersionList = ($fileversions[0..$($fileversions.Count - $versionsToKeep)])
                                    $element = "" | Select-Object SiteUrl, siteName, ListTitle, itemName, fileType, Modified, versioncount, FileSize
                                    $element.SiteUrl = $siteUrl
                                    $element.siteName = $siteconn.Name
                                    $element.ListTitle = $list.Title
                                    $element.itemName = $file.Name
                                    $fileextention = $item["FileLeafRef"].Substring($item["FileLeafRef"].LastIndexOf(".")+1)
                                    $element.fileType = $fileextention
                                    $element.Modified = $file.TimeLastModified.tostring()
                                    $element.versioncount = $fileversions.Count
                                    $element.fileSize = $file.Length
                                    
                                    $arraylist.Add($element) | Out-Null
                        
                                    
                                    foreach($VersionToDelete in $DeleteVersionList) 
                                    {
                                        Remove-PnPFileVersion -Url $listitem["FileRef"] -Identity $VersionToDelete.Id –Force -Connection $siteconn            
                                    }
                                }
                                else {
                                    write-host "no versions to delete"
                                }
                            }
                            
                        }
                        else {
                            write-host "file not found" -ForegroundColor Red
                        }
                    }
                }
                else 
                {
                    foreach($listitem in $listitems)
                    {
                        $file = Get-PnPFile  -Url $listitem["FileRef"] -AsFileObject -ErrorAction SilentlyContinue -Connection $siteconn           
                        if($file)
                        {
                            $fileversions = Get-PnPFileVersion -Url $listitem["FileRef"] -Connection $siteconn
                            if($fileversions)
                            {
                                Write-Host "fileversions found $($fileversions.Count)"
                                if($fileversions.Count -gt $versionsToKeep)
                                {
                                    $number =$fileversions.Count - $versionsToKeep
                                    $DeleteVersionList = ($fileversions[0..$number])
                                    $element = "" | Select-Object SiteUrl, ListTitle, itemName, fileType, Modified, versioncount, FileSize
                                    $element.SiteUrl = $siteUrl
                                    $element.ListTitle = $list.Title
                                    $element.itemName = $file.Name
                                    $fileextention = $listitem["FileLeafRef"].Substring($listitem["FileLeafRef"].LastIndexOf(".")+1)
                                    $element.fileType = $fileextention
                                    $element.Modified = $file.TimeLastModified.tostring()
                                    $element.versioncount = $fileversions.Count
                                    $element.fileSize = $file.Length
                                    
                                    $arraylist.Add($element) | Out-Null
                                    foreach($VersionToDelete in $DeleteVersionList) 
                                    {
                                        Remove-PnPFileVersion -Url $listitem["FileRef"] -Identity $VersionToDelete.Id –Force -Connection $siteconn            
                                    }
                                }
                                else {
                                    write-host "no versions to delete"
                                }
                                
                            }
                            else {
                                write-host "fileversions not found" -ForegroundColor Yellow
                            }
                            
                        }
                        else {
                            write-host "file not found" -ForegroundColor Yellow
                        }
                    }
                }
            }
            
        }
        else {
            # you can trim all lists in a site here
        }
            
    }
    catch 
    {
        Write-Output "Ups an exception was thrown : $($_.Exception.Message)" -ForegroundColor Red
    }
  
}


function Get-SiteCollections
{
    # this function is just a way to get the site collections that are in scope for the trimming
    $SiteCollections = Get-PnPTenantSite -Connection $conn  
    Disconnect-PnPOnline -Connection $conn
    return $SiteCollections

}

# $allsitecollections = Get-SiteCollections
# foreach($SiteCollection in $SiteCollections)
# {
#     DeleteVersions -siteUrl $SiteCollection.Url -ListName "Shared Documents" -listitemID 1 -versionsToKeep 20   
# }


#get total storage use for this site collection
$siteUrl = "https://contoso.sharepoint.com/sites/aSpecificSiteCollection"
$site = Get-PnPTenantSite -Connection $conn -Url $siteUrl -Detailed
$siteStorage = $site.StorageUsageCurrent
$siteStorage = $siteStorage / 1024 
$siteStorage = [Math]::Round($siteStorage,2)
write-host "site storage $siteStorage GB"

DeleteVersions -siteUrl $siteUrl -ListName "DocLibMajors"  -versionsToKeep 10
$arraylist | Export-Csv -Path "C:\temp\\versiontrimmer.csv" -NoTypeInformation -Force -Encoding utf8BOM -Delimiter "|"






