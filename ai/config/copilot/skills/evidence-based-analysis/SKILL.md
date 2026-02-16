---
name: evidence-based-analysis
description: "Prevents hallucinations by requiring evidence-based analysis for all claims about the codebase. Use when analyzing code, writing documentation, explaining behavior, reviewing changes, debugging, or making any claim about how the code works. Always cite file and line numbers."
---

# Overview

You must verify every claim with concrete evidence from the codebase before stating it as fact. Never infer behavior without proof.

# When to use

This skill is always active. It applies to all analysis, documentation, and explanations.

# Instructions

## Core Rules

1. **No assumptions** - If you cannot find direct evidence (grep match, file content, explicit reference), do not state it as fact
2. **Show your work** - When making claims, cite the file and line number
3. **Distinguish facts from inferences** - If you must infer, explicitly say "I infer..." or "This appears to..." and explain why
4. **Verify references** - When you see something defined (function, script, variable), verify it's actually used before claiming it's part of the workflow
5. **Trace the full path** - For CI/CD pipelines, trace job → script → reference chain completely

## Verification Checklist

Before documenting any behavior:

- [ ] Did I find the definition? (where it's declared)
- [ ] Did I find the usage? (where it's called/referenced)
- [ ] Did I verify the connection? (the caller actually invokes it)
- [ ] Can I cite file:line for each claim?

## Language Rules

### DO say:
- "In `file.yml:42`, the job `build` calls..."
- "I found the script `.tag_deployment_branch` defined at line 27, but I cannot find any job that references it"
- "Based on lines 10-15 of `config.yml`, this appears to..."
- "I could not find evidence of X in the codebase"

### DO NOT say:
- "The pipeline automatically creates tags" (without showing which job does it)
- "This script is used for..." (without showing where it's called)
- "The system does X" (without citing evidence)

## When Uncertain

1. State what you found
2. State what you could not find
3. Ask the user if they have additional context
4. Never fill gaps with assumptions

## Documentation Tasks

When writing documentation:
1. Draft the content
2. For each claim, mentally check: "Can I cite where I found this?"
3. If no citation possible, either find evidence or remove/qualify the statement
4. Flag uncertain sections with "⚠️ Needs verification:" prefix

# Example

**Bad (hallucination risk):**
"Git tags are automatically created on production release"

**Good (evidence-based):**
"I found `.tag_deployment_branch` script in `ci.deploy.scripts.yml:27-34` that creates git tags, but I cannot find any job in the pipeline that calls this script. The tagging functionality appears to be unused."
