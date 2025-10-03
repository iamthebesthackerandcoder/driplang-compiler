module DripLangCompiler

using Logging
using LoggingExtras
using ArgParse

const VERSION = v"0.2.0"
const _STDLIB_ROOT = normpath(joinpath(@__DIR__, "..", "stdlib"))
if !(_STDLIB_ROOT in Base.LOAD_PATH)
    push!(Base.LOAD_PATH, _STDLIB_ROOT)
end

function ensure_stdlib_loaded()
    try
        Base.require(Main, :DripStd)
    catch err
        @warn "Unable to auto-load DripStd standard library" error=err
    end
end

ensure_stdlib_loaded()

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
const DripStd = isdefined(Main, :DripStd) ? Main.DripStd : nothing

compile_string(args...; kwargs...) = Runtime.compile_string(args...; kwargs...)
compile_file(args...; kwargs...) = Runtime.compile_file(args...; kwargs...)
run_file(args...; kwargs...) = Runtime.run_file(args...; kwargs...)
repl(args...; kwargs...) = Runtime.repl(args...; kwargs...)

export compile_string, compile_file, run_file, repl, Runtime, Diagnostics, AST, Lexer, Parser, Semantics, Codegen, CLI, DripStd, VERSION

end # module
