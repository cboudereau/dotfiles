#! /bin/sh
# windows msbuild path
MSBUILD_FW_TOOL_PATH="/mnt/c/Program Files/Microsoft Visual Studio/18/Professional"

# .NET Framework build function: restore nuget from the .nuget project folder then run msbuild from windows
# usage: msbuildfw solution.sln
function msbuildfw() {
  local MSBUILD="${MSBUILD_FW_TOOL_PATH}/MSBuild/Current/Bin/amd64/MSBuild.exe"
  local NUGET=".nuget/NuGet.exe"
  local SLN=$1
  "$NUGET" restore -ConfigFile .nuget/NuGet.Config $SLN
  "$MSBUILD" /t:Clean,Build $SLN
}

# .NET Framework test unit runner function to run tests with vstest console host.
# usage: vstestfw assembly.Tests.dll
function vstestfw() {
  local ASSEMBLY_PATH=$1
  local TEST="${MSBUILD_FW_TOOL_PATH}/Common7/IDE/Extensions/TestPlatform/vstest.console.exe"
  "$TEST" /Parallel /collect:"Code Coverage;Format=Cobertura" ${ASSEMBLY_PATH}
}