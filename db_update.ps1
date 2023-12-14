$server = "mydb.cqsjd7auvq0d.us-east-2.rds.amazonaws.com"
$database = "rdsdemo"
$username = "admin"
$password = "admin1234"

# New AMI ID
$NewAMIId = "ami-06475fa81c3e0ecd6"  # Replace with the actual AMI ID you obtained

# Construct the SQL update query
$updateSql = "UPDATE instance SET inst_id  = '$NewAMIId' WHERE ami_id = 1 ;"

# Reference the MySQL .NET Connector assembly
[Reflection.Assembly]::LoadFile("C:\Program Files (x86)\MySQL\MySQL Connector NET 8.2.0\MySql.Data.dll")

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
