param(
	[string]
	[Parameter()]
	$Cache = "nuget-packages",
	[string]
	[Parameter()]
	$Source = "solution.json",
	[switch]
	[Parameter()]
	$KeepSolution,
	[switch]
	[Parameter()]
	$SkipClean
)

$data = Get-Content -Raw -Path $Source | ConvertFrom-Json

$sln = "src/BuildCache"
if (Test-Path $sln) {
	Remove-Item $sln -Recurse -Force
}

#region Build-Solution

function Get-ProjectPath(
	[string] $sln,
	[string] $project
) {
	return Join-Path $sln $project
}

function Build-Project([psobject] $project, [string] $sln) {
	$output = Get-ProjectPath $sln $project.name

	& dotnet new $project.template -o $output
	& dotnet sln $sln add $output

	$project.dependencies | ForEach-Object {
		& dotnet add $output package $_
	}
}

function Build-Solution([psobject] $data, [string] $sln) {
	& dotnet new sln -o $sln

	$data | ForEach-Object {
		Build-Project $_ $sln
	}
}

Build-Solution $data $sln

#endregion

#region Build-Cache

function Initialize-Path([string] $path, [string] $type) {
	if (-not (Test-Path $path)) {
		New-Item -Path $path -ItemType $type -Force
	}
}

function Build-Cache([string] $cache, [string] $sln) {
	Initialize-Path $cache "Directory"
	& dotnet restore $sln --packages $cache
}

if (-not $SkipClean) {
	& dotnet nuget locals all --clear
}

Build-Cache $Cache $sln

if (-not $KeepSolution) {
	Remove-Item "src" -Recurse -Force
}

#endregion