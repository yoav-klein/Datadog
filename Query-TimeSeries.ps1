
. ./Environment.ps1

$headers = @{
    "DD-API-KEY"         = $api_key
    "DD-APPLICATION-KEY" = $app_key
    "Accept"       = "application/json"
}

function Query-TimeSeries {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Query,
        [Parameter(Mandatory=$true)]
        [int]$Duration
    )

    $currentTime = [int](Get-Date -date ((get-date).ToUniversalTime()) -UFormat %s) -Replace("[,\.]\d*", "")
    $to = $currentTime
    $from = $to - ($Duration * 60)
    $url = "$base_url/v1/query?from=$($from)&to=$($to)&query=$($Query)"
    
    $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
    Write-Host "Datadog response: $($response | ConvertTo-Json -Depth 5)"
}

$Query = "sum:my.custom.metric{*}.as_count().rollup(sum, 1)"
Query-TimeSeries $Query -Duration 5