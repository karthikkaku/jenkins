 param (
    [Parameter(Mandatory = $true)]
    [string]$NotificationText
)

Write-Output "NotificationText - $NotificationText."

if (-not [string]::IsNullOrEmpty($result)) {
    # Prepare JSON payload
    $body = @{
        text = "$NotificationText"
    } | ConvertTo-Json

    # Send a POST request to the Slack webhook URL
    Invoke-RestMethod -Uri "https://hooks.slack.com/services/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" -Method Post -ContentType "application/json" -Body $body
} else {
    Write-Output "The content of result.txt is empty or null."
}
