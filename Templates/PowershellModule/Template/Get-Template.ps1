function Get-#TOKEN##Tablename# {
    <#
        .SYNOPSIS
        Gets the #Tablename# contents
        .EXAMPLE
        Get-#TOKEN##Tablename#
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [PSObject]$MySQLCreds
    )
        
    process {
        $sql = "SELECT * FROM #Tablename#"

        Get-MySqlResult -MySQLCreds $MySQLCreds -query $sql
    }
}