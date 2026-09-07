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

Read review discussions from GitLab with `glab`, turn them into a table
preview of proposed code suggestions, and only write to GitLab after the user
approves the preview.

The flow is always: **read -> preview -> approve -> post + resolve**. Never write first.

One approval covers the whole write. The preview states, per thread, both the reply
and whether that thread gets resolved; the user approves once; posting then does both
in the same pass. Never come back to ask about resolving after posting the replies.

For first time code review, just do the usual code review.

For any code review, confirm skills used before.

## Rules

1. Always preview suggestions and wait for explicit approval before any write to GitLab.
2. Resolve every approved thread whose preview **Disposition** said `reply + resolve`. This
   is required, not optional, and happens in the same pass as the reply — see
   "Posting after approval". Never unresolve, approve, merge, close, or delete anything:
   those stay the user's calls.
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

Note the comments may live on an **earlier** MR while the fix lives in a follow-up MR.
Reply and resolve on the MR that carries the thread, not the one that carries the code.

## Preview format

For the live preview, be concise: one row per thread, two tables.

**Replies** to existing reviewer threads, which is the main case:

```markdown
| # | File:line | Discussion | Reviewer comment (verbatim) | Reply | Suggestion | Resolve? |
|---|---|---|---|---|---|---|
| 1 | src/Domain/Booking.cs:42 | abc12345 | "Verbatim reviewer comment." | Agreed, null check added | `-0+0` `if (booking is null) return NotFound();` | yes |
| 2 | src/Api/Handler.cs:17 | def67890 | "Verbatim reviewer comment." | Fixed, test still to add | `-1+2` one-line summary | no - test missing |
| 3 | general | 0123abcd | "Verbatim reviewer comment." | Question back to reviewer | none | no - needs @user |
```

**New comments** on lines with no existing thread:

```markdown
| # | File:line | Comment | Suggestion |
|---|---|---|---|
| 4 | src/Domain/Booking.cs:58 | Same null check as thread 1 applies here | `-0+0` one-line summary |
```

End with **Not addressed:** item, reason.

Column rules:
- **File:line** is `new_path:new_line`, or `general` for a non-diff thread.
- **Discussion** is the eight-character id prefix; keep the full id for the write.
- **Reviewer comment** is quoted verbatim, trimmed with `...` only when long.
- **Suggestion** is the range plus the replacement when it fits one line, otherwise a summary; the full fenced block goes in the markdown file or the note body.
- **Resolve?** is `yes` for `reply + resolve`, or `no - reason` for `reply only` and `leave open`. It maps to the Disposition below.

Every thread in the preview carries a **Disposition**, whatever the output format.
It is a required field with exactly one of three values:

| Disposition | Meaning | Write on approval |
|---|---|---|
| `reply + resolve` | The comment is answered and the ask is done | reply, then resolve |
| `reply only` | Answered, but something real is still outstanding — say what | reply, leave open |
| `leave open` | Needs the user, another person, or a decision — say who or what | nothing |

`reply + resolve` is the normal case for a comment whose ask has landed. Reaching for
`reply only` to stay safe leaves the user to close threads by hand, which is the work
this skill exists to remove.

In case of a markdown output is asked, create one section per unresolved thread to
`<scratchpad>/mr-<iid>-suggestions.md`:

````markdown
## 1. src/Domain/Booking.cs:42 - @reviewer  [discussion: abc12345]

> Verbatim reviewer comment.

**Assessment:** what the comment is actually asking, and whether it holds.

**Disposition:** reply + resolve

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

Then ask one question: which numbered items to write, taking the previewed dispositions
as read. Write only those, and resolve exactly the approved `reply + resolve` ones.
If the user narrows or overrides a disposition in their answer, theirs wins.

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

**Then verify and report**, in one message: the posted note ids, which threads are now
resolved, and which stay open with the reason from their disposition.

```bash
glab mr note list <iid> -F json --jq '[.[] | {id, resolved: ([.notes[] | select(.system==false) | .resolved] | any)}]'
```

## Red flags - the write is not finished

- Replies posted, resolve left for the user
- "Resolving is the user's call" — it was, at preview time, and they answered
- A second question about resolving after the replies are already up
- Every thread previewed as `reply only` with no outstanding item named
- Reporting note ids without saying which threads are resolved

**All of these mean: go back and resolve the approved threads now.**

## Setup

`glab` lives at `~/.local/bin/glab`. Check auth with `glab auth status`. On failure,
tell the user to run `glab auth login --hostname gitlab.com --stdin` with a personal
access token scoped `api`; do not attempt to create or read tokens.
