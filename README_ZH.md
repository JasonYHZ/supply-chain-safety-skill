# Supply Chain Safety Skill 中文说明

[English README](README.md)

这是一个可复用的 agent skill 和全局安全约束，用来让 agent 在新增依赖、升级依赖、执行包管理器命令、处理 lockfile、引入构建插件或代码生成器时，按供应链安全流程工作。

它本身不是漏洞扫描器。它的作用是约束 agent 的行为：先检查包元数据，优先参考可信公开安全来源，在执行远程包代码前征求用户确认，保持 lockfile 可追溯，并在最终回复里说明残余风险。

## 覆盖场景

- 新增或升级第三方依赖。
- 执行 `npx`、`npm exec`、`pnpm dlx`、`yarn dlx`、`bunx`、`pipx` 等包 CLI。
- 审查 `package.json`、`pnpm-lock.yaml`、`package-lock.json`、`yarn.lock`、Python requirements、Go modules、Cargo lock 等依赖变更。
- 处理构建插件、代码生成器、native module、发布工具、CI/CD 工具。
- 使用 OSV、Socket、Snyk、GitHub Advisories、npm/PyPI metadata 和生态 advisory database 等可信来源检查包风险。
- 明确本地扫描器只是本机证据，不是权威漏洞库。

## 让你的 Agent 安装

你可以直接告诉你的 agent：

```text
请从下面这个仓库安装 supply-chain safety skill：
git@github.com:JasonYHZ/supply-chain-safety-skill.git

安装完成后，请把仓库里的 guardrail block 更新到我的全局 AGENTS.md 或 CLAUDE.md 中，让依赖变更、包执行、lockfile 变更时自动触发这个 skill。
```

如果你的 agent 可以执行 shell 命令：

```sh
git clone git@github.com:JasonYHZ/supply-chain-safety-skill.git
cd supply-chain-safety-skill
scripts/install.sh --agent codex
```

安装到 Claude：

```sh
scripts/install.sh --agent claude
```

同时安装到 Codex 和 Claude：

```sh
scripts/install.sh --agent both
```

## 手动安装

### Codex

复制 skill：

```sh
mkdir -p ~/.codex/skills
cp -R skills/supply-chain-safety ~/.codex/skills/supply-chain-safety
```

然后把下面文件里的 guardrail 内容追加到全局 `AGENTS.md`：

```text
templates/supply-chain-guardrail.md
```

目标文件：

```text
~/.codex/AGENTS.md
```

### Claude

复制 skill：

```sh
mkdir -p ~/.claude/skills
cp -R skills/supply-chain-safety ~/.claude/skills/supply-chain-safety
```

然后把下面文件里的 guardrail 内容追加到全局 `CLAUDE.md`：

```text
templates/supply-chain-guardrail.md
```

目标文件：

```text
~/.claude/CLAUDE.md
```

## 安装脚本行为

`scripts/install.sh` 会安装 skill，并默认更新对应 agent 的全局约束文件。

它会写入一个可重复更新的 managed block：

```text
<!-- supply-chain-safety-skill:start -->
<!-- supply-chain-safety-skill:end -->
```

重复执行安装脚本时，只会替换这段 managed block，不会覆盖文件里的其他内容。

不更新全局约束，只安装 skill：

```sh
scripts/install.sh --agent codex --no-guardrail
```

等价环境变量写法：

```sh
INSTALL_GUARDRAIL=0 scripts/install.sh --agent codex
```

自定义 agent home：

```sh
CODEX_HOME=/path/to/.codex scripts/install.sh --agent codex
CLAUDE_HOME=/path/to/.claude scripts/install.sh --agent claude
```

## 推荐给 Agent 的安装 Prompt

你可以把下面这段直接发给 agent：

```text
请安装这个 supply-chain safety skill：
git@github.com:JasonYHZ/supply-chain-safety-skill.git

要求：
- 把 skill 安装到我的 agent skills 目录。
- 把仓库里的 guardrail block 更新到我的全局 AGENTS.md 或 CLAUDE.md。
- 不要覆盖无关的已有指令。
- 保留 managed supply-chain-safety block 之外的所有原内容。
- 安装完成后，告诉我修改了哪些文件，并展示新增或更新的 guardrail block。
```

## 仓库结构

```text
skills/supply-chain-safety/SKILL.md
skills/supply-chain-safety/references/checklist.md
templates/supply-chain-guardrail.md
scripts/install.sh
```

## 安全原则

- 当第三方检查会发送包名、版本、manifest、lockfile 或依赖图时，agent 必须先获得用户确认。
- OSV、Socket、Snyk、GitHub Advisories、npm/PyPI metadata 和生态 advisory database 被视为可信外部信号。
- 本地扫描器只提供本机证据，例如 lockfile、cache/store 痕迹和 IOC 文件，不应被当成完整漏洞数据库。
- 执行未知包命令前必须询问用户，例如 `npx`、`pnpm dlx`、`npm exec`、`curl | sh` 或第三方 installer。
- 如果包有 `install`、`postinstall`、`prepare`、native binary、代码生成、CI/CD、凭证、云权限或非常新的发布版本，agent 必须先停下来让用户确认。

## Skill 的核心要求

安装后，当 agent 遇到依赖变更或包执行任务时，应该：

1. 说明为什么需要这个依赖，能否用标准库或现有依赖替代。
2. 判断它是 runtime、dev、build、test、CLI、codegen 还是 deploy tool。
3. 在安装或执行前检查包元数据、发布历史、维护者、license、仓库、安装脚本和可疑信号。
4. 优先查可信第三方来源，例如 OSV、Socket、Snyk、GitHub Advisories、npm/PyPI metadata。
5. 使用项目固定的包管理器和工具链，例如 `mise exec -- pnpm ...`。
6. 同步并提交 lockfile。
7. 在最终回复中说明依赖变更、lockfile 状态、第三方检查、本地检查和残余风险。
