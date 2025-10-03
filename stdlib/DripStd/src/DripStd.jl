module DripStd

module Basic
export spill, lowkey_spill, vibe_check, assert_no_cap, prompt, slay

function spill(args...)
    isempty(args) && (println(); return nothing)
    println(join(string.(args), " "))
    return nothing
end

function lowkey_spill(args...)
    isempty(args) && return nothing
    print(join(string.(args), " "))
    return nothing
end

function vibe_check(condition::Bool, message::AbstractString="vibe check failed")
    condition || throw(AssertionError(message))
    return condition
end

assert_no_cap(condition::Bool, message::AbstractString="caught you in 4k") = vibe_check(condition, message)

function prompt(message::AbstractString="> ")
    print(message)
    flush(stdout)
    return readline(stdin)
end

slay(value) = begin
    println("slay:", value)
    return value
end

end # module Basic

module Collections
export lineup, link_up, glow_map, lowkey_filter, group_chat, drip_zip

function lineup(iterable)
    collect(iterable)
end

function link_up(collections...)
    isempty(collections) && return Any[]
    reduce(vcat, collections)
end

glow_map(f, iterable) = map(f, iterable)
lowkey_filter(f, iterable) = filter(f, iterable)

function group_chat(f, iterable)
    groups = Dict{Any,Vector{Any}}()
    for item in iterable
        key = f(item)
        push!(get!(groups, key, Any[]), item)
    end
    return groups
end

drip_zip(iterables...) = collect(zip(iterables...))

end # module Collections

module Math
export drip_sum, drip_mean, drip_median, energy, normalize

drip_sum(xs) = sum(xs)

function drip_mean(xs)
    length(xs) == 0 && throw(ArgumentError("cannot take the mean of an empty collection"))
    return sum(xs) / length(xs)
end

function drip_median(xs)
    n = length(xs)
    n == 0 && throw(ArgumentError("cannot take the median of an empty collection"))
    sorted = sort!(collect(xs))
    if isodd(n)
        idx = div(n + 1, 2)
        return sorted[idx]
    else
        hi = div(n, 2) + 1
        lo = div(n, 2)
        return (sorted[lo] + sorted[hi]) / 2
    end
end

energy(xs) = sum(abs2, xs)

function normalize(xs::AbstractVector{T}) where {T<:Real}
    total = energy(xs)
    total == 0 && return zeros(T, length(xs))
    return xs ./ sqrt(total)
end

end # module Math

module Debug
export receipts, bench, bench!

receipts(value) = (println(repr(value)); value)

function bench(fn::Function; warmups::Integer=1, repeats::Integer=5)
    warmups < 0 && throw(ArgumentError("warmups must be >= 0"))
    repeats > 0 || throw(ArgumentError("repeats must be > 0"))
    for _ in 1:warmups
        fn()
    end
    samples = Float64[]
    for _ in 1:repeats
        start = time_ns()
        fn()
        elapsed_ns = time_ns() - start
        push!(samples, elapsed_ns / 1_000_000)
    end
    avg = sum(samples) / length(samples)
    return (avg = avg, min = minimum(samples), max = maximum(samples), samples = samples)
end

function bench!(label::AbstractString, fn::Function; kwargs...)
    stats = bench(fn; kwargs...)
    println("$label -> avg $(round(stats.avg, digits=3)) ms (min $(round(stats.min, digits=3)) ms, max $(round(stats.max, digits=3)) ms)")
    return stats
end

end # module Debug

using .Basic
using .Collections
using .Math
using .Debug

export Basic, Collections, Math, Debug
export spill, lowkey_spill, vibe_check, assert_no_cap, prompt, slay
export lineup, link_up, glow_map, lowkey_filter, group_chat, drip_zip
export drip_sum, drip_mean, drip_median, energy, normalize
export receipts, bench, bench!

end # module DripStd
