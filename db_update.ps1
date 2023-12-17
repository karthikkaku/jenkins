param (
    [Parameter(Mandatory = $true)]
    [string]$AMIId
)

# Replace these variables with your AWS RDS endpoint, database name, username, and password
$server = "rdsdemo.clsi8fbjzmk6.us-east-1.rds.amazonaws.com"
$database = "demo"
$username = "admin"
$password = "admin123"

# Construct the SQL query
$query = "UPDATE instance SET inst_id = '$AMIId' WHERE ami_id = 1;"

# Build connection string
$connectionString = "Server=$server;Database=$database;User ID=$username;Password=$password;"

# Create connection
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

try {
    # Open the connection
    $connection.Open()

    # Create command
    $command = $connection.CreateCommand()
    $command.CommandText = $query

    # Execute the query
    $result = $command.ExecuteReader()

    # Check if the query was executed successfully
    if ($result.HasRows) {
        Write-Output "SQL query executed successfully!"
        # Process the result set if needed
    } else {
        Write-Output "SQL query returned no results."
    }

    # Close the connection
    $connection.Close()
} catch {
    Write-Output "Error executing SQL query: $_"
    $connection.Close()
}
