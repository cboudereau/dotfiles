# ni

**ni** stands for natural intelligence, as opposed to artificial. Say it *nickel* (French: spot on, good enough) or *nice* (UK/US). Either way, it is the human staying in the loop.

ni is a Claude Code plugin that lives in the skills directory. Copied to `~/.claude/skills/ni/`, Claude loads it on every session as `ni@skills-dir` with no marketplace or install step. Its `skills/` folder is also the single source of skills for Copilot CLI, Cursor, and Gemini CLI.

## Layout
| Path | Purpose |
|---|---|
| `.claude-plugin/plugin.json` | Plugin manifest, name `ni` |
| `commands/` | Slash commands, invoked as `/ni:<command>` |
| `scripts/` | Hook scripts behind the terse reply mode |
| `skills/` | The skills, invoked as `ni:<skill>` |

## Install
See [claude/README.md](../../README.md). It is a plain copy of the `claude` folder into `~/.claude/`.

## Develop
```bash
claude plugin validate ./ai/config/claude/skills/ni
claude --plugin-dir ./ai/config/claude/skills/ni   # load from the working tree
```

## Terse mode
ni injects a terse reply ruleset at session start and reminds Claude every turn, so replies stay short even after context compaction. Adapted from [caveman](https://github.com/juliusbrussee/caveman) (MIT), with two levels only.

| Level | Effect |
|---|---|
| `lite` | Default. No filler, hedging, preamble, or recap. Full sentences kept. |
| `full` | Also drops articles, allows fragments. |
| `off` | Nothing injected. |

Switch with `/ni:terse lite|full|off`. The level persists in `~/.claude/ni/terse`. Commits, docs, MR text, and security warnings always stay in normal prose.

## Skills
| Skill | Use when |
|---|---|
| `ni:terse` | The terse ruleset itself, for reference or manual invocation |
| `ni:software-engineer` | Implementing, fixing, or refactoring with the plan, test, implement, commit workflow |
| `ni:tdd` | Writing tests first, red-green-refactor |
| `ni:plan` | Multi-session work with a durable workspace, design doc, and ADRs |
| `ni:git-conventions` | Any git operation, commit messages, MR or PR descriptions |
| `ni:review-conventions` | Reviewing a change or answering reviewer comments |
| `ni:gitlab-review` | Reading and replying to GitLab MR threads with glab |
| `ni:dotnet-build` | Building, testing, or measuring coverage on .NET |
| `ni:rust-build` | Building, testing, linting, or measuring coverage on Rust |
| `ni:evidence-based-analysis` | Any claim about the codebase, cited by file and line |

Run `/ni:help` inside Claude for the same list.
