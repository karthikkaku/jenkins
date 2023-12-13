$awsCLIInstallerPath = "$env:TEMP\AWSCLIInstaller.msi"
$awsExecutable = Join-Path $env:ProgramFiles 'Amazon\AWSCLIV2\aws.exe'

# Check if AWS CLI is already installed or install it if not found
if (-not (Test-Path $awsExecutable)) {
    Write-Output "AWS CLI not found. Installing AWS CLI..."

    # Download AWS CLI installer MSI
    Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile $awsCLIInstallerPath

    # Install AWS CLI silently
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $awsCLIInstallerPath, "/qn" -Wait

    # Validate installation
    if (Test-Path $awsExecutable) {
        Write-Output "AWS CLI installed successfully."
    } else {
        Write-Output "Failed to install AWS CLI."
        exit 1  # Exit the script with an error code
    }
} else {
    Write-Output "AWS CLI already installed."
}


# Check AWS CLI version
$awsVersion = & $awsExecutable --version

Write-Output "AWS CLI installed. Version: $awsVersion"

# Parameters - Instance ID, Base AMI Name, and Description
$InstanceID = $args[0]
$BaseAMIName = $args[1]
$Description = $args[2]

Write-Output "$InstanceID $BaseAMIName $Description"


# Generate a unique timestamp
$Timestamp = Get-Date -Format "yyyyMMddHHmmss"

# Create a unique AMI name by appending the timestamp to the base AMI name
$AMIName = "${BaseAMIName}_${Timestamp}"

# Rest of your AMI creation code
# ...

# Create an AMI from the specified EC2 instance using the AWS CLI
$AMIId = & $awsExecutable ec2 create-image --instance-id $InstanceID --name $AMIName --description $Description --output text

Write-Output "Creating AMI with ID: $AMIId and name: $AMIName"

# Slack notification integration using AWS CLI
if ($amiStatus -eq "available") {
    Write-Output "AMI creation completed. AMI ID: $AMIId"
    $text = "$AMIId AMI Created Successfully"
} else {
    Write-Output "AMI creation failed or timed out."
}
