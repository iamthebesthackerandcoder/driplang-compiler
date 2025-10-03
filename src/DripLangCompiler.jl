module DripLangCompiler

using Logging
using LoggingExtras
using ArgParse

include("diagnostics.jl")
include("ast.jl")
include("lexer.jl")
include("parser.jl")
include("semantics.jl")
include("codegen.jl")
include("runtime.jl")
include("cli.jl")

const Diagnostics = Diagnostics
const AST = AST
const Lexer = Lexer
const Parser = Parser
const Semantics = Semantics
const Codegen = Codegen
const Runtime = Runtime
const CLI = CLI

compile_string(args...; kwargs...) = Runtime.compile_string(args...; kwargs...)
compile_file(args...; kwargs...) = Runtime.compile_file(args...; kwargs...)
run_file(args...; kwargs...) = Runtime.run_file(args...; kwargs...)
repl(args...; kwargs...) = Runtime.repl(args...; kwargs...)

export compile_string, compile_file, run_file, repl, Runtime, Diagnostics, AST, Lexer, Parser, Semantics, Codegen, CLI

end # module
