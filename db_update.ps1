$server = "database-1.clsi8fbjzmk6.us-east-1.rds.amazonaws.com"
$database = "rdsdemo"
$username = "admin"
$password = "admin123"

# New AMI ID
$NewAMIId = Get-Content -Path "result.txt" -Raw 

# Construct the SQL update query
$updateSql = "UPDATE instance SET inst_id  = '$NewAMIId' WHERE ami_id = 1 ;"

# Reference the MySQL .NET Connector assembly

# Create a database connection
$connectionString = "Server=$server;Database=$database;User ID=$username;Password=$password;"
$connection = New-Object MySql.Data.MySqlClient.MySqlConnection
$connection.ConnectionString = $connectionString

# Open the database connection
$connection.Open()

# Create a MySQL command
$command = $connection.CreateCommand()
$command.CommandText = $updateSql

# Execute the update query
$affectedRows = $command.ExecuteNonQuery()

# Close the database connection
$connection.Close()

# Check if the update was successful
if ($affectedRows -gt 0) {
    Write-Output "AMI ID updated in the database."
} else {
    Write-Output "Update in the database failed."
}
