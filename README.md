# DripLang Compiler

DripLang is a Julia-inspired language that replaces core keywords with Gen Z slang while preserving Julia's semantics, multiple dispatch, and JIT performance. This repository contains a production-ready compiler implemented in Julia.

## Features

- Tokenizer that remaps slang keywords (e.g., `flex` ? `function`, `yeet` ? `end`).
- Parser that normalizes Windows/Unix newlines and lowers code through Julia's parser.
- Semantic analyzer that assigns stable module names and extracts typed method signatures for eager precompilation.
- Runtime pipeline that compiles DripLang source into isolated Julia modules, optionally precompiles typed methods, and exposes programmatic and CLI entry points.
- Simple CLI supporting `compile`, `run`, and `repl` commands.

## Getting Started

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

To compile and run the example program:

```bash
julia --project=. -e 'using DripLangCompiler; compiled = DripLangCompiler.compile_file("examples/hello.drip"); println(DripLangCompiler.Runtime.run(compiled; entrypoint=:main))'
```

Or use the CLI:

```bash
julia --project=. -e 'using DripLangCompiler; DripLangCompiler.CLI.main(["run", "examples/hello.drip"])'
```

## Testing

```
julia --project=. -e 'using Pkg; Pkg.test()'
```

## Language Reference

See [docs/LANGUAGE.md](docs/LANGUAGE.md) for the keyword mapping and language specification.
