# Exceptions

One row per rule this repository cannot meet yet. The reason and the revisit date
are required. The shared `standard` job reads this file.

| Rule | Reason | Revisit |
| --- | --- | --- |
| `ci/coverage` | Not measurable by the shared coverage workflow, in part. The setup code is about 930 lines of PowerShell and about 820 lines of bash. The suite runs two PowerShell scripts, `agent-vault/with-secrets.ps1` and `apply-tools.ps1`, and some bash, but no test runs the rest. The Node modules the suite imports are measurable, but the shared line gate does not measure the setup scripts. | 2027-05-31 |
| `C7.3` | The suite is eight `node:test` files and Node runs it. A `bun:test` port fails on the test context's `t.after` hook and on the platform skips the PowerShell and shell probes rely on; the port is its own change rather than a toolchain swap. Bun formats and lints. There is no `typecheck` recipe because the repository has no TypeScript. | 2027-05-31 |
| `C7.4` | The scripts are `.mjs` run by Node, not Bun TypeScript. The 26 modules and their tests are a large migration, so it is its own change. The 18 PowerShell files run on Windows targets (`apply-tools.ps1`, `setup-ops` helpers, the local-model lifecycle) and stay. The 10 bash files cover the macOS and WSL paths, and one Python `sitecustomize.py` is an interpreter hook TypeScript cannot provide. | 2027-05-31 |
