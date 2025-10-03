module Semantics

using Base: isnothing
using ..AST: DripProgram
using ..Diagnostics: Diagnostic, SourceRange, SourceLocation

export SemanticModel, TypedMethod, analyze

struct TypedMethod
    name::Symbol
    arg_types::Vector{Expr}
end
Base.:(==)(a::TypedMethod, b::TypedMethod) = a.name == b.name && length(a.arg_types) == length(b.arg_types) && all(isequal.(a.arg_types, b.arg_types))
Base.hash(tm::TypedMethod, h::UInt) = hash((tm.name, tm.arg_types), h)

struct SemanticModel
    program::DripProgram
    module_name::Symbol
    exports::Vector{Symbol}
    typed_methods::Vector{TypedMethod}
    entrypoint::Union{Nothing, Symbol}
end

function sanitize_name(name::AbstractString)
    sanitized = replace(name, r"[^A-Za-z0-9_]" => "_")
    isempty(sanitized) && (sanitized = "DripSession")
    return sanitized
end

function make_module_name(file::AbstractString, program::DripProgram)
    base = file == "<memory>" ? "DripSession" : splitext(basename(file))[1]
    sanitized = sanitize_name(base)
    hash_value = UInt32(hash(program.mapped_source) & 0x00000000ffffffff)
    hash_part = lpad(string(hash_value, base=16), 8, '0')
    Symbol("Drip_" * sanitized * "_" * hash_part)
end

function splitext(path::AbstractString)
    idx = findlast(c -> c == '.', path)
    isnothing(idx) && return path, ""
    return path[1:idx-1], path[idx:end]
end

function basename(path::AbstractString)
    idx = findlast(c -> c == '/' || c == '\\', path)
    isnothing(idx) && return path
    return path[idx+1:end]
end

function collect_exports!(acc::Vector{Symbol}, expr)
    if expr isa Expr
        if expr.head == :export
            for arg in expr.args
                arg isa Symbol && push!(acc, arg)
            end
        end
        for arg in expr.args
            collect_exports!(acc, arg)
        end
    end
    return acc
end

function function_name_of(sig)
    if sig isa Symbol
        return sig
    elseif sig isa Expr
        if sig.head == :call
            head = sig.args[1]
            if head isa Symbol
                return head
            elseif head isa Expr && head.head == :curly && !isempty(head.args)
                inner = head.args[1]
                return inner isa Symbol ? inner : nothing
            end
        elseif sig.head == :where
            return function_name_of(sig.args[1])
        end
    end
    return nothing
end

function collect_function_names(expr)
    names = Symbol[]
    if expr isa Expr
        if expr.head == :function
            name = function_name_of(expr.args[1])
            name !== nothing && push!(names, name)
        elseif expr.head == :(=)
            name = function_name_of(expr.args[1])
            name !== nothing && push!(names, name)
        end
        for arg in expr.args
            append!(names, collect_function_names(arg))
        end
    end
    return names
end

function extract_typed_signature(sig)
    if sig isa Symbol
        return TypedMethod(sig, Expr[])
    elseif sig isa Expr
        if sig.head == :call
            fname = function_name_of(sig)
            fname === nothing && return nothing
            arg_exprs = sig.args[2:end]
            types = Expr[]
            for arg in arg_exprs
                if arg isa Expr && arg.head == :(::)
                    if arg.args[1] isa Expr && arg.args[1].head == :(...)
                        return nothing
                    end
                    push!(types, arg.args[2])
                else
                    return nothing
                end
            end
            return TypedMethod(fname, types)
        elseif sig.head == :where
            return nothing
        end
    end
    return nothing
end

function collect_typed_methods!(acc::Vector{TypedMethod}, expr)
    if expr isa Expr
        if expr.head == :function
            sig = extract_typed_signature(expr.args[1])
            sig !== nothing && push!(acc, sig)
        elseif expr.head == :(=)
            sig = extract_typed_signature(expr.args[1])
            sig !== nothing && push!(acc, sig)
        end
        for arg in expr.args
            collect_typed_methods!(acc, arg)
        end
    end
    return acc
end

function analyze(program::DripProgram; file::AbstractString="<memory>", module_name::Union{Nothing,Symbol}=nothing)
    exports = Symbol[]
    typed_methods = TypedMethod[]
    all_function_names = Symbol[]

    for expr in program.exprs
        collect_exports!(exports, expr)
        collect_typed_methods!(typed_methods, expr)
        append!(all_function_names, collect_function_names(expr))
    end

    unique!(exports)
    unique!(typed_methods)
    unique!(all_function_names)

    entrypoint = :main in all_function_names ? :main : nothing
    modname = isnothing(module_name) ? make_module_name(file, program) : module_name

    model = SemanticModel(program, modname, exports, typed_methods, entrypoint)
    return model, Diagnostic[]
end

end # module
