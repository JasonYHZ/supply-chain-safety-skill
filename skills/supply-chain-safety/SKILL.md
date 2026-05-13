---
name: supply-chain-safety
description: Use when adding, upgrading, auditing, or executing third-party packages, package-manager commands, CLIs, build plugins, code generators, native modules, or dependency lockfile changes.
---

# Supply Chain Safety

## Core rule

Treat dependency changes and one-off package execution as a security-sensitive operation. Prefer public, trusted vulnerability and package-intelligence sources for package risk, and use local scans only as machine evidence.

## Must use when

- Adding or upgrading npm, pnpm, Yarn, Bun, Python, Go, Rust, Java, or other third-party dependencies.
- Running `npx`, `npm exec`, `pnpm dlx`, `yarn dlx`, `bunx`, `pipx`, `curl | sh`, installer scripts, CLIs, build plugins, code generators, native modules, or release/deploy tools.
- Reviewing dependency diffs, lockfile changes, or package-manager audit output.
- A package can access credentials, source code, CI/CD, registries, cloud accounts, Git, SSH, browsers, filesystems, or network.

## Hard stops

Ask the user before proceeding if any of these are true:

- The package has `install`, `postinstall`, `preinstall`, `prepare`, binary download, native build, codegen, or credential/cloud/Git/SSH access behavior.
- The package/version is very new, ownership recently changed, has low adoption, unusual maintainer history, or looks typo-squatted.
- `npx`, `pnpm dlx`, `npm exec`, `curl | sh`, or a third-party installer would execute unreviewed remote code.
- OSV, Socket, Snyk, GitHub Advisories, npm advisories, or the local scanner reports malware, compromise, credential exfiltration, high/critical vulnerabilities, or suspicious package behavior.
- The command would send private/internal package names, lockfiles, source, or dependency graphs to a third-party service without user approval.

## Required workflow

1. Justify the dependency: explain why existing code, standard library, or current dependencies are insufficient.
2. Classify risk: runtime vs dev/build/test; library vs CLI; install-time scripts; native/binary; network/file/env/credential access.
3. Inspect package metadata before installation or execution.
4. Check trusted third-party sources first: OSV, Socket, Snyk or GitHub Advisories where available. Local tools are additional evidence, not authoritative.
5. Install using the repo's pinned package manager and update lockfiles. Avoid global tools unless explicitly requested.
6. Run security checks after the change. Use a trusted local scanner only when one is already available in the environment or the user approves installing/running it.
7. Final response must include dependency changes, lockfile status, third-party checks, local checks, and residual risk.

## Local scanner role

Use a trusted local scanner, if one is available in the current environment, as evidence for lockfiles, package-manager stores, cache traces, and IOC files. Do not present it as a complete vulnerability database.

Example local check shape after dependency changes:

```sh
<local-supply-chain-scanner> --path . --stores=false
```

Only add a network-backed option, such as OSV, after confirming the user accepts sending package names and versions to that service:

```sh
<local-supply-chain-scanner> --path . --stores=false --osv
```

## Detailed references

For concrete package-manager commands, third-party source selection, and report templates, read `references/checklist.md`.
