# Claude

Claude has the same issue as copilot since it does not check the input.

References:
 - [terminal config](https://code.claude.com/docs/en/terminal-config)
 - [plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)

This folder mirrors `~/.claude/`. Skills ship as the [ni plugin](https://github.com/itsaspacestation/natural-intelligence), installed from the [itsaspacestation marketplace](https://github.com/itsaspacestation/claude-marketplace) and loaded as `ni:<skill>`.

## install
```bash
cp ai/config/claude/{settings.json,statusline-command.sh} ~/.claude/
```

`settings.json` declares the marketplace and enables `ni@itsaspacestation`. Claude prompts to install it on the next start. To install by hand:
```
/plugin marketplace add itsaspacestation/claude-marketplace
/plugin install ni@itsaspacestation
```
