module Codegen

using ..AST: DripProgram
using ..Semantics: SemanticModel

export LoweredProgram, lower_to_julia

struct LoweredProgram
    semantic::SemanticModel
    exprs::Vector{Any}
end

function lower_to_julia(model::SemanticModel)
    LoweredProgram(model, copy(model.program.exprs))
end

end # module
