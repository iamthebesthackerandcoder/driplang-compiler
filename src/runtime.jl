module Runtime

using Logging

using ..Diagnostics: Diagnostic, CompilerError, emit_diagnostic
using ..Lexer
using ..Parser
using ..Semantics
using ..Codegen

export CompiledModule, compile_string, compile_file, run_file, repl

struct CompiledModule
    namespace::Module
    lowered::Codegen.LoweredProgram
    source::String
    file::String
    last_value::Any
end

const _PUBLIC_FIELDS = (:module, :namespace, :lowered, :source, :file, :last_value)

Base.propertynames(::CompiledModule, private::Bool=false) = private ? _PUBLIC_FIELDS : (:module, :lowered, :source, :file, :last_value)

function Base.getproperty(compiled::CompiledModule, name::Symbol)
    if name === :module
        return compiled.namespace
    elseif name === :namespace || name === :lowered || name === :source || name === :file || name === :last_value
        return getfield(compiled, name)
    elseif isdefined(compiled.namespace, name)
        return getfield(compiled.namespace, name)
    else
        return getfield(compiled, name)
    end
end

function handle_diagnostics!(diagnostics::Vector{Diagnostic})
    for diag in diagnostics
        emit_diagnostic(global_logger(), diag)
        diag.severity === :error && throw(CompilerError(diag))
    end
end

function precompile_methods!(mod::Module, methods::Vector{Semantics.TypedMethod})
    for typed in methods
        isdefined(mod, typed.name) || continue
        fn = getfield(mod, typed.name)
        arg_types = Type[]
        convertible = true
        for type_expr in typed.arg_types
            try
                ty = Core.eval(mod, type_expr)
                ty isa Type || ((convertible = false); break)
                push!(arg_types, ty)
            catch err
                convertible = false
                @warn "Unable to resolve type annotation" fn_symbol=typed.name type_expr=string(type_expr) error=err
                break
            end
        end
        convertible || continue
        sig = Tuple{typeof(fn), arg_types...}
        try
            Base.precompile(sig)
        catch err
            @warn "Precompile failed" fn_symbol=typed.name signature=string(sig) error=err
        end
    end
end

function instantiate(lowered::Codegen.LoweredProgram; source::AbstractString, file::AbstractString, precompile_methods::Bool=true, existing_module::Union{Nothing,Module}=nothing, capture_last::Bool=false)
    mod = existing_module === nothing ? Module(lowered.semantic.module_name) : existing_module
    last_value = nothing
    for expr in lowered.exprs
        last_value = Core.eval(mod, expr)
    end
    precompile_methods && precompile_methods!(mod, lowered.semantic.typed_methods)
    CompiledModule(mod, lowered, String(source), String(file), capture_last ? last_value : nothing)
end

function compile_string(source::AbstractString; file::AbstractString="<memory>", module_name::Union{Nothing,Symbol}=nothing, precompile_methods::Bool=true, existing_module::Union{Nothing,Module}=nothing, capture_last::Bool=false)
    tokens, lex_diags = Lexer.tokenize(source; file=file)
    handle_diagnostics!(lex_diags)

    program, parse_diags = Parser.parse_program(tokens; file=file)
    if program === nothing
        handle_diagnostics!(parse_diags)
        error("Parsing failed")
    end
    handle_diagnostics!(parse_diags)

    semantic_module_name = existing_module === nothing ? module_name : nameof(existing_module)
    semantic, semantic_diags = Semantics.analyze(program; file=file, module_name=semantic_module_name)
    handle_diagnostics!(semantic_diags)

    lowered = Codegen.lower_to_julia(semantic)
    instantiate(lowered; source=source, file=file, precompile_methods=precompile_methods, existing_module=existing_module, capture_last=capture_last)
end

function compile_file(path::AbstractString; module_name::Union{Nothing,Symbol}=nothing, precompile_methods::Bool=true)
    source = read(path, String)
    compile_string(source; file=path, module_name=module_name, precompile_methods=precompile_methods)
end

function resolve_entrypoint(compiled::CompiledModule, entrypoint)
    if entrypoint === :auto
        ep = compiled.lowered.semantic.entrypoint
        ep === nothing && error("DripLang program defines no entrypoint. Declare `flex main()` to use auto mode.")
        return ep
    elseif entrypoint === nothing
        error("No entrypoint specified")
    else
        return entrypoint
    end
end

function run(compiled::CompiledModule; entrypoint=:auto, args::Tuple=())
    ep = resolve_entrypoint(compiled, entrypoint)
    isdefined(compiled.namespace, ep) || error("Entry function $(ep) is not defined")
    fn = getfield(compiled.namespace, ep)
    return fn(args...)
end

function run_file(path::AbstractString; entrypoint=:auto, args=())
    compiled = compile_file(path)
    run(compiled; entrypoint=entrypoint, args=Tuple(args))
end

function repl()
    println("DripLang REPL - type `exit` or `quit` to leave")
    session_module = Module(:DripREPL)
    while true
        print("> ")
        line = try
            readline()
        catch
            println()
            break
        end
        line === nothing && break
        stripped = strip(line)
        stripped in ("exit", "quit") && break
        isempty(stripped) && continue
        try
            compiled = compile_string(line * "\n"; file="<repl>", module_name=:DripREPL, precompile_methods=false, existing_module=session_module, capture_last=true)
            result = compiled.last_value
            result !== nothing && println(result)
        catch err
            println("Error: ", err)
        end
    end
    nothing
end

end # module
