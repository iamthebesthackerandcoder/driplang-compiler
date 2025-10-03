module Diagnostics

using Logging

export SourceLocation, SourceRange, Diagnostic, CompilerError, emit_diagnostic

struct SourceLocation
    file::AbstractString
    line::Int
    column::Int
end

struct SourceRange
    file::AbstractString
    start_line::Int
    start_column::Int
    end_line::Int
    end_column::Int
end

struct Diagnostic
    range::SourceRange
    severity::Symbol
    message::String
end

struct CompilerError <: Exception
    diagnostic::Diagnostic
end

Base.showerror(io::IO, err::CompilerError) = print(io, "$(err.diagnostic.severity) @ $(err.diagnostic.range.file):$(err.diagnostic.range.start_line):$(err.diagnostic.range.start_column): $(err.diagnostic.message)")

function emit_diagnostic(logger::AbstractLogger, diag::Diagnostic)
    level = diag.severity === :error ? Logging.Error : diag.severity === :warning ? Logging.Warn : Logging.Info
    with_logger(logger) do
        @logmsg level diag.message key=:drip_range value=(diag.range.start_line, diag.range.start_column, diag.range.end_line, diag.range.end_column)
    end
end

end # module
