
. ./Environment.ps1


$headers = @{
    "DD-API-KEY"         = $api_key
    "DD-APPLICATION-KEY" = $app_key
    "Content-Type"       = "application/json"
}

function Send-DatadogMetric {
    param(
        [Parameter(Mandatory=$true)]
        [string]$MetricName,

        [Parameter(Mandatory=$true)]
        [int]$MetricValue,

        [Parameter(Mandatory=$false)]
        [string[]]$Tags = @()
    )

    $url = "$base_url/v2/series"

    $currentTime = (Get-Date).ToUniversalTime()
    $unixTime = [int](Get-Date -date $currentTime -UFormat %s) -Replace("[,\.]\d*", "")

    $body = @{
        "series" = @(
            @{
                "metric" = $MetricName
                "points" = @(
                    @{
                        "timestamp" = $unixTime
                        "value"     = $MetricValue
                    }
                )
                "type"  = 3                # (1) count, (2) rate, (3) gauge
                "tags"  = $Tags             # optional parameter should be an array of tags
            }
        )
    }

    echo "$($currentTime): $($MetricValue)"
    

    $jsonBody = $body | ConvertTo-Json -Depth 5 -Compress

    $response = Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $jsonBody
    
    <# Write-Host "Datadog response: $($response | ConvertTo-Json -Depth 5)" #>
}

while($true) {
    Send-DatadogMetric -MetricName "yoav.test" -MetricValue $(Get-Random -Maximum 100)
    sleep 1
}