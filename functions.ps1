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

function Initialize-Path([string] $path, [string] $type) {
    if (-not (Test-Path $path)) {
        New-Item -Path $path -ItemType $type -Force
    }
}

function Build-Cache([string] $cache, [string] $sln) {
    Initialize-Path $cache "Directory"
    & dotnet restore $sln --packages $cache
}
