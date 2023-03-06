
# Sourcce: https://pnp.github.io/script-samples/graph-openai-get-page-summary/README.html
# A script to get summary of a SharePoint site page using GPT-3.5 turbo
# The script accepts the following parameters:
# SiteAbsoluteUrl, PageName

Param(
    [Parameter(Mandatory = $true)]
    [string]$SiteAbsoluteUrl,
    [Parameter(Mandatory = $true)]
    [string]$PageName
)

# function to connect to Microsoft Graph
# See https://learn.microsoft.com/en-us/powershell/microsoftgraph/get-started?view=graph-powershell-1.0 for more details
function Connect-Graph {

    Write-Host "Connecting to Microsoft Graph.";
    
    # Select Microsoft Graph beta endpoint
    Select-MgProfile -Name "beta"
    # Connect to Microsoft Graph
    Connect-MgGraph -Scopes "Sites.Read.All"
}

function Get-SiteId {
    
    Write-Host "Getting site Id.";

    # remove trailing slash from site absolute url
    $SiteAbsoluteUrl = $SiteAbsoluteUrl.TrimEnd("/");

    # SiteAbsoluteUrl is of the form https://<tenant>.sharepoint.com/sites/<site>
    # We need to get a string of the form <tenant>.sharepoint.com:/sites/<site>
    
    $siteUri = New-Object System.Uri($SiteAbsoluteUrl);
    $siteId = $siteUri.Host + ":" + $siteUri.AbsolutePath;

    $site = Get-MgSite -SiteId $siteId;

    if($null -eq $site) {
        Write-Host "Error: Unable to get site Id. Check if the site exists." -ForegroundColor Red;
        Exit;
    }

    return $site.Id;
}

# function to get page content
function Get-PageContent {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SiteId
    )

    Write-Host "Getting page content.";

    $pageContent = "";

    # Get content from all the text web parts in the page
    $page = Get-MgSitePage -SiteId $SiteId -Filter "name eq '$PageName'" `
        -ExpandProperty "webparts(`$filter=(isof('microsoft.graph.textWebPart')))";

    if($null -eq $page) {
        Write-Host "Error: Unable to get page content. Check if the page exists." -ForegroundColor Red;
        Exit;
    }

    $page.WebParts | ForEach-Object { 
        $pageContent += $_.AdditionalProperties.innerHtml 
    }

    $pageContent = $pageContent -replace "<[^>]+>", "";
    $pageContent = $pageContent -replace "&nbsp;", " ";
    $pageContent = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Convert([System.Text.Encoding]::UTF8, [System.Text.Encoding]::GetEncoding(1252), [System.Text.Encoding]::UTF8.GetBytes($pageContent)));

    return $pageContent;
}

# function to get page summary using openai api

function Get-PageSummary {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PageContent
    )

    $openai_api_key = "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
    $openai_api_endpoint = "https://api.openai.com/v1/chat/completions";

    $data = @{}
    $data["model"] = "gpt-3.5-turbo";
    $data["messages"] = @(@{});
    $data["messages"][0]["role"] = "user";
    $messageContent = "1 short sentence summary in English, French and Spanish of this: {{content}}. Output format: 'English: 'xxx' `n French: 'xxx' `n Spanish: 'xxx'";
    $data["messages"][0]["content"] = $messageContent.Replace("{{content}}", $PageContent);
    
    $headers = @{
        "Content-Type"  = "application/json"
        "Authorization" = "Bearer " + $openai_api_key
    }

    Write-Host "Calling OpenAI API to get page summary.";

    $response = Invoke-WebRequest -Method Post -Uri $openai_api_endpoint -Headers $headers -Body ($data | ConvertTo-Json);

    if ($response -and $response.StatusCode -eq 200) {
        $result = $response.Content | ConvertFrom-Json | Select-Object -ExpandProperty choices | Select-Object -ExpandProperty message | Select-Object -ExpandProperty content;
    } else {
        $result = $null;
    }

    return $result;
}


# main
Connect-Graph;
$siteId = Get-SiteId;
$pageContent = Get-PageContent -SiteId $siteId;
$pageSummary = Get-PageSummary -PageContent $pageContent;

If($null -eq $pageSummary) {
    Write-Host "Error: Unable to get page summary." -ForegroundColor Red;
    Exit;
}

Write-Host "### Page summary ###"
Write-Host $pageSummary -ForegroundColor Green
Write-Host "`n ### End of page summary ###"

# end of script

<#

Example usage: .\get-page-summary-using-gpt-3.5-turbo.ps1 -SiteAbsoluteUrl "https://contoso.sharepoint.com/sites/teamsite" -PageName "UK-News-1.aspx"
Welcome To Microsoft Graph!
Getting site Id.
Getting page content.
Calling OpenAI API to get page summary.
### Page summary ###

English: UK and EU are close to revising post-Brexit trade rules for Northern Ireland, but a deal is not yet guaranteed, says Irish Prime Minister Leo Varadkar.
French: Le Royaume-Uni et l'UE sont proches de réviser les règles commerciales post-Brexit pour l'Irlande du Nord, mais un accord n'est pas encore garanti, a déclaré le Premier ministre irlandais Leo Varadkar.
Spanish: El Reino Unido y la UE están cerca de revisar las normas comerciales posteriores al Brexit para Irlanda del Norte, pero aún no se garantiza el acuerdo, dice el primer ministro irlandés Leo Varadkar.

 ### End of page summary ###

#>
