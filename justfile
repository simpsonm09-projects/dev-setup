# Cross-platform task runner for humans and agents. `just --list` shows every
# recipe. Keep each recipe a thin call to a portable tool or a script under
# scripts/. See https://github.com/simpsonm09-projects/repo-standard/blob/main/docs/task-runner.md
set windows-shell := ["powershell.exe", "-NoLogo", "-NoProfile", "-Command"]

# List the recipes.
default:
    @just --list

# Install the pinned tools.
install:
    mise install

# Format the JavaScript with Bun.
fmt *files:
    mise exec -- node scripts/fmt.mjs {{files}}

# Check the JavaScript formatting with Bun.
fmt-check:
    mise exec -- bun fmt --check "scripts/**/*.mjs" "services/**/*.mjs"

# Lint the JavaScript, through Bun with an oxlint fallback. The shared lint
# workflow runs flint over the non-JavaScript files.
lint *files:
    mise exec -- bun scripts/lint.ts

# Run the AI-slop gate.
aislop:
    npx --yes aislop@0.16.1 ci

# Build the workspace: clone the roster and install the config.
workspace *args:
    mise exec -- node scripts/workspace.mjs {{args}}

# Print the read-only LiteLLM gateway preflight plan and change nothing.
gateway-plan *args:
    mise exec -- node services/litellm/plan.mjs {{args}}

# Run offline checks for the opt-in local Pi model lifecycle helper.
local-model-check:
    mise exec -- node --test --test-concurrency=1 scripts/local-model.test.mjs

# Run the named synthetic verification cases for the supervised public command.
local-model-verify-test:
    mise exec -- node --test --test-concurrency=1 --test-name-pattern="supervised lifecycle|public lifecycle run" scripts/local-model.test.mjs

# Check the workspace wiring without cloning anything.
test:
    mise exec -- node scripts/workspace.mjs
    mise exec -- node --test --test-concurrency=1 scripts/workspace.test.mjs
    mise exec -- node scripts/check-worktreeinclude.mjs
    mise exec -- node scripts/check-secret-consumers.mjs
    mise exec -- node --test --test-concurrency=1 scripts/secret-consumers.test.mjs
    mise exec -- node --test --test-concurrency=1 scripts/litellm.test.mjs
    mise exec -- node --test --test-concurrency=1 scripts/secret-copies.test.mjs
    mise exec -- node --test --test-concurrency=1 scripts/tools.test.mjs
    mise exec -- node --test --test-concurrency=1 scripts/setup-ops.test.mjs
    mise exec -- node --test --test-concurrency=1 scripts/lib/yaml.test.mjs
    mise exec -- node --test --test-concurrency=1 scripts/with-secrets.test.mjs

# Copy the ignored secrets bootstrap template once. Existing files are preserved.
secrets-init:
    mise exec -- node scripts/agent-vault/with-secrets.mjs secrets-init

# Print this host's tool install plan and change nothing.
tools:
    mise exec -- node scripts/tools.mjs plan

# Regenerate the per-platform artifacts from tools.yaml.
tools-render:
    mise exec -- node scripts/tools.mjs render

# Validate tools.yaml and fail when a generated artifact is stale.
tools-check:
    mise exec -- node scripts/tools.mjs check

# Print the agent tool set and change nothing.
tools-ai:
    mise exec -- node scripts/tools.mjs ai

# Validate tools.yaml and fail when an agent artifact is stale.
tools-ai-check:
    mise exec -- node scripts/tools.mjs ai-check

# Install the machine tools. Windows drives winget then WSL; macOS uses brew.
tools-apply:
    {{ if os_family() == "windows" { "pwsh -File scripts/apply-tools.ps1 apply" } else { "bash scripts/apply-tools.sh apply" } }}

# Preview or apply the shared Zed settings snapshot (pass -Apply to write).
apply-settings *args:
    mise exec -- node scripts/setup-ops.mjs apply-settings {{args}}

# Audit or install the winget app set (pass -Install to install).
install-apps *args:
    mise exec -- node scripts/setup-ops.mjs install-apps {{args}}

# Preview or apply the shared Noctty (Ghostty) config (pass -Apply to write).
apply-noctty *args:
    mise exec -- node scripts/setup-ops.mjs apply-noctty {{args}}

# Preview or add Defender exclusions for the workspace and WSL dir (pass -Apply from an elevated shell).
add-defender-exclusions *args:
    mise exec -- node scripts/setup-ops.mjs add-defender-exclusions {{args}}

# Report this machine's storage profile.
machine-profile *args:
    mise exec -- node scripts/setup-ops.mjs machine-profile {{args}}

# Benchmark small- and large-file I/O on the Windows mount against ext4.
test-wsl-perf *args:
    mise exec -- node scripts/setup-ops.mjs test-wsl-perf {{args}}

# Retired compatibility command. Use with-secrets for one command.
import-secrets *args:
    mise exec -- node scripts/setup-ops.mjs import-secrets {{args}}

# Set the local Git identity in each sibling repository.
configure-git-identity *args:
    mise exec -- node scripts/setup-ops.mjs configure-git-identity {{args}}

# Preview or publish the private GitHub repositories (pass --publish).
publish-repos *args:
    mise exec -- node scripts/setup-ops.mjs publish-repos {{args}}

# Audit or install the WSL base packages (pass --install).
bootstrap *args:
    mise exec -- node scripts/setup-ops.mjs bootstrap {{args}}

# Audit or install Docker Engine inside WSL (pass --install).
install-docker-engine *args:
    mise exec -- node scripts/setup-ops.mjs install-docker-engine {{args}}

# Install Bun in WSL under ~/.bun.
install-bun *args:
    mise exec -- node scripts/setup-ops.mjs install-bun {{args}}

# Retired compatibility command. Use with-secrets for one command.
load-secrets *args:
    mise exec -- node scripts/setup-ops.mjs load-secrets {{args}}

# Audit or delete old OpenCode sessions in the WSL store (pass --apply).
cleanup-sessions *args:
    mise exec -- node scripts/setup-ops.mjs cleanup-sessions {{args}}

# Collect this host's workspace environment snapshot (pass -Write or --write to write).
snapshot *args:
    mise exec -- node scripts/setup-ops.mjs snapshot {{args}}

# Everything CI requires.
check: fmt-check lint test

# Historical alias for `check`, kept for the support template.
verify: check

# Install the shared Lefthook hooks and assert the merged jobs (C7.8).
hooks:
    mise exec -- node scripts/hooks.ts

# Check the .agents/skills tree and its .claude/skills links.
agent-files:
    mise exec -- node scripts/agent-files.mjs

# Staged secret scan (C7.10).
secrets-staged:
    mise exec -- gitleaks git --staged --redact --no-banner

# Reject env files, private keys, kubeconfigs and files over 5 MB (C7.10).
forbidden-files *files:
    mise exec -- node scripts/forbidden-files.ts {{files}}

# actionlint and zizmor over the given workflows, or every workflow (C7.10).
workflows *files:
    {{ if files == "" { "mise exec -- actionlint" } else { "mise exec -- actionlint -- " + files } }}
    {{ if files == "" { "mise exec -- zizmor --quiet .github/workflows" } else { "mise exec -- zizmor --quiet " + files } }}

# shellcheck over the given scripts; nothing to do when none are given (C7.10).
shellcheck *files:
    {{ if files == "" { "echo shellcheck: no files to check" } else { "mise exec -- shellcheck -- " + files } }}

# Advisory Conventional Commit check (C2.4); never fails the commit (C7.10).
commit-msg file:
    mise exec -- node scripts/commit-msg.ts {{quote(file)}}

# Read the pushed refs from stdin, refuse main, and scan the range (C7.10).
hook-pre-push:
    mise exec -- node scripts/git-hook.ts pre-push

# Fast pre-push subset, under 30 seconds (C7.10).
pre-push-check:
    just fmt-check
    just lint
    just tools-check

# Refresh locked dependencies when a manifest changed (C7.10).
deps-refresh *files:
    {{ if files == "" { "mise exec -- node scripts/deps-refresh.ts mise.toml" } else { "mise exec -- node scripts/deps-refresh.ts " + files } }}

# Owner hook: fail when this checkout cannot sign commits (C2.7).
signing-check:
    mise exec -- node scripts/signing-check.mjs

# Prune remote-tracking refs and delete local branches merged into main.
prune:
    mise exec -- node scripts/prune.mjs
