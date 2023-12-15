param (
    [Parameter(Mandatory = $true)]
    [string]$InstanceID,

    [Parameter(Mandatory = $true)]
    [string]$BaseAMIName,

    [Parameter(Mandatory = $true)]
    [string]$Description
)

# Your AWS credentials
$accessKey = "AKIAY7SEYN2PFTKTB67I"
$secretKey = "KtC6oL4WOFqvOFOENHdwVx8yQkE4sg/F7JNPHzcc"

# Set AWS credentials and region
Set-AWSCredential -AccessKey $accessKey -SecretKey $secretKey
Set-DefaultAWSRegion -Region "us-east-2"

# Generate a unique timestamp for the AMI name
$Timestamp = Get-Date -Format "yyyyMMddHHmmss"
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
    
    # Write the AMI ID to result.txt
    $message = "AMI creation completed. AMI ID: $AMIId"
    Add-Content -Path "result.txt" -Value $message

    # Update the database with the new AMI ID
    $server = "rdsdemo.clsi8fbjzmk6.us-east-1.rds.amazonaws.com"
    $database = "demo"
    $username = "admin"
    $password = "admin123"

    $NewAMIId = $AMIId

    $updateSql = "UPDATE instance SET inst_id = '$AMIId' WHERE ami_id = 1;"

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

    # Slack notification about AMI update in the database
    $slackMessage = "AMI ID updated in the database."
    $slackBody = @{
        text = $slackMessage
    } | ConvertTo-Json

    Invoke-RestMethod -Uri "https://hooks.slack.com/services/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" -Method Post -ContentType "application/json" -Body $slackBody
} else {
    Write-Output "Update in the database failed."
}
