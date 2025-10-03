#!/usr/bin/env julia

using Pkg

project_root = normpath(joinpath(@__DIR__, ".."))
Pkg.activate(project_root)
Pkg.instantiate()

Pkg.add(name = "PackageCompiler", version = "2")

using PackageCompiler

output_dir = get(ENV, "DRIP_BUILD_OUTPUT", joinpath(project_root, "build"))
force = get(ENV, "DRIP_BUILD_FORCE", "true") == "true"
precompile_file = joinpath(@__DIR__, "precompile.jl")
launcher_file = joinpath(@__DIR__, "launcher.jl")

create_app(
    project_root,
    output_dir;
    force = force,
    filter_stdlibs = true,
    include_transitive_dependencies = true,
    precompile_execution_file = isfile(precompile_file) ? precompile_file : nothing,
    script = isfile(launcher_file) ? launcher_file : nothing,
)

println("Build artifacts placed in: ", output_dir)
