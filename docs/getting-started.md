# Getting Started

## Install

1. Clone the repository and enter the workspace.
2. Launch Julia with the project environment:
   ```bash
   julia --project=. -e "using Pkg; Pkg.instantiate()"
   ```
   Instantiation pulls the compiler dependencies and makes the DripStd standard library discoverable via the `LOAD_PATH`.

## CLI Usage

`DripLangCompiler.CLI.main` exposes the command-line interface. Invoke it from Julia to build, run, or REPL your `.drip` sources.

```bash
julia --project=. -e "using DripLangCompiler; DripLangCompiler.CLI.main(ARGS)" -- run examples/hello.drip
```

Popular commands:

- `compile <file>` - parse and lower the program without running it.
- `run <file> [--entry name]` - compile then execute the entrypoint (defaults to `flex main()`).
- `repl` - open a DripLang REPL backed by Julia's runtime.

Pass `--module-name` to pin the target module name or `--no-precompile` to skip Julia precompilation.

### Wrapper Script

To avoid typing the full Julia invocation, the repository ships with `bin/drip.jl`:

```bash
julia bin/drip.jl --version
julia bin/drip.jl run examples/hello.drip
```

The script auto-activates the project and forwards arguments to the CLI.

## Hello, World

Create `my_app.drip`:

```drip
plug DripStd

flex main()
    spill("hey bestie!")
    bounce void
yeet
```

Run it:

```bash
julia bin/drip.jl run my_app.drip
```

## Using Julia Packages

DripLang maps `plug` and `scoop` to Julia's `using` and `import`. Any package available in the active Julia environment is instantly usable:

```drip
plug Statistics
plug DripStd

flex main()
    numbers = [1, 2, 3, 4]
    spill("mean", mean(numbers))
    bounce drip_sum(numbers)
yeet
```

## Project Layout

```
.
|-- src/                # Compiler pipeline
|-- stdlib/DripStd/     # DripLang standard library package
|-- examples/           # Sample programs
|-- docs/               # GitHub Pages site
`-- test/               # Automated tests
```

Run the test suite whenever you change the compiler:

```bash
julia --project=. test/runtests.jl
```

The tests exercise lexing, parsing, runtime execution, and the DripStd standard library.
