## Supply Chain Safety

When adding, upgrading, auditing, or executing third-party packages, package-manager commands, CLIs, build plugins, code generators, native modules, or dependency lockfile changes, use the `supply-chain-safety` skill.

Hard rules:

- Do not run unknown `npx`, `npm exec`, `pnpm dlx`, `yarn dlx`, `bunx`, `pipx`, `curl | sh`, or installer scripts without explicit user approval.
- Before adding or executing a dependency, inspect package metadata, repository, release age, license, install scripts, maintainers, and known vulnerability or malware signals.
- Prefer trusted public sources for package risk: OSV, Socket, Snyk, GitHub Advisories, npm/PyPI metadata, and ecosystem advisory databases. Treat local scanners as machine evidence, not authoritative vulnerability databases.
- Do not send private package names, internal scopes, lockfiles, source code, full dependency graphs, or local reports to third-party services without user approval.
- Lockfiles must be committed or updated together with dependency changes.
- Prefer repo-pinned package managers and toolchains, such as `mise exec -- pnpm ...`, when a repo provides them.
- Use OSV, Socket, Snyk, or similar network checks only when the user accepts sending package names, versions, manifests, lockfiles, or dependency graphs to that service.
- Ask the user before adding packages with install/postinstall/prepare scripts, native binaries, code generators, CI/CD access, credential access, cloud access, or very recent releases.
- Final responses for dependency changes must include changed packages, lockfile status, third-party checks, local checks, and residual risk.
