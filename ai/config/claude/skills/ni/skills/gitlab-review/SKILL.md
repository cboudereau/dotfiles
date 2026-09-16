---
name: gitlab-review
description: "Use when working with a GitLab merge request through the glab CLI: reading MR review comments or discussions, listing unresolved threads, posting replies or code suggestions on an MR, resolving threads, or checking glab auth. Also use when the user mentions glab, GitLab MR discussions, or GitLab suggestion blocks."
---
# GitLab Review

## When to use
- User asks to read comments or threads on a GitLab merge request
- User asks to post replies, code suggestions, or resolve threads on an MR
- User mentions `glab`, GitLab MR discussions, or unresolved threads
- User asks to set up or troubleshoot `glab`

## Overview

GitLab-specific tooling for the review flow. It provides the `glab` commands and API
calls; the flow itself is not here.

**REQUIRED BACKGROUND:** the [`review-conventions`](../review-conventions/SKILL.md) skill defines the flow (read -> preview ->
approve -> post + resolve), the preview format, the Disposition rules, and the red
flags. Load it first. Git rules (never push) are in the [`git-conventions`](../git-conventions/SKILL.md) skill.

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

In the preview, **File:line** is `new_path:new_line` and **Discussion** is the
eight-character id prefix.

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

Two writes per approved `reply + resolve` thread, in this order. A thread is not done
after the reply.

**1. Reply** inside the reviewer's own thread, which is the default choice:

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
not survive inline shell quoting. `--file`, `--reply` and `--unique` are mutually
exclusive, so a reply cannot carry `--unique`: to stay idempotent on a retry, re-read
the thread and skip the ones that already have your note.

**2. Resolve** the thread. `glab` has no resolve verb, so go through the API — the
discussion id is the same one `--reply` took:

```bash
glab api --method PUT "projects/<project-id>/merge_requests/<iid>/discussions/<discussion-id>?resolved=true"
```

Get `<project-id>` once with `glab repo view -F json --jq .id`, or use the URL-encoded
path (`d-edge%2F...`). Requires the full discussion id, not the eight-character prefix.

**3. Verify** before reporting, as the [`review-conventions`](../review-conventions/SKILL.md) skill requires:

```bash
glab mr note list <iid> -F json --jq '[.[] | {id, resolved: ([.notes[] | select(.system==false) | .resolved] | any)}]'
```

## Setup

`glab` lives at `~/.local/bin/glab`. Check auth with `glab auth status`. On failure,
tell the user to run `glab auth login --hostname gitlab.com --stdin` with a personal
access token scoped `api`; do not attempt to create or read tokens.
