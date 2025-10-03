---
layout: default
title: Tooling & Workflow
nav_order: 5
---

# Tooling & Workflow

## CLI Commands

```bash
julia --project=. -e "using DripLangCompiler; DripLangCompiler.CLI.main(ARGS)"
# or
julia bin/drip.jl run examples/hello.drip
```

| Command | Description |
|---------|-------------|
| `compile <file>` | Tokenize and lower the program without executing it. |
| `run <file> [--entry name]` | Compile then execute the chosen entry function (defaults to `main`). |
| `repl` | Launch an interactive DripLang REPL with persistent session state. |

Flags:

- `--module-name Name` - override the generated module name.
- `--no-precompile` - skip Julia method precompilation for faster iteration.
- `--entry name` - specify a different entry function when using `run`.
- `--version`, `--help` - introspect the CLI.

## Programmatic API

```julia
using DripLangCompiler

compiled = compile_file("examples/hello.drip")
Runtime.run(compiled; entrypoint=:main)
```

`Runtime.compile_string` accepts keyword arguments to reuse modules, pick module names, or capture the last evaluated value (useful for REPL tooling).

## Testing & Continuous Integration

Run the full suite locally:

```bash
julia --project=. test/runtests.jl
```

The suite covers:

- Keyword translation in the lexer
- Parser integration through `Meta.parseall`
- Runtime evaluation and entrypoint resolution
- DripStd helpers and their availability from DripLang programs

The **CI** workflow (`.github/workflows/ci.yml`) mirrors these checks across Linux, macOS, and Windows on every push and pull request, plus a CLI smoke test.

## Building Standalone Bundles

Use `scripts/build_app.jl` to compile a self-contained DripLang CLI with PackageCompiler:

```bash
julia scripts/build_app.jl
```

Environment overrides:

- `DRIP_BUILD_OUTPUT` - destination directory (default `build/`)
- `DRIP_BUILD_FORCE` - set to `false` to skip overwriting existing builds

The **Build Apps** workflow runs the same script on tagged releases (`v*`) and publishes tar/zip artifacts for Linux, macOS, and Windows.

## Release Workflow

1. Update project versions (`Project.toml`, `stdlib/DripStd/Project.toml`).
2. Commit changes and run `julia --project=. test/runtests.jl`.
3. Tag the release (`git tag vX.Y.Z && git push origin vX.Y.Z`).
4. Wait for the **Build Apps** workflow to finish, then attach its artifacts to a GitHub Release if desired.
5. Publish release notes summarizing compiler, stdlib, and documentation changes.

## Documentation Deployment

The `.github/workflows/pages.yml` pipeline publishes the `docs/` folder to GitHub Pages on every push to `main`. The deployed URL is exposed in the workflow summary under the `github-pages` environment.

Extend the docs with tutorials, API references, or ecosystem guides as the language grows.
