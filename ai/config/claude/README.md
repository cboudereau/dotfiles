# Claude

Claude has the same issue as copilot since it does not check the input.

References:
 - [terminal config](https://code.claude.com/docs/en/terminal-config)
 - [plugins in the skills directory](https://code.claude.com/docs/en/plugins#develop-a-plugin-in-your-skills-directory)

This folder mirrors `~/.claude/`. Skills ship as the [ni plugin](skills/ni/README.md) under `skills/ni`, loaded automatically as `ni:<skill>`.

## install
```bash
rm -rf ~/.claude/skills   # remove renamed or deleted skills
cp -r ai/config/claude/{skills,settings.json,statusline-command.sh} ~/.claude/
```
