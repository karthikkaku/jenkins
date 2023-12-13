# Function to check if AWS CLI is installed
function Check-AWSCLIInstallation {
    return (Test-Path (Join-Path $env:ProgramFiles 'Amazon\AWSCLI\aws.exe'))
}

# Function to install AWS CLI
function Install-AWSCLI {
    Write-Output "AWS CLI not found. Installing AWS CLI..."

    # Download AWS CLI installer
    $awsCLIInstaller = "$env:TEMP\AWSCLIV2.exe"
    Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.exe" -OutFile $awsCLIInstaller

    # Run AWS CLI installer silently
    Start-Process -Wait -FilePath $awsCLIInstaller -ArgumentList "/S" -NoNewWindow
}

# Check if AWS CLI is available
$awsExecutable = "C:\Program Files\Amazon\AWSCLI\aws.exe"
if (-not (Test-Path $awsExecutable)) {
    # AWS CLI not found, installing AWS CLI or use the correct path if installed elsewhere
    Write-Output "AWS CLI not found. Please install AWS CLI or provide the correct path."
    exit 1  # Exit the script with an error code
}

# Check AWS CLI version
$awsVersion = & $awsExecutable --version

Write-Output "AWS CLI installed. Version: $awsVersion"

# Parameters - Instance ID, Base AMI Name, and Description
$InstanceID = $args[0]
$BaseAMIName = $args[1]
$Description = $args[2]

Write-Output "Instance ID: $InstanceID"
Write-Output "BaseAMIName: $BaseAMIName"
Write-Output "Description: $Description"

# Set your Slack API token here
$SLACK_API_TOKEN = "xoxb-6304431362048-6320659208197-YqD4S8FA2leoPaceMnKOEM2m"

# Generate a unique timestamp
$Timestamp = Get-Date -Format "yyyyMMddHHmmss"

# Create a unique AMI name by appending the timestamp to the base AMI name
$AMIName = "${BaseAMIName}_${Timestamp}"

# Rest of your script to handle AMI creation and Slack notification
# Check if an AMI with the specified name already exists
$existingAmi = aws ec2 describe-images --owners self --filters "Name=name,Values=$AMIName" --query 'Images[*].ImageId' --output text

if ($existingAmi) {
    Write-Output "An AMI with the name '$AMIName' already exists (AMI ID: $existingAmi). Please choose a different base AMI name."
    exit 0
}

# Create an AMI from the specified EC2 instance
$AMIId = aws ec2 create-image --instance-id $InstanceID --name $AMIName --description $Description --output text

Write-Output "Creating AMI with ID: $AMIId and name: $AMIName"

# Wait for the AMI creation to complete
$amiStatus = "pending"
while ($amiStatus -eq "pending") {
    Start-Sleep -Seconds 30  # Wait for 30 seconds before checking again
    $ami = aws ec2 describe-images --image-ids $AMIId --query 'Images[*].State' --output text
    $amiStatus = $ami
}

if ($amiStatus -eq "available") {
    Write-Output "AMI creation completed. AMI ID: $AMIId"
    $text = "$AMIId AMI Created Successfully"
    Invoke-RestMethod -Uri "https://hooks.slack.com/services/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" -Method Post -Body (@{text = $text} | ConvertTo-Json) -ContentType "application/json"
} else {
    Write-Output "AMI creation failed or timed out."
}
