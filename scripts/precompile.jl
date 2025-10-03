using DripLangCompiler

sample = """
plug DripStd

flex main()
    spill("DripLang build precompile")
    bounce void
yeet
"""

compiled = DripLangCompiler.compile_string(sample; file = "<build-precompile>", precompile_methods = true)
DripLangCompiler.Runtime.run(compiled; entrypoint = :main)
