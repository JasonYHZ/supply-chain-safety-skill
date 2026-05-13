# Supply Chain Safety Checklist

## Dependency intake questions

- Why is this dependency needed?
- Is it runtime, dev, build, test, CLI, codegen, or deploy tooling?
- Can existing code, standard library, or an existing dependency solve it?
- Does it run code during install or build?
- Does it download binaries, compile native code, or execute remote scripts?
- Does it need filesystem, env, token, registry, Git, SSH, cloud, browser, or CI/CD access?

## Trusted third-party checks

Use the strongest applicable public source before relying on local heuristics.

- OSV: broad public vulnerability and malicious-package database. Good default for npm/PyPI/Go/Rust/Maven ecosystems.
- Socket: package behavior and supply-chain intelligence, especially useful for npm/PyPI package risk, capabilities, malware, typo-squats, install scripts, and maintainer signals.
- Snyk: project-level SCA and fix guidance. Use when the user already accepts Snyk auth/data sharing or the repo already uses Snyk.
- GitHub Advisories: useful for GitHub-hosted packages and repo advisories.
- npm package metadata: useful for scripts, publish time, maintainers, repository, dist-tags, and tarball metadata.

Do not send private package names, internal scopes, lockfiles, source code, or full dependency graphs to third-party services without user approval.

## npm / pnpm metadata checks

Before installing:

```sh
npm view <package> name version license repository homepage bugs dist-tags time maintainers scripts dependencies optionalDependencies peerDependencies bin --json
```

For a specific version:

```sh
npm view <package>@<version> name version license repository time maintainers scripts dependencies optionalDependencies peerDependencies bin dist --json
```

Red flags:

- `preinstall`, `install`, `postinstall`, or `prepare` scripts.
- `bin` CLI entry points that will be executed with `npx`, `pnpm dlx`, or `npm exec`.
- Version published in the last 24-72 hours for a security-sensitive package.
- New maintainer, repo mismatch, missing repository, renamed package, or unusual dist-tags.
- Dependencies on shell, downloader, credential, crypto-wallet, browser, or filesystem-heavy packages without clear need.

Install with repo-pinned tooling. For pnpm projects:

```sh
pnpm add <package>@<version>
pnpm install --frozen-lockfile
```

If the repo uses `mise`, prefer:

```sh
mise exec -- pnpm add <package>@<version>
mise exec -- pnpm install --frozen-lockfile
```

## Python checks

Before installing:

```sh
python -m pip index versions <package>
python -m pip install --dry-run <package>  # only if dry-run is supported in the environment
```

Check PyPI project metadata in a browser or trusted API when risk matters. Watch for build backends, native extensions, generated code, typosquatting, and very new releases.

If the repo uses `uv`, prefer repo-pinned commands:

```sh
uv pip compile pyproject.toml
uv pip sync requirements.txt
```

## Go checks

Inspect module and versions:

```sh
go list -m -versions <module>
go list -m -json <module>@<version>
```

Check public advisories:

```sh
govulncheck ./...
```

Watch for modules that run code generation, invoke shell tools, or fetch binaries during builds.

## Rust checks

Inspect crate metadata and advisories:

```sh
cargo search <crate>
cargo info <crate>
cargo audit
```

Watch for build scripts (`build.rs`), native compilation, binary downloads, and proc macros.

## Java / Gradle / Maven checks

Prefer repository-pinned build tools:

```sh
./gradlew dependencies
./gradlew dependencyInsight --dependency <artifact>
```

Check Maven Central, GitHub Advisories, OSV, and Snyk when the dependency affects runtime or build plugins.

## Local checks after dependency changes

Run the local scanner:

```sh
/Users/jasonyu/workspace/Tools/supply-chain-scan/supply-chain-scan --path . --stores=false
```

If the user accepts OSV upload of package names and versions:

```sh
/Users/jasonyu/workspace/Tools/supply-chain-scan/supply-chain-scan --path . --stores=false --osv
```

Use `--osv-all` only after explicit approval because it sends every discovered npm/PyPI package name and version to OSV.

## Lockfile rules

- Node projects must commit the relevant lockfile: `pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`, or `bun.lock`.
- Do not update lockfiles unrelated to the requested dependency unless the package manager requires it.
- For application repos, preserve the repo's existing version range style unless the package is security-sensitive.
- For security-sensitive dependencies, CLIs, build tools, native modules, and code generators, prefer exact versions.
- CI should use frozen or locked installs where available.

## Final response template

```text
Dependency changes:
- Added/changed: <name>@<version> (<runtime/dev/build/test/cli>)
- Reason: <why needed>
- Lockfile: <updated/not changed/not applicable>
- Metadata checked: <license/repo/scripts/release age/maintainers summary>
- Third-party checks: <OSV/Socket/Snyk/GitHub Advisories/npm audit result>
- Local checks: <supply-chain-scan result and command>
- Residual risk: <none known / specific caveat / user approval obtained>
```
