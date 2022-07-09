function Build-Project([psobject] $project, [string] $sln) {
    $output = Join-Path $sln $project.name

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

function Build-Cache([string] $cache, [string] $sln) {
    if (-not (Test-Path $cache)) {
        New-Item -Path $cache -ItemType Directory -Force
    }

    & dotnet restore $sln --packages $cache
}
