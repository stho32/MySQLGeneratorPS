Set-Location $PSScriptRoot
. .\library\MySQLTools.ps1

$SourceDb = New-MySqlCredentials -Hostname "..." -Database "..." -User "..." -Pwd "..."
$TargetDirectory = "C:\Projekte\VPADB\"
$TemplateDirectory = Join-Path $PSScriptRoot "Template"
$Token = "VPA"
$ModuleName = "VPAPs"

$Tables = Get-MySqlResult -MySQLCreds $SourceDb -query "SHOW TABLES;"

function PathToTemplateFile([string]$TemplateFile) {
    $sourcePath = Join-Path $TemplateDirectory $TemplateFile
    return $sourcePath
}

function PathToTargetFile([string]$NewFilename) {
    $targetPath = Join-Path $TargetDirectory $NewFilename 
    return $targetPath
}

function CopyToTarget([string] $TemplateFile, [string] $NewFilename) {
    $sourcePath = Join-Path $TemplateDirectory $TemplateFile
    $targetPath = Join-Path $TargetDirectory $NewFilename 

    $targetPathDirectories = Split-Path $targetPath -Parent
    if (-not (Test-Path $targetPathDirectories)) {
        New-Item -Path $targetPathDirectories -Force -ItemType Directory
    }
    Copy-Item -Path $sourcePath -Destination $targetPath
}

CopyToTarget -TemplateFile "GenericModule.psm1" "$ModuleName`.psm1"
CopyToTarget -TemplateFile "library" "library"
CopyToTarget -TemplateFile "library\MySQLTools.ps1" "library\MySQLTools.ps1"
CopyToTarget -TemplateFile "library\MySql.Data.dll" "library\MySql.Data.dll"

$propertyName = $Tables | Get-Member -MemberType NoteProperty

$Tables | Foreach-Object {
    $table = $_ | Select-Object -ExpandProperty $propertyName.name

    $tableDirectory = Join-Path $TargetDirectory $table
    New-Item -Path $tableDirectory -Force -ItemType Directory

    $templateGet = (Get-Content (PathToTemplateFile -TemplateFile "Get-Template.ps1") -Raw)
    $templateGet = $templateGet.Replace("#Tablename#", $table)
    $templateGet = $templateGet.Replace("#TOKEN#", $Token)
    $templateGet | Set-Content (PathToTargetFile -NewFilename "$table\Get-$Token$Table`.ps1")
}
