param (
    [Parameter(Mandatory = $true)]
    [string]$AMIId
)

# Replace these variables with your AWS RDS endpoint, database name, username, and password
$server = "sqldb.clsi8fbjzmk6.us-east-1.rds.amazonaws.com"
$database = "sqldb"
$tableToCheck = "ami"
$username = "admin"
$password = "admin123"

# Build connection string
$connectionString = "Server=$server;Database=$database;Uid=$username;Pwd=$password;"

try {
    # Load MySQL assembly
    [System.Reflection.Assembly]::LoadFile("C:\Program Files (x86)\MySQL\MySQL Connector NET 8.2.0\MySql.Data.dll")

    # Create connection
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection
    $connection.ConnectionString = $connectionString

    $connection.Open()

    # Check if the database exists
    $checkDbQuery = "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = @database;"
    $command = $connection.CreateCommand()
    $command.CommandText = $checkDbQuery
    $command.Parameters.AddWithValue("@database", $database)
    
    $result = $command.ExecuteScalar()
    if ($result -eq $null) {
        Write-Output "Database '$database' does not exist. Creating..."

        # Create the database if it doesn't exist
        $createDbQuery = "CREATE DATABASE $database;"
        $command.CommandText = $createDbQuery
        $command.Parameters.Clear()
        $command.ExecuteNonQuery()

        Write-Output "Database '$database' created."
    } else {
        Write-Output "Database '$database' exists."
    }

    # Check if the table exists
    $checkTableQuery = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @database AND TABLE_NAME = @tableToCheck;"
    $command.CommandText = $checkTableQuery
    $command.Parameters.Clear() # Clear parameters before reuse
    $command.Parameters.AddWithValue("@database", $database)
    $command.Parameters.AddWithValue("@tableToCheck", $tableToCheck)

    $tableResult = $command.ExecuteScalar()

    if ($tableResult -eq $null) {
        Write-Output "Table '$tableToCheck' does not exist in database '$database'. Creating..."
        $createTableQuery = "CREATE TABLE $tableToCheck (
            id INT PRIMARY KEY AUTO_INCREMENT,
            column_name VARCHAR(255),
            ami_id VARCHAR(100)
        );"
        $command.CommandText = $createTableQuery
        $command.Parameters.Clear() # Clear parameters before reuse
        $command.ExecuteNonQuery()

        Write-Output "Table '$tableToCheck' created."
    } else {
        Write-Output "Table '$tableToCheck' exists in database '$database'. Inserting row..."

        # Insert a row into the table
        $insertQuery = "INSERT INTO $tableToCheck (column_name, ami_id) VALUES (@columnValue, @amiId);"
        $command.CommandText = $insertQuery
        $command.Parameters.Clear() # Clear parameters before reuse
        $command.Parameters.AddWithValue("@columnValue", "some_value")
        $command.Parameters.AddWithValue("@amiId", $AMIId)
        $command.ExecuteNonQuery()

        Write-Output "Row inserted into table '$tableToCheck'."

        # Retrieve the inserted data
        $selectQuery = "SELECT * FROM $tableToCheck;"
        $command.CommandText = $selectQuery
        $command.Parameters.Clear() # Clear parameters before reuse

        $dataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($command)
        $dataTable = New-Object System.Data.DataTable
        $dataAdapter.Fill($dataTable)

        # Log the retrieved data
        Write-Output "Data retrieved from table '$tableToCheck':"
        $dataTable | Format-Table -AutoSize

    }

    # Close the connection
    $connection.Close()
} catch {
    Write-Output "Error: $_.Exception.Message"
    $connection.Close()
}
