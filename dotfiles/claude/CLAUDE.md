# CLAUDE.md

## Default posture

For any non-trivial task, run the `go` skill (`/general:go`): converge on an approach with me, execute it, then validate the result. Non-trivial means multiple files, an ambiguous approach, any risk, or a request framed as a goal rather than an exact instruction. Skip it for lookups, single obvious edits, and direct "run X" or "read Y" asks. "just do it" from me skips the loop.

`AGENT-STANDARD.md` in the `general` plugin is the standing standard for how I want you to work. `go` loads it; read it yourself when you are not running the loop.

## Secrets

`op` is signed in to 1Password with a service account, so it never prompts. The fields of the `Environment` item in the `Agent` vault are already exported when the session starts, so those variables are simply set: use them, do not re-read them. If one is empty the startup resolve failed, so treat it as missing rather than as a real empty value.

Everything else in the vault is a plain read, with `op item list --vault Agent` to see what is there:

```bash
op read "op://Agent/<item>/<field>"
```

To add a variable, add a field to the `Environment` item. Its label is the variable name, and no code changes.

## FOSSA work

FOSSA work has its own plugin. Start with the `fossa:standard` skill, which carries the domain standard and points at the sibling skills holding the detail: Jira, databases, repos, observability, production access, and vulns.
