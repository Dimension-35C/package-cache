param(
	[string]
	[Parameter()]
	$cache = "nuget-packages",
	[string]
	[Parameter()]
	$sources = "sources",
	[string]
	[Parameter()]
	$testTemplate = "xunit"
)

function Initialize-Path([string] $path, [string] $type) {
	if (-not (Test-Path $path)) {
		New-Item -Path $path -ItemType $type -Force
	}
}

function Initialize-Solution(
	[string] $sln
) {
	& dotnet new sln -o $sln
}

function Get-ProjectPath(
	[string] $sln,
	[string] $project
) {
	return Join-Path $sln "$sln.$project"
}

function Build-Cache(
	[string] $template,
	[string] $sln,
	[string] $project,
	[string] $source
) {
	$output = Get-ProjectPath $sln $project
	& dotnet new $template -o $output
	& dotnet sln $sln add $output

	$data = Get-Content -Raw -Path $source | ConvertFrom-Json

	$data | ForEach-Object {
		& dotnet add $output package $_
	}
}

Initialize-Path $cache "Directory"

$coreFile = Join-Path $sources "core.json"
$testFile = Join-Path $sources "test.json"
$webFile = Join-Path $sources "web.json"

& dotnet nuget locals all --clear

$sln = "BuildCache"
Initialize-Solution $sln

Build-Cache "classlib" $sln "Core" $coreFile
Build-Cache $testTemplate $sln "Test" $testFile
Build-Cache "webapi" $sln "Web" $webFile

& dotnet restore $sln --packages $cache

Remove-Item $sln -Recurse -Force
