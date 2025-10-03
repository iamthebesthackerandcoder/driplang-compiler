#!/usr/bin/env julia
# Lightweight launcher for the DripLang compiler CLI.

using Pkg
Pkg.activate(joinpath(@__DIR__, ".."), io=devnull)

try
    @eval using DripLangCompiler
catch err
    if err isa ArgumentError
        @warn "Dependencies missing; instantiate the environment first" err
    end
    rethrow()
end

DripLangCompiler.CLI.main(collect(ARGS))
