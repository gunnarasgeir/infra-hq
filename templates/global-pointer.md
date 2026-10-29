# Global pointer

Append the block below to each agent's global instructions file (see `docs/onboarding.md`, Phase 6). Replace `<REPO>` with the absolute path of this repo on this machine (e.g. `~/code/infra-hq`) and `<NAME>` with the user's name.

For **Claude Code** and **Gemini CLI**, keep the `@<REPO>/AGENTS.md` line: it imports the full rules. For **Codex** and agents without imports, delete that line; the text tells the agent to read the file itself.

```markdown
# <NAME>'s infrastructure (applies in every repo)

My servers, domains, DNS, hosting and other services are documented and managed from the infra-hq repo at `<REPO>`. Its rules apply everywhere, also when you are opened in another repo.

@<REPO>/AGENTS.md

- Before any work that touches infrastructure (DNS, hosting, deploys, servers, databases, env vars, access), read `<REPO>/AGENTS.md` if it is not already loaded, and `<REPO>/docs/infrastructure.md`.
- Paths like `docs/infrastructure.md`, `services/` and `scripts/` refer to `<REPO>`, not the current repo.
- Run `git -C <REPO> pull` before reading or changing docs there.
- If you change or learn something about the infrastructure, update `<REPO>` and commit and push there, not in the current repo.
- The current repo's own instructions apply to its code.
```
