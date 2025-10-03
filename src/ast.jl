module AST

using ..Diagnostics: SourceRange

export Token, DripProgram, set_mapped_range

struct Token
    kind::Symbol
    lexeme::String
    mapped::String
    original_range::SourceRange
    mapped_range::Union{Nothing, SourceRange}
end

Token(kind::Symbol, lexeme::String, mapped::String, range::SourceRange) = Token(kind, lexeme, mapped, range, nothing)

function set_mapped_range(token::Token, mapped::SourceRange)
    Token(token.kind, token.lexeme, token.mapped, token.original_range, mapped)
end

struct DripProgram
    tokens::Vector{Token}
    mapped_source::String
    exprs::Vector{Any}
end

end # module
