<#	A very small library that contains minimal mysql interaction #>
[void][system.reflection.Assembly]::LoadFrom("$PSScriptRoot\MySql.Data.dll")

function New-MySqlCredentials {
	<#
		.SYNOPSIS
		creates a set of mysql credentials so they can easily be passed around
	#>
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
		[string]$Hostname,
		[Parameter(Mandatory=$true)]
		[string]$Database,
		[Parameter(Mandatory=$true)]
		[string]$User,
		[Parameter(Mandatory=$true)]
		[string]$Pwd
	)

	Process {
		New-Object -TypeName psobject -Property @{
			Hostname = $Hostname
			Database = $Database
			User = $User
			Pwd = $Pwd
		}
	}
}

function Get-MySqlResult {
	<#
		.SYNOPSIS
		Request data from a mysql database
	#>
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
		[PSObject]$MySQLCreds,
		[Parameter(Mandatory=$true)]
		[string]$query,
		[Parameter(Mandatory=$false)]
		[hashtable]$parameter = @{}
	)

	Process {
		try {
			$SqlConnection = New-Object MySql.Data.MySqlClient.MySqlConnection
			$SqlConnection.ConnectionString = "server=$($MySQLCreds.Hostname);" + 
				"Uid=$($MySQLCreds.User);" + 
				"Pwd=$($MySQLCreds.Pwd);" + 
				"database=$($MySQLCreds.Database);Convert Zero Datetime=True"
			$SqlConnection.Open()

			$SqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand
			$SqlCmd.CommandText = $query
			$SqlCmd.Connection = $SqlConnection
	
			foreach ($p in $parameter.GetEnumerator()) {
				$SqlCmd.Parameters.AddWithValue("@" + $p.Name, $p.Value) | Out-Null
			}
	
			$SqlAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter
			$SqlAdapter.SelectCommand = $SqlCmd
			$DataSet = New-Object System.Data.DataSet
			$null = $SqlAdapter.Fill($DataSet)    
	
			$DataSet.Tables[0] | Select-Object * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors
		}
		finally {
			$SqlConnection.Close()
		}
	}
}


function Invoke-MySql {
	<#
		.SYNOPSIS
		Invoke an sql query on mysql without result
	#>
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
		[PSObject]$MySQLCreds,
		[Parameter(Mandatory=$true)]
		[string]$query,
		[Parameter(Mandatory=$false)]
		[hashtable]$parameter = @{}
	)

	Process {
		try {
			$SqlConnection = New-Object MySql.Data.MySqlClient.MySqlConnection
			$SqlConnection.ConnectionString = "server=$($MySQLCreds.Hostname);" + 
				"Uid=$($MySQLCreds.User);" + 
				"Pwd=$($MySQLCreds.Pwd);" + 
				"database=$($MySQLCreds.Database);Convert Zero Datetime=True"
			$SqlConnection.Open()

			$SqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand
			$SqlCmd.CommandText = $query
			$SqlCmd.Connection = $SqlConnection
			$SqlCmd.CommandTimeout = 60000
	
			foreach ($p in $parameter.GetEnumerator()) {
				$SqlCmd.Parameters.AddWithValue("@" + $p.Name, $p.Value) | Out-Null
			}
	
			$SqlCmd.ExecuteNonQuery() | Out-Null
		}
		finally {
			$SqlConnection.Close()
		}
	}
}
