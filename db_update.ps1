param (
    [Parameter(Mandatory = $true)]
    [string]$AMIId
)

    # Update the database with the new AMI ID
    $server = "rdsdemo.clsi8fbjzmk6.us-east-1.rds.amazonaws.com"
    $database = "demo"
    $username = "admin"
    $password = "admin123"

    $NewAMIId = $AMIId

    $updateSql = "UPDATE instance SET inst_id = '$AMIId' WHERE ami_id = 1;"
    # Reference the MySQL .NET Connector assembly

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
