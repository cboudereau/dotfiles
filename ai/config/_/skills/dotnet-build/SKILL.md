---
name: dotnet-build
description: "Build and test .NET projects using dotnet CLI or MSBuild. Use when the user asks to build, compile, run tests, or debug a .NET, C#, F#, .NET Core, or .NET Framework project, or when working with .sln, .csproj, or .fsproj files."
---
# Build and test .NET

## When to use
- User asks to "build", "compile", or "rebuild" a `.sln` or `.csproj` project
- User asks to run .NET tests or unit tests
- User mentions "msbuild", "dotnet build", "dotnet test", or "nuget restore"
- User references a `.sln`, `.csproj`, or `.fsproj` file
- User mentions "CI" in context of a .NET solution

## Decision logic
1. Find the `.sln` file the user wants to build
2. Read the `.sln` file to determine the project type:
   - If project GUIDs use `{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}` (classic C#) and Visual Studio format without SDK-style projects → use **.NET Framework** workflow
   - If projects use SDK-style format (`<Project Sdk="Microsoft.NET.Sdk">`) or target `netcoreapp`/`net5+`/`net6+`/`net7+`/`net8+` → use **.NET Core** workflow
3. Use the appropriate build and test commands below

## .NET Framework
### setup
user defined function to build .NET Framework
```bash
# windows msbuild path
MSBUILD_FW_TOOL_PATH="/mnt/c/Program Files/Microsoft Visual Studio/18/Professional"

# .NET Framework build function: restore nuget from the .nuget project folder then run msbuild from windows
# usage: msbuildfw solution.sln
msbuildfw() {
  local MSBUILD="${MSBUILD_FW_TOOL_PATH}/MSBuild/Current/Bin/amd64/MSBuild.exe"
  local NUGET=".nuget/NuGet.exe"
  local SLN="${1:?usage: msbuildfw solution.sln}"
  "$NUGET" restore -ConfigFile .nuget/NuGet.Config "$SLN" && "$MSBUILD" /t:Clean,Build "$SLN"
}

# .NET Framework test unit runner function to run tests with vstest console host.
# usage: vstestfw assembly.Tests.dll
vstestfw() {
  local ASSEMBLY_PATH="${1:?usage: vstestfw assembly.Tests.dll}"
  local TEST="${MSBUILD_FW_TOOL_PATH}/Common7/IDE/Extensions/TestPlatform/vstest.console.exe"
  "$TEST" /Parallel /collect:"Code Coverage;Format=Cobertura" "${ASSEMBLY_PATH}"
}
```

### build
```bash
msbuildfw solution.sln
```

### test
```bash
vstestfw assembly.Tests.dll
```

## .NET Core
### build

```bash
dotnet.exe build solution.sln
```

### test
```bash
dotnet.exe test solution.sln --filter "Category!=Integration" \
  /p:CollectCoverage=true \
  /p:CoverletOutputFormat=cobertura \
  /p:ExcludeByAttribute="GeneratedCodeAttribute"
```

