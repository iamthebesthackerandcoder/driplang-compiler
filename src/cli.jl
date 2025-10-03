module CLI

using ..Runtime

export main

function usage()
    println("Usage: drip <compile|run|repl> [options] [file]")
    println()
    println("Commands:")
    println("  compile <file> [--module-name NAME] [--no-precompile]")
    println("  run <file> [--entry NAME] [--module-name NAME] [--no-precompile]")
    println("  repl")
end

function parse_options(args::Vector{String})
    options = Dict{String,Any}()
    positional = String[]
    i = 1
    while i <= length(args)
        arg = args[i]
        if startswith(arg, "--")
            if arg == "--no-precompile"
                options["no_precompile"] = true
                i += 1
            elseif arg == "--module-name" || arg == "--entry"
                i == length(args) && error("Option $arg requires a value")
                options[arg[3:end]] = args[i+1]
                i += 2
            else
                error("Unknown option $arg")
            end
        else
            push!(positional, arg)
            i += 1
        end
    end
    return options, positional
end

function main(args::Vector{String})
    isempty(args) && return usage()
    command = args[1]
    options, positional = parse_options(args[2:end])
    if command == "compile"
        isempty(positional) && error("compile command expects a file path")
        file = positional[1]
        module_name = get(options, "module-name", nothing)
        precompile = !get(options, "no_precompile", false)
        Runtime.compile_file(file; module_name=module_name === nothing ? nothing : Symbol(module_name), precompile_methods=precompile)
    elseif command == "run"
        isempty(positional) && error("run command expects a file path")
        file = positional[1]
        module_name = get(options, "module-name", nothing)
        precompile = !get(options, "no_precompile", false)
        entry = get(options, "entry", :auto)
        entry_symbol = entry === :auto ? :auto : Symbol(entry)
        compiled = Runtime.compile_file(file; module_name=module_name === nothing ? nothing : Symbol(module_name), precompile_methods=precompile)
        Runtime.run(compiled; entrypoint=entry_symbol)
    elseif command == "repl"
        Runtime.repl()
    else
        usage()
        error("Unknown command: $command")
    end
end

end # module
