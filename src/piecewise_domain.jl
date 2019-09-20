struct PiecewiseInterval{T, S} <: Intervals.AbstractInterval{T}
    first::T
    last::T
    inclusivity::Intervals.Inclusivity
    PiecewiseInterval(S) = new{eltype(S), S}(S[1], S[end], Inclusivity(true,true))
end

function region(::PiecewiseInterval{T,S}, x::T) where {T,S}
    N = length(S)
    low = 1
    high = N
    while low != high-1
        mid = (high-low)÷2
        if S[low] < x < S[mid]
            high = mid
        else
            low = mid
        end
    end
    return low
end


"""
Finds the new piecewise domains of a convolved function - it assumes that x and y are already sorted.
"""
function conv_picewise_intervals(::PiecewiseInterval{T,X}, ::PiecewiseInterval{T,Y}) where {T,X,Y}
    x,y = X,Y
    min, shifted = findmax((y[end] - x[1], x[end]-x[1]))
    τ = []
    if shifted == 2
        x,y = y,x
    end
    k = 1
    n = length(x)
    endmin = min(length(x), length(y))
    while min(length(y), length(x))>0
        push!(τ, min)
        y = y .- min
        min = Inf
        for j in max((length(y)-k+1), 1):length(y), i in 1:min(k, length(x)) # moves the indices to avoid iterating over
            cand = x[i]-y[j]
            if 0<cand<min
                min = cand
            end
        end
        if k<endmin
            k = k+1
        else
            if y[end] > x[end]
                y = y[1:end-1]
            end
            if x[1] < y[1]
                x = x[2:end]
            end
        end
    end
    return PiecewiseInterval(τ)
end
