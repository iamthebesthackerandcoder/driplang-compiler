module Parser

using Base.Meta
using ..AST: DripProgram, Token, set_mapped_range
using ..Diagnostics: Diagnostic, SourceRange, SourceLocation

export parse_program

function annotate_tokens(tokens::Vector{Token})
    annotated = Vector{Token}(undef, length(tokens))
    io = IOBuffer()
    line = 1
    col = 1
    for (idx, token) in enumerate(tokens)
        mapped = token.mapped
        start_line = line
        start_col = col
        line_next = line
        col_next = col
        for ch in mapped
            if ch == '\n'
                line_next += 1
                col_next = 1
            else
                col_next += 1
            end
        end
        end_line = line_next
        if !isempty(mapped) && last(mapped) == '\n'
            end_col = 0
            col = 1
        else
            end_col = max(col_next - 1, start_col)
            col = col_next
        end
        line = line_next
        mapped_range = SourceRange("<translated>", start_line, start_col, end_line, end_col)
        annotated[idx] = set_mapped_range(token, mapped_range)
        write(io, mapped)
    end
    return annotated, String(take!(io))
end

function byte_to_linecol(source::String, byte_index::Int)
    byte_index <= 0 && return 1, 1
    current_line = 1
    current_col = 1
    current_byte = 1
    idx = firstindex(source)
    while current_byte < byte_index && idx <= lastindex(source)
        ch = source[idx]
        if ch == '\n'
            current_line += 1
            current_col = 1
        else
            current_col += 1
        end
        current_byte += ncodeunits(ch)
        idx = nextind(source, idx)
    end
    return current_line, current_col
end

function range_contains(range::SourceRange, line::Int, col::Int)
    if line < range.start_line || line > range.end_line
        return false
    end
    if range.start_line == range.end_line
        return range.start_column <= col <= max(range.end_column, range.start_column)
    elseif line == range.start_line
        return col >= range.start_column
    elseif line == range.end_line
        return col <= max(range.end_column, 1)
    else
        return true
    end
end

function offset_in_mapped(token::Token, line::Int, col::Int)
    mrange = token.mapped_range
    mrange === nothing && return 0
    current_line = mrange.start_line
    current_col = mrange.start_column
    offset = 0
    for ch in token.mapped
        if current_line == line && current_col == col
            return offset
        end
        if ch == '\n'
            current_line += 1
            current_col = 1
        else
            current_col += 1
        end
        offset += 1
    end
    return offset
end

function offset_to_original(token::Token, offset::Int)
    orng = token.original_range
    current_line = orng.start_line
    current_col = orng.start_column
    idx = 0
    for ch in token.lexeme
        if idx == offset
            return SourceLocation(orng.file, current_line, current_col)
        end
        if ch == '\n'
            current_line += 1
            current_col = 1
        else
            current_col += 1
        end
        idx += 1
    end
    return SourceLocation(orng.file, orng.end_line, max(orng.end_column, 1))
end

function mapped_to_original(tokens::Vector{Token}, line::Int, col::Int)
    if isempty(tokens)
        return SourceLocation("<unknown>", line, col)
    end
    fallback = SourceLocation(tokens[end].original_range.file, tokens[end].original_range.end_line, max(tokens[end].original_range.end_column, 1))
    for token in tokens
        mrange = token.mapped_range
        mrange === nothing && continue
        if range_contains(mrange, line, col)
            if token.lexeme == token.mapped
                offset = offset_in_mapped(token, line, col)
                return offset_to_original(token, offset)
            else
                orng = token.original_range
                return SourceLocation(orng.file, orng.start_line, orng.start_column)
            end
        elseif (line > mrange.end_line) || (line == mrange.end_line && col > max(mrange.end_column, 0))
            fallback = SourceLocation(token.original_range.file, token.original_range.end_line, max(token.original_range.end_column, 1))
        end
    end
    return fallback
end

function parse_error_diagnostic(err::Base.Meta.ParseError, mapped_source::String, tokens::Vector{Token})
    detail = err.detail
    start_loc = SourceLocation("<translated>", 1, 1)
    end_loc = start_loc
    message = strip(err.msg)

    if detail isa Base.JuliaSyntax.ParseError && !isempty(detail.diagnostics)
        diag = detail.diagnostics[1]
        start_byte = diag.first_byte
        end_byte = diag.last_byte
        start_line, start_col = byte_to_linecol(mapped_source, start_byte)
        end_line, end_col = byte_to_linecol(mapped_source, max(end_byte, start_byte))
        start_loc = mapped_to_original(tokens, start_line, start_col)
        end_loc = mapped_to_original(tokens, end_line, max(end_col, start_col))
        message = diag.message
    else
        start_loc = mapped_to_original(tokens, 1, 1)
        end_loc = start_loc
    end

    range = SourceRange(start_loc.file, start_loc.line, start_loc.column, end_loc.line, end_loc.column)
    return Diagnostic(range, :error, message)
end

function flatten_toplevel(expr)
    if expr === nothing
        Any[]
    elseif expr isa Expr && expr.head === :toplevel
        Any[expr.args...]
    else
        Any[expr]
    end
end

function parse_program(tokens::Vector{Token}; file::AbstractString="<memory>")
    annotated_tokens, mapped_source = annotate_tokens(tokens)
    expr = Meta.parseall(mapped_source; filename=file)

    exprs = flatten_toplevel(expr)
    for node in exprs
        if node isa Expr && node.head === :incomplete
            parse_err = node.args[1]
            diag = parse_error_diagnostic(parse_err, mapped_source, annotated_tokens)
            return nothing, [diag]
        end
    end

    program = DripProgram(annotated_tokens, mapped_source, exprs)
    return program, Diagnostic[]
end

end # module
