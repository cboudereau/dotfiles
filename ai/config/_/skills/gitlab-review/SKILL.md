---
name: gitlab-review
description: "Read GitLab merge request review comments and answer them with code suggestions using the glab CLI. Use when the user asks to read MR comments, check review feedback, see what reviewers said, address or reply to review threads, post code suggestions on a merge request, or prepare a markdown plan from review comments. Also use when the user mentions glab, GitLab MR discussions, or unresolved threads."
---
# GitLab Review

## When to use
- User asks what reviewers said, or to read comments on an MR
- User asks to address, answer, or fix review feedback
- User asks to post code suggestions on a merge request
- User asks for a plan built from review comments
- User mentions `glab`, MR discussions, threads, or unresolved comments

## Overview

Read review discussions from GitLab with `glab`, turn them into a markdown
preview of proposed code suggestions, and only post to GitLab after the user
approves the preview.

The flow is always: **read -> preview -> approve -> post**. Never post first.

For first time code review, just do the usual code review.

For any code review, confirm skills used before.

## Rules

1. Always preview suggestions and wait for explicit approval before any write to GitLab.
2. Never resolve, unresolve, approve, merge, close, update, or delete anything. Those are the user's calls.
3. Never `git push`. See the `git-conventions` skill.
4. Quote the reviewer's comment verbatim in the preview. Do not paraphrase feedback.
5. Read the actual file around the referenced line before proposing a suggestion. Never suggest code from the comment text alone.
6. If a comment is unclear or technically questionable, say so in the preview instead of complying.
7. Write the preview to the session scratchpad by default. Write it into the repository only when the user asks.
8. One suggestion per discussion thread. Do not bundle unrelated changes into one note.

## Reading the review

Find the merge request. With no id, `glab` uses the current branch's MR.

```bash
glab mr list --reviewer=@me            # MRs waiting on me
glab mr list --author=@me              # my own MRs
glab mr view <iid> --unresolved        # human-readable open threads
```

Get structured discussions, which is what to work from:

```bash
# All unresolved diff comments with file, line, author, body and discussion id
glab mr note list <iid> -F json --state unresolved --type diff \
  --jq '.[] | {id, notes: [.notes[] | {author: .author.username, body,
        file: .position.new_path, line: .position.new_line,
        old_line: .position.old_line}]}'

glab mr note list <iid> -F json --state unresolved --type general   # non-diff comments
glab mr note list <iid> --file <path>                               # threads on one file
```

Keep the full `id` of each discussion: it is what `--reply` targets. Human-readable
output truncates it to the first eight characters, which `--reply` also accepts.

For diff context:

```bash
glab mr diff <iid>
glab mr view <iid> -F json --jq '.diff_refs'   # base_sha, head_sha, start_sha
```

## Preview format

For the live preview, be concise.

In case of a markdown output is asked, create one section per unresolved thread to
`<scratchpad>/mr-<iid>-suggestions.md`:

````markdown
## 1. src/Domain/Booking.cs:42 - @reviewer  [discussion: abc12345]

> Verbatim reviewer comment.

**Assessment:** what the comment is actually asking, and whether it holds.

**Current code** (src/Domain/Booking.cs:40-44):
```csharp
<actual lines read from the file>
```

**Proposed reply:**
```suggestion:-0+0
<replacement for line 42>
```
````

End the file with a short **Not addressed** list for anything skipped, with the reason.

Then ask the user which numbered items to post. Post only those.

## Suggestion syntax

GitLab applies a fenced `suggestion` block when the note is attached to the diff.
The range is relative to the commented line:

- `suggestion:-0+0` replaces the commented line only
- `suggestion:-1+2` replaces one line above through two lines below

Rules:
- The block content is the final code, with the file's real indentation, and no diff markers.
- Suggestions work on diff notes only. A general MR comment cannot carry an applicable suggestion.
- A reply inside a diff thread can carry a suggestion; it applies to that thread's line.

## Posting after approval

Reply inside the reviewer's own thread, which is the default choice:

```bash
glab mr note create <iid> --reply <discussion-id> -m "$(cat body.md)"
```

Start a new inline thread when there is no existing discussion on that line:

```bash
glab mr note create <iid> --file src/Domain/Booking.cs --line 42 -m "$(cat body.md)"
glab mr note create <iid> --file src/Domain/Booking.cs --line 40:44 -m "$(cat body.md)"  # range
glab mr note create <iid> --file src/Domain/Booking.cs --old-line 42 -m "..."            # removed line
```

Write the body to a file first with a heredoc, because fenced blocks and backticks do
not survive inline shell quoting. Add `--unique` to avoid duplicate posts on a retry.

Report the posted note ids back to the user, and list the threads left untouched.

## Setup

`glab` lives at `~/.local/bin/glab`. Check auth with `glab auth status`. On failure,
tell the user to run `glab auth login --hostname gitlab.com --stdin` with a personal
access token scoped `api`; do not attempt to create or read tokens.
