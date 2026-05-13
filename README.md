# Supply Chain Safety Skill

A reusable agent skill and global guardrail for safer dependency changes, package execution, lockfile handling, and supply-chain risk checks.

This is not a vulnerability scanner by itself. It teaches agents how to handle dependency risk: inspect metadata, prefer trusted public security sources, ask before executing remote package code, preserve lockfiles, and report residual risk clearly.

## What It Covers

- Adding or upgrading third-party dependencies.
- Running package CLIs such as `npx`, `npm exec`, `pnpm dlx`, `yarn dlx`, `bunx`, or `pipx`.
- Reviewing lockfile and package-manager changes.
- Handling build plugins, code generators, native modules, release tools, and CI/CD tooling.
- Choosing trusted checks such as OSV, Socket, Snyk, GitHub Advisories, npm/PyPI metadata, and ecosystem advisory databases.
- Treating local scanners as machine evidence, not authoritative vulnerability databases.

## Install With Your Agent

Tell your agent:

```text
Install this supply-chain safety skill from:
git@github.com:JasonYHZ/supply-chain-safety-skill.git

After installation, update my global AGENTS.md or CLAUDE.md with the guardrail block from the repo so dependency changes trigger the skill automatically.
```

Or, if your agent can run shell commands:

```sh
git clone git@github.com:JasonYHZ/supply-chain-safety-skill.git
cd supply-chain-safety-skill
scripts/install.sh --agent codex
```

For Claude:

```sh
scripts/install.sh --agent claude
```

For both Codex and Claude:

```sh
scripts/install.sh --agent both
```

## Manual Installation

### Codex

Copy the skill:

```sh
mkdir -p ~/.codex/skills
cp -R skills/supply-chain-safety ~/.codex/skills/supply-chain-safety
```

Then append the guardrail block from:

```text
templates/supply-chain-guardrail.md
```

to:

```text
~/.codex/AGENTS.md
```

### Claude

Copy the skill:

```sh
mkdir -p ~/.claude/skills
cp -R skills/supply-chain-safety ~/.claude/skills/supply-chain-safety
```

Then append the guardrail block from:

```text
templates/supply-chain-guardrail.md
```

to:

```text
~/.claude/CLAUDE.md
```

## Installer Behavior

`scripts/install.sh` installs the skill and, by default, updates the global agent guardrail file.

It writes a managed block delimited by:

```text
<!-- supply-chain-safety-skill:start -->
<!-- supply-chain-safety-skill:end -->
```

Re-running the installer replaces only that managed block.

Disable guardrail updates:

```sh
scripts/install.sh --agent codex --no-guardrail
```

Equivalent environment form:

```sh
INSTALL_GUARDRAIL=0 scripts/install.sh --agent codex
```

Custom agent homes:

```sh
CODEX_HOME=/path/to/.codex scripts/install.sh --agent codex
CLAUDE_HOME=/path/to/.claude scripts/install.sh --agent claude
```

## Recommended Agent Prompt

Use this prompt when asking an agent to install it:

```text
Please install the supply-chain safety skill from git@github.com:JasonYHZ/supply-chain-safety-skill.git.

Requirements:
- Install the skill into my agent skills directory.
- Update my global AGENTS.md or CLAUDE.md with the repo's guardrail block.
- Do not overwrite unrelated existing instructions.
- Preserve any existing content outside the managed supply-chain-safety block.
- After installation, show me the files changed and the exact guardrail block added.
```

## Repository Layout

```text
skills/supply-chain-safety/SKILL.md
skills/supply-chain-safety/references/checklist.md
templates/supply-chain-guardrail.md
scripts/install.sh
```

## Security Notes

- The skill requires user approval before third-party network checks that send package names, versions, manifests, lockfiles, or dependency graphs.
- OSV, Socket, Snyk, GitHub Advisories, npm/PyPI metadata, and ecosystem advisory databases are treated as trusted external signals.
- Local scanners are treated as local machine evidence, useful for lockfiles, cache/store traces, and IOC files, but not as a complete vulnerability database.
- Agents must ask before running unknown package execution commands such as `npx`, `pnpm dlx`, or installer scripts.
