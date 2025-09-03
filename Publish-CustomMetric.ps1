# This script sends a custom metric to Datadog v2 API from PowerShell.
# Tested on Windows 10 Pro (version 10.0.1945) with PSVersion 5.1 (Build 19041, Revision 5486)

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

    $currentTime = [int](Get-Date -date ((get-date).ToUniversalTime()) -UFormat %s) -Replace("[,\.]\d*", "")

    $body = @{
        "series" = @(
            @{
                "metric" = $MetricName
                "points" = @(
                    @{
                        "timestamp" = $currentTime
                        "value"     = $MetricValue
                    }
                )
                "type"  = 1                 # (1) count, (2) rate, (3) gauge
                "tags"  = $Tags             # optional parameter should be an array of tags
            }
        )
    }

    $jsonBody = $body | ConvertTo-Json -Depth 5 -Compress

    $response = Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $jsonBody

    Write-Host "Datadog response: $($response | ConvertTo-Json -Depth 5)"
}


# ----------------------------
# Example Usage:
# ----------------------------
# This sends a custom count metric called "my.custom.metric" with a value of 42
# and adds "env:test" + "version:1.0" + host as tags.

$randomNumber = Get-Random -Maximum 200

Send-DatadogMetric -MetricName "my.custom.metric" `
                   -MetricValue $randomNumber `
                   -Tags @("env:test","version:1.0", "host:$env:COMPUTERNAME")