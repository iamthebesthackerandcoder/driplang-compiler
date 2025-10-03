module CLI

using ..Runtime

const _PARENT = parentmodule(@__MODULE__)
const DRIP_VERSION = getproperty(_PARENT, :VERSION)

export main, usage

function usage(io::IO=stdout)
    println(io, "Usage: drip <command> [options] [file]")
    println(io)
    println(io, "Commands:")
    println(io, "  compile <file> [--module-name NAME] [--no-precompile]")
    println(io, "  run <file> [--entry NAME] [--module-name NAME] [--no-precompile]")
    println(io, "  repl")
    println(io)
    println(io, "Global flags:")
    println(io, "  --help, -h        Show this message")
    println(io, "  --version, -V     Show compiler version")
end

print_version(io::IO=stdout) = println(io, "DripLangCompiler " * string(DRIP_VERSION))

function parse_options(args::Vector{String})
    options = Dict{String,Any}()
    positional = String[]
    i = 1
    while i <= length(args)
        arg = args[i]
        if startswith(arg, "--") || startswith(arg, "-")
            if arg == "--no-precompile"
                options["no_precompile"] = true
                i += 1
            elseif arg in ("--module-name", "--entry")
                i == length(args) && throw(ArgumentError("option $(arg) requires a value"))
                options[arg[3:end]] = args[i+1]
                i += 2
            elseif arg in ("--help", "-h")
                options["help"] = true
                i += 1
            elseif arg in ("--version", "-V")
                options["version"] = true
                i += 1
            else
                throw(ArgumentError("unknown option $(arg)"))
            end
        else
            push!(positional, arg)
            i += 1
        end
    end
    return options, positional
end

function dispatch(command::String, options::Dict{String,Any}, positional::Vector{String})
    if command == "compile"
        isempty(positional) && throw(ArgumentError("compile expects a file path"))
        file = positional[1]
        module_name = get(options, "module-name", nothing)
        precompile = !get(options, "no_precompile", false)
        Runtime.compile_file(file; module_name=module_name === nothing ? nothing : Symbol(module_name), precompile_methods=precompile)
    elseif command == "run"
        isempty(positional) && throw(ArgumentError("run expects a file path"))
        file = positional[1]
        module_name = get(options, "module-name", nothing)
        precompile = !get(options, "no_precompile", false)
        entry = get(options, "entry", :auto)
        entry_symbol = entry === :auto ? :auto : Symbol(entry)
        compiled = Runtime.compile_file(file; module_name=module_name === nothing ? nothing : Symbol(module_name), precompile_methods=precompile)
        Runtime.run(compiled; entrypoint=entry_symbol)
    elseif command == "repl"
        !isempty(positional) && throw(ArgumentError("repl does not take positional arguments"))
        Runtime.repl()
    else
        throw(ArgumentError("unknown command $(command)"))
    end
end

function main(args::Vector{String})
    try
        if isempty(args)
            usage()
            return
        end
        first_arg = args[1]
        if first_arg in ("--help", "-h")
            usage()
            return
        elseif first_arg in ("--version", "-V")
            print_version()
            return
        end

        command = first_arg
        options, positional = parse_options(args[2:end])

        get(options, "help", false) && (usage(); return)
        get(options, "version", false) && (print_version(); return)

        dispatch(command, options, positional)
    catch err
        if err isa ArgumentError
            println(stderr, "error: ", err.msg)
            usage(stderr)
            return
        else
            rethrow()
        end
    end
end

end # module
