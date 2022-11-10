# Source: https://pnp.github.io/script-samples/spo-export-termstore-terms-to-csv/README.html?tabs=pnpps

###### Declare and Initialize Variables ######  

#site url
$url="Site admin site url"

#term store variables
$groups = @("Group 1","Group 2") # leave empty for exporting all groups

# data will be saved in same directory script was started from
$saveDir = (Resolve-path ".\")  
$currentTime= $(get-date).ToString("yyyyMMddHHmmss")  
$FilePath=".\TermStoreReport-"+$currentTime+".csv"  
Add-Content $FilePath "Term group name, Term group ID, Term set name, Term set ID, Term name, Term ID"
## Export List to CSV ##  
function ExportTerms
{  
    try  
    {  
        if($groups.Length -eq 0){
            $groups = @(Get-PnPTermGroup | ForEach-Object{ $_.Name })
        }
        # Loop through the term groups
        foreach ($termGroup in $groups) {
            try {
                $termGroupName = $termGroup
                Write-Host "Exporting terms from $termGroup"
                $termGroupObj = Get-PnPTermGroup -Identity $termGroupName -Includes TermSets
                foreach ($termSet in $termGroupObj.TermSets) {
                    $termSetObj = Get-PnPTermSet -Identity $termSet.Id -TermGroup $termGroupName -Includes Terms
                    foreach ($term in $termSetObj.terms) {
                        Add-Content $FilePath "$($termGroupObj.Name),$($termGroupObj.Id),$($termSetObj.Name),$($termSetObj.Id),$($term.Name),$($term.Id)"
                    }
                }
            }
            catch {
                Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            }
            
        }
     }  
     catch [Exception]  
     {  
        $ErrorMessage = $_.Exception.Message         
        Write-Host "Error: $ErrorMessage" -ForegroundColor Red          
     }  
}  
 
## Connect to SharePoint Online site  

Connect-PnPOnline -Url $Url -Interactive
 
## Call the Function  
ExportTerms
 
## Disconnect the context  

Disconnect-PnPOnline 