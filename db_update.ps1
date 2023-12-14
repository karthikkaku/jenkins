param (
    [Parameter(Mandatory = $true)]
    [string]$InstanceID,

    [Parameter(Mandatory = $true)]
    [string]$BaseAMIName,

    [Parameter(Mandatory = $true)]
    [string]$Description
)

#credentials to connect AWS
$accessKey = "AKIAY7SEYN2PFTKTB67I"
$secretKey = "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"

Set-AWSCredential -AccessKey $accessKey -SecretKey $secretKey
Set-DefaultAWSRegion -Region us-east-2

# Import the AWSPowerShell module
if (-not (Get-Module -Name AWSPowerShell -ErrorAction SilentlyContinue)) {
    Install-Module -Name AWSPowerShell -Force -Verbose
}
Import-Module AWSPowerShell

# Generate a unique timestamp
$Timestamp = Get-Date -Format "yyyyMMddHHmmss"

# Create a unique AMI name by appending the timestamp to the base AMI name
$AMIName = "${BaseAMIName}_${Timestamp}"

# Check if an AMI with the specified name already exists
$existingAmi = Get-EC2Image -Owners self -Filters @{Name = "name"; Values = $AMIName}

if ($existingAmi) {
    Write-Output "An AMI with the name '$AMIName' already exists (AMI ID: $($existingAmi.ImageId)). Please choose a different base AMI name."
    exit 0
}

# Create an AMI from the specified EC2 instance
$AMIParams = @{
    InstanceId = $InstanceID
    Name = $AMIName
    Description = $Description
}
$AMIId = New-EC2Image @AMIParams

Write-Output "Creating AMI with ID: $AMIId and name: $AMIName"

# Wait for the AMI creation to complete
Write-Output "Waiting for the AMI creation to complete..."
$amiStatus = "pending"
while ($amiStatus -eq "pending") {
    Start-Sleep -Seconds 30  # Wait for 30 seconds before checking again
    $ami = Get-EC2Image -ImageIds $AMIId
    $amiStatus = $ami.State
}

if ($amiStatus -eq "available") {
    Write-Output "AMI creation completed. AMI ID: $AMIId"
    $message = "AMI creation completed. AMI ID: $AMIId"
    Add-Content -Path "result.txt" -Value $message

    # Update the database with the new AMI ID
    $server = "database-1.clsi8fbjzmk6.us-east-1.rds.amazonaws.com"
    $database = "rdsdemo"
    $username = "admin"
    $password = "admin123"

    $NewAMIId = $AMIId
    $updateSql = "UPDATE instance SET inst_id = '$NewAMIId' WHERE ami_id = 1;"

    $connectionString = "Server=$server;Database=$database;User ID=$username;Password=$password;"
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection
    $connection.ConnectionString = $connectionString

    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = $updateSql

    $affectedRows = $command.ExecuteNonQuery()
    $connection.Close()

    if ($affectedRows -gt 0) {
        Write-Output "AMI ID updated in the database."
    } else {
        Write-Output "Update in the database failed."
    }

    # Send a notification to Slack
    $slackMessage = "AMI ID: $AMIId created and updated in the database."
    $body = @{ text = $slackMessage } | ConvertTo-Json
    Invoke-RestMethod -Uri "https://hooks.slack.com/services/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" -Method Post -ContentType "application/json" -Body $body
} else {
    Write-Output "AMI creation failed or timed out."
}
