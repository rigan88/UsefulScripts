# Source: https://pnp.github.io/script-samples/spo-remove-webpart-from-pages/README.html?tabs=pnpps

Function Remove-WebpartFromPages() {
    PARAM (
        [Parameter(Mandatory = $true)]
        [string]$SiteURL,

        [Parameter(Mandatory = $false)]
        [string[]]$WebPartIds,

        [Parameter(Mandatory = $false)]
        [string]$ContentTypeId,

        [Parameter(Mandatory = $false)]
        [string[]]$Pages
    )

    Try {
            ## Connect to SharePoint Online site  
            Write-Host "Connect to $($SiteURL)"
            Connect-PnPOnline -URL $SiteURL -UseWebLogin

            $pageItems = @()
            $skippedPages = @()

            # If page parameter is empty, loop through all pages
            if ($Pages.Length -lt 1) {
                $pageItems = Get-PnPListItem -List "Site Pages"
                $Pages = $pageItems | ForEach-Object { $_["FileLeafRef"] }
            }

            if($Pages.Length -lt 1){
                $pageItems = Get-PnPListItem -List "Site Pages"
            }
            
            if ($ContentTypeId) {
                $pageItems = $pageItems | Where-Object {$_["ContentTypeId"].toString() -eq $ContentTypeId}
            }
            
            if($pageItems.Length -ge 1){
                $Pages = $pageItems | ForEach-Object{ $_["FileLeafRef"] }
            }
            
            $Pages | ForEach-Object {
                $fileLeafRef = $_
                Write-Host "Processing $fileLeafRef"
                try {
                    $page = Get-PnPPage -Identity $fileLeafRef
                    if($WebPartIds.Length -ge 1){
                        $controls = $page.Controls | Where-Object {$WebPartIds -contains $_.Title -or $WebPartIds -contains $_.WebPartId}
                    }                    
                    $controls | ForEach-Object {
                        Write-Host "Removing web part: $($_.Title)"
                        Remove-PnPPageComponent -Page $page -InstanceId $_.InstanceId -Force
                        Write-Host "Web part $($_.Title) removed successfully from $($fileLeafRef)" -ForegroundColor "green"
                    }
                }
                catch {
                    $skippedPages += $fileLeafRef                    
                    Write-Host "Skipped $fileLeafRef" -ForegroundColor "yellow"
                }
            
            }
        }

        Catch {
            Write-Host "Error: $($_.Exception)" -ForegroundColor Red
            Break
        }

        ## Disconnect the context  
        Disconnect-PnPOnline  
}

Remove-WebPartFromPages -SiteURL https://contoso.sharepoint.com -WebPartIds "News","0ec51ebc-4754-4ef4-a953-1a3adb4b4d8c" -Pages "home.aspx","pnp.aspx"

# More examples
<#
# Specific content type
Remove-WebPartFromPages -SiteURL https://contoso.sharepoint.com -WebPartIds "News" -ContentTypeId "0x0101009D1CB255DA764"

#>