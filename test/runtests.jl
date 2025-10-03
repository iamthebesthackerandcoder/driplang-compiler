using Test
using .DripLangCompiler
using .DripLangCompiler.Lexer
using .DripLangCompiler.Parser
using .DripLangCompiler.Runtime

@testset "Lexer" begin
    tokens, diags = Lexer.tokenize("flex demo() yeet"; file="<lexer>")
    @test isempty(diags)
    @test any(t -> t.mapped == "function", tokens)
end

sample_source = """
plug Statistics

flex sum_numbers(vals::Vector{Int})
    total = 0
    loopin v vibein vals
        total += v
    yeet
    bounce total
yeet

flex main()
    bounce sum_numbers([1,2,3])
yeet
"""

@testset "Parser" begin
    tokens, diags = Lexer.tokenize(sample_source; file="<parser>")
    @test isempty(diags)
    program, parse_diags = Parser.parse_program(tokens; file="<parser>")
    @test isempty(parse_diags)
    @test length(program.exprs) >= 2
end

@testset "Runtime" begin
    compiled = DripLangCompiler.compile_string(sample_source; file="<runtime>")
    result = Runtime.run(compiled; entrypoint=:main)
    @test result == 6
end
