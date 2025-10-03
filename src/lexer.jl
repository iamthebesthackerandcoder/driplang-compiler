module Lexer

using Tokenize
using Tokenize: Tokens

using ..Diagnostics: SourceRange, Diagnostic
using ..AST: Token

export KEYWORD_TRANSLATIONS, tokenize

const KEYWORD_TRANSLATIONS = Dict(
    "flex" => (:function, "function"),
    "yeet" => (:end, "end"),
    "fr" => (:if, "if"),
    "lowkey" => (:elseif, "elseif"),
    "no_cap" => (:else, "else"),
    "keepit100" => (:while, "while"),
    "loopin" => (:for, "for"),
    "vibein" => (:in, "in"),
    "main_character" => (:mutable_struct, "mutable struct"),
    "side_character" => (:struct, "struct"),
    "squad" => (:begin, "begin"),
    "bet" => (:let, "let"),
    "bounce" => (:return, "return"),
    "ghost" => (:break, "break"),
    "spin" => (:continue, "continue"),
    "facts" => (:true, "true"),
    "cap" => (:false, "false"),
    "void" => (:nothing, "nothing"),
    "clout" => (:module, "module"),
    "shoutout" => (:export, "export"),
    "scoop" => (:import, "import"),
    "plug" => (:using, "using"),
    "vibecheck" => (:macro, "macro"),
    "glow" => (:arrow, "->")
)

const TOKEN_KIND_MAP = Dict{Tokens.Kind, Symbol}(
    Tokens.IDENTIFIER => :identifier,
    Tokens.KEYWORD => :julia_keyword,
    Tokens.WHITESPACE => :whitespace,
    Tokens.COMMENT => :comment,
    Tokens.STRING => :string,
    Tokens.TRIPLE_STRING => :string,
    Tokens.CHAR => :char
)

function classify_token(raw_kind::Tokens.Kind)
    get(TOKEN_KIND_MAP, raw_kind, Symbol(lowercase(string(raw_kind))))
end

function translate_identifier(lexeme::String)
    lower = lowercase(lexeme)
    if haskey(KEYWORD_TRANSLATIONS, lower) && lexeme == lower
        mapped_sym, mapped_str = KEYWORD_TRANSLATIONS[lower]
        return Symbol("keyword_" * String(mapped_sym)), mapped_str
    end
    return :identifier, lexeme
end

function build_token(raw_token, file::AbstractString)
    raw_kind = raw_token.kind
    raw_kind === Tokens.ENDMARKER && return nothing

    lexeme = Tokenize.untokenize(raw_token)
    start_line, start_col = Tokens.startpos(raw_token)
    end_line, end_col = Tokens.endpos(raw_token)
    original_range = SourceRange(file, start_line, start_col, end_line, end_col)

    mapped_kind = classify_token(raw_kind)
    mapped_text = replace(lexeme, "\r\n"=>"\n", "\r"=>"\n")

    if raw_kind === Tokens.IDENTIFIER
        mapped_kind, mapped_text = translate_identifier(lexeme)
    elseif Tokens.iskeyword(raw_kind)
        mapped_kind = :julia_keyword
        mapped_text = lowercase(string(raw_token.kind))
    elseif Tokens.isoperator(raw_kind)
        mapped_kind = :operator
        mapped_text = Tokenize.untokenize(raw_token)
    elseif raw_kind === Tokens.WHITESPACE
        mapped_kind = :whitespace
    elseif raw_kind === Tokens.COMMENT
        mapped_kind = :comment
    end

    return Token(mapped_kind, lexeme, mapped_text, original_range)
end

function tokenize(source::AbstractString; file::AbstractString="<memory>")
    lexer = Tokenize.tokenize(source)
    tokens = Token[]
    diagnostics = Diagnostic[]

    for raw in lexer
        raw.kind === Tokens.ENDMARKER && break

        start_line, start_col = Tokens.startpos(raw)
        end_line, end_col = Tokens.endpos(raw)
        range = SourceRange(file, start_line, start_col, end_line, end_col)

        if raw.token_error != Tokens.NO_ERR
            message = Tokens.TOKEN_ERROR_DESCRIPTION[raw.token_error]
            push!(diagnostics, Diagnostic(range, :error, message))
            continue
        end

        token = build_token(raw, file)
        token === nothing && continue
        push!(tokens, token)
    end

    return tokens, diagnostics
end

end # module
