param (
    [Parameter(Mandatory = $true)]
    [string]$AMIId
)

$databaseName = "demo"
$username = "admin"
$password = "admin123"
$server = "rdsdemo.clsi8fbjzmk6.us-east-1.rds.amazonaws.com"
$region = "us-east-1"

# Define the SQL query to perform operations on your RDS instance
$query = "UPDATE instance SET inst_id = '$AMIId' WHERE ami_id = 1;"

# Set AWS credentials (replace with your own)
$accessKey = "AKIAY7SEYN2PFTKTB67I"
$secretKey = "KtC6oL4WOFqvOFOENHdwVx8yQkE4sg/F7JNPHzcc"

# Set AWS credentials and region
Set-AWSCredential -AccessKey $accessKey -SecretKey $secretKey -StoreAs "default"
Set-DefaultAWSRegion -Region $region

try {
    # Execute SQL query on RDS instance
    $result = Invoke-RdsCommand -Region $region -DBInstanceIdentifier $dbInstanceIdentifier -Region $region -SelectSql $query -ProfileName "default"

    # Check if the query was successful
    if ($result -ne $null) {
        Write-Output "SQL query executed successfully!"
        # Process the $result variable if needed
    } else {
        Write-Output "SQL query returned no results."
    }
} catch {
    Write-Output "Error executing SQL query: $_"
}
