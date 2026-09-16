# .NET specifics

Load the [`dotnet-build`](../dotnet-build/SKILL.md) skill for the commands.

- Find the `.sln` first. With several, confirm which one to use before building.
- Determine .NET Framework versus .NET Core from the solution before choosing commands.
- Run all tests in the chosen solution before committing, not only the changed project.
- Prefer records and readonly structs for value objects; keep entities behind explicit invariants.
