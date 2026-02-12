# dotnet

.NET was initially created for windows plaform only (there was "unofficial support with Mono") but now, with .NET Core, it becomes easy to get cross platform project.

Some legacy project still support the old .NET Framework which requires specific dotnet tools installed on Windows. This is why it is important to start analyzing the kind of project.

For .NET Framework, use the [required tools](./fw/msbuild.sh) but for .NET / .NET Core projects, use the `dotnet.exe` / `dotnet` commands depending the dotnet tools platform.