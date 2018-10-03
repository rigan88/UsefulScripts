# PnP Powershell


## Documentation

- [sharepoint-pnp-cmdlets](https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-pnp/sharepoint-pnp-cmdlets?view=sharepoint-ps)


## Latest Version

- [Latest Release Version](https://github.com/SharePoint/PnP-PowerShell/releases/latest)
- [Change Log](https://github.com/SharePoint/PnP-PowerShell/blob/master/CHANGELOG.md)


## Check 

```Powershell
Get-Module SharePointPnPPowerShell* -ListAvailable | Select-Object Name,Version | Sort-Object Version -Descending
```

## Update Module to latest version

```Powershell
Update-Module SharePointPnPPowerShell*  
```

## Delete old version

```Powershell
Get-InstalledModule -Name "SharePointPnPPowerShellOnline" -RequiredVersion 2.24.1803.0 | Uninstall-Module
```

## List all commands

```Powershell
Get-Command | ? { $_.ModuleName -eq "SharePointPnPPowerShellOnline" }
```

## Upload Documents
- https://gallery.technet.microsoft.com/office/Upload-Multiple-Documents-4c4aa989

```Powershell
function UploadDocuments(){
Param(
        [ValidateScript({If(Test-Path $_){$true}else{Throw "Invalid path given: $_"}})] 
        $LocalFolderLocation,
        [String] 
        $siteUrl,
        [String]
        $documentLibraryName
)
Process{
        $path = $LocalFolderLocation.TrimEnd('\')

        Write-Host "Provided Site :"$siteUrl -ForegroundColor Green
        Write-Host "Provided Path :"$path -ForegroundColor Green
        Write-Host "Provided Document Library name :"$documentLibraryName -ForegroundColor Green

          try{
                $credentials = Get-Credential
  
                Connect-PnPOnline -Url $siteUrl -CreateDrive -Credentials $credentials

                $file = Get-ChildItem -Path $LocalFolderLocation -Recurse
                $i = 0;
                Write-Host "Uploading documents to Site.." -ForegroundColor Cyan
                (dir $path -Recurse) | %{
                    try{
                        $i++
                        if($_.GetType().Name -eq "FileInfo"){
                          $SPFolderName =  $documentLibraryName + $_.DirectoryName.Substring($path.Length);
                          $status = "Uploading Files :'" + $_.Name + "' to Location :" + $SPFolderName
                          Write-Progress -activity "Uploading Documents.." -status $status -PercentComplete (($i / $file.length)  * 100)
                          $te = Add-PnPFile -Path $_.FullName -Folder $SPFolderName
                         }          
                        }
                    catch{
                    }
                 }
            }
            catch{
             Write-Host $_.Exception.Message -ForegroundColor Red
            }

  }
}


#UploadDocuments -LocalFolderLocation {Local Folder Location} -siteUrl {Site collection URL} -documentLibraryName {Document Library Name}
```

## Site Classification

- https://www.jijitechnologies.com/blogs/site-classification-using-pnp-powershell

```Powershell
Connect-PnPOnline -Scopes "Directory.ReadWrite.All"
```

```Powershell
Enable-PnPSiteClassification -Classifications "HBI","LBI","Top Secret" -UsageGuidelinesUrl ```
"http://aka.ms/sppnp" -DefaultClassification "HBI"
```

```Powershell
Add-PnPSiteClassification -Classifications "SBI","MBI"
```

```Powershell
Remove-PnPSiteClassification -Classifications "SBI"
```

```Powershell
Update-PnPSiteClassification -Classifications "HBI","LBI","Top Secret" -UsageGuidelinesUrl http://aka.ms/sppnp" -DefaultClassification "HBI"
```

```Powershell
Disable-PnPSiteClassification
```