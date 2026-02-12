---
name: dotnet-build
description: .NET build and test
---
# Build and test .NET
## Overview

1. Analyse project type (.NET Framework / .NET Core)
2. Use the appropriate tool

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

