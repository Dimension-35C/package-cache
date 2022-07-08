# Package Cache

This project provides the ability to generate a NuGet Package cache based on a series of dependencies defined in JSON files. The generated cache can then be placed on a file share located on a network with no internet, and serve as a NuGet package feed.

All functionality is encapsulated in [Build-PackageCache.ps1](./Build-PackageCache.ps1)

> A more comprehensive description of this repository will follow. For now, know that you can specify dependencies to cache in any of the .json files located in [sources](./sources/). Core, Test, and Web are differentiated so that the cache can be built for all necessary project types. This will be enhanced / simplified in the future, but this is an initial effort.