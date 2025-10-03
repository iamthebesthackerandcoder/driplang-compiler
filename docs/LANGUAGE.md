# DripLang Specification

DripLang is a high-level, expression-oriented programming language inspired by Julia's syntax and semantics but remixed with Gen Z slang for lexical keywords. The compiler translates DripLang source code into Julia IR, leveraging Julia's multiple dispatch and JIT compiler for runtime performance.

## Lexical Keywords

| Purpose | DripLang | Julia | Notes |
|---------|----------|-------|-------|
| Function definition | `flex` | `function` | Functions support multiple dispatch based on argument types |
| Anonymous function arrow | `glow` | `->` | Used for lambda literals |
| End of block | `yeet` | `end` | Terminates `flex`, `fr`, loops, etc. |
| If | `fr` | `if` | Conditional execution |
| Else if | `lowkey` | `elseif` | Chained condition |
| Else | `no_cap` | `else` | Fallback branch |
| While loop | `keepit100` | `while` | Condition-checked loop |
| For loop | `loopin` | `for` | Iterates over iterables |
| In (loop binding) | `vibein` | `in` | Used within `loopin` headers |
| Mutable struct | `main_character` | `mutable struct` | Defines mutable aggregate types |
| Immutable struct | `side_character` | `struct` | Defines immutable aggregate types |
| Begin block | `squad` | `begin` | Group statements |
| Let binding | `bet` | `let` | Scoped binding |
| Return | `bounce` | `return` | Early exit from `flex` |
| Break | `ghost` | `break` | Exit loops |
| Continue | `spin` | `continue` | Next iteration |
| True | `facts` | `true` | Boolean literal |
| False | `cap` | `false` | Boolean literal |
| Nothing | `void` | `nothing` | Absence of value |
| Module | `clout` | `module` | Namespace |
| Export | `shoutout` | `export` | Public API |
| Import | `scoop` | `import` | Qualified import |
| Using | `plug` | `using` | Bring names into scope |
| Macro | `vibecheck` | `macro` | Define macros |

Identifiers follow Julia rules. Numeric, string, and interpolation syntax match Julia.

## Expressions and Statements

- Blocks, control flow, and loops behave identically to Julia but use DripLang keywords.
- Function definitions allow optional type annotations using Julia syntax: `flex foo(x::Int) ... yeet`.
- Lambdas use `args glow expr`.
- Struct definitions map directly onto Julia `struct`/`mutable struct` constructs, enabling multiple dispatch across types.
- Operators, literals, broadcasting, and macros mirror Julia semantics; the compiler forwards unknown identifiers to Julia at runtime.

## Semantics

- Static scoping identical to Julia.
- Types and dispatch resolved by Julia's runtime; DripLang acts as syntactic sugar.
- Compilation produces Julia `Expr` objects, then defines methods into a generated module to trigger JIT compilation on demand.

## Compilation Pipeline

1. **Lexing** ? Convert source into tokens, remapping slang keywords.
2. **Parsing** ? Adapted Pratt parser that produces Julia-compatible AST.
3. **Desugaring** ? Transform DripLang AST into canonical Julia AST.
4. **Codegen** ? Produce Julia expressions and evaluate them inside a managed `Module`.
5. **Runtime** ? Provide CLI for compiling files, running entry points, and emitting lowered code.

## File Extensions

- Source files use `.drip` extension.
- Compiled cache artifacts (planned) use `.dripc`.

## Tooling Goals

- Deterministic lexing/parsing with helpful diagnostics.
- Emission of readable Julia code for debugging.
- Support for REPL/CLI compilation, including module encapsulation.
- Hooks for future static analysis and optimization passes.


## Tooling

- Compiler API: `DripLangCompiler.compile_string` and `DripLangCompiler.Runtime.run` support programmatic compilation and execution.
- CLI: `DripLangCompiler.CLI.main` exposes `compile`, `run`, and `repl`. Example:
  `julia --project=. -e "using DripLangCompiler; DripLangCompiler.CLI.main([\"run\", \"examples/hello.drip\"])"`
