---
layout: default
title: Welcome to DripLang
nav_order: 1
description: Overview of the DripLang language, tooling, and community links.
---

# Welcome to DripLang

DripLang is a Julia-powered programming language that swaps the classic keywords for Gen Z slang while keeping Julia's multiple dispatch, performance, and expressive power. The compiler translates `.drip` sources to Julia IR, so your programs get instant JIT compilation and access to the rich Julia ecosystem.

## Quick Start

```bash
julia --project=. -e "using DripLangCompiler; DripLangCompiler.CLI.main([\"run\", \"examples/hello.drip\"])"
```

That command compiles and executes `examples/hello.drip` using the DripLang CLI. Add `compile` to emit a compiled module or launch the `repl` command for an interactive session.

## Features

- Slang-first syntax: write `flex`, `fr`, and `yeet` while keeping Julia semantics.
- Multiple dispatch and JIT: every DripLang function is a Julia method with dynamic specialization.
- DripStd standard library: batteries-included helpers for I/O, math, collections, and benchmarking.
- CLI and API: scriptable compiler plus a REPL for rapid experimentation.
- Tooling ready: structured diagnostics, CI pipelines, release builds, and a documentation site.

## Next Steps

- [Install & Run](getting-started.md)
- [Language Reference](language-reference.md)
- [Standard Library](stdlib.md)
- [Tooling & Workflow](tooling.md)

## Community

Open issues, ideas, or fire memes? File them on [GitHub](https://github.com/shuey/driplang-compiler) or join the discussions tab to keep the vibes high.
