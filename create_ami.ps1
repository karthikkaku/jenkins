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

# Generate a unique timestamp
$Timestamp = Get-Date -Format "yyyyMMddHHmmss"

# Create a unique AMI name by appending the timestamp to the base AMI name
$AMIName = "${BaseAMIName}_${Timestamp}"

# Rest of your AMI creation code
# ...

# Create an AMI from the specified EC2 instance using the AWS CLI
$AMIId = & $awsExecutable ec2 create-image --instance-id $InstanceID --name $AMIName --description $Description --output text

Write-Output "Creating AMI with ID: $AMIId and name: $AMIName"

# Wait for the AMI creation to complete using the AWS CLI
# ...

# Slack notification integration using AWS CLI
if ($amiStatus -eq "available") {
    Write-Output "AMI creation completed. AMI ID: $AMIId"
    $text = "$AMIId AMI Created Successfully"

    # Send a notification to Slack using AWS CLI
    & $awsExecutable lambda invoke --function-name "slackNotificationLambdaFunction" --payload "{ \"text\": \"$text\" }" --region us-east-1
} else {
    Write-Output "AMI creation failed or timed out."
}
