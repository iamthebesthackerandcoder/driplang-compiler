# DripLang Compiler

DripLang replaces Julia's reserved words with Gen Z slang without sacrificing multiple dispatch or JIT performance. The compiler is written in Julia and lowers `.drip` sources directly into Julia IR before evaluation.

## Highlights

- Slang keyword remapping (`flex` -> `function`, `yeet` -> `end`, ...)
- Lexer + parser built on Tokenize.jl and `Meta.parseall`
- Semantic analysis that records exports, typed signatures, and module identities
- Runtime harness with optional method precompilation and a REPL
- DripStd standard library packaged under `stdlib/`
- GitHub Actions pipelines for CI, release builds, and documentation deployment

## Quick Start

```bash
julia --project=. -e "using Pkg; Pkg.instantiate()"
```

Run the sample program:

```bash
julia --project=. -e "using DripLangCompiler; DripLangCompiler.CLI.main([\"run\", \"examples/hello.drip\"])"
```

Or use the lightweight wrapper:

```bash
julia bin/drip.jl run examples/hello.drip
```

Launch the REPL:

```bash
julia bin/drip.jl repl
```

## Building Standalone Apps

The repository ships with `scripts/build_app.jl`, powered by PackageCompiler, to create native application bundles:

```bash
julia scripts/build_app.jl
```

Artifacts land in `build/` by default. Override `DRIP_BUILD_OUTPUT` or `DRIP_BUILD_APP_NAME` to customize the output path and executable name. The GitHub Actions **Build Apps** workflow runs the same script on Linux, macOS, and Windows and publishes tar/zip bundles for tagged releases (`v*`).

## DripStd Standard Library

`plug DripStd` from any DripLang file to access helper modules for basics, collections, math, and debugging. The package lives in `stdlib/DripStd` and can be extended like any Julia package.

## Testing & CI

```bash
julia --project=. test/runtests.jl
```

The suite covers lexing, parsing, runtime evaluation, and standard library availability. A cross-platform **CI** workflow runs the tests and a CLI smoke check on every push and pull request across Linux, macOS, and Windows.

## Documentation

GitHub Pages deployment is automated via `.github/workflows/pages.yml`. The site in `docs/` hosts:

- [Getting Started](docs/getting-started.md)
- [Language Reference](docs/language-reference.md)
- [Standard Library](docs/stdlib.md)
- [Tooling & Workflow](docs/tooling.md)

After the first successful workflow run, the documentation is published at the repository's Pages URL.

## Releasing

1. Update `Project.toml`/`stdlib/DripStd/Project.toml` versions as needed.
2. Commit changes and tag a release (`git tag vX.Y.Z && git push origin vX.Y.Z`).
3. The **Build Apps** workflow packages binaries; attach them to a GitHub Release if desired.
4. Draft release notes summarizing compiler, stdlib, and documentation changes.

## Contributing

1. Create a branch.
2. Add tests for new behaviour.
3. Run `julia --project=. test/runtests.jl`.
4. Submit a pull request.

Feel free to open issues for new slang proposals, performance ideas, or ecosystem tooling.
