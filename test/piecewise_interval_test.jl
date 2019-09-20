using AnalyticSignals

function dumb_region(::PiecewiseInterval{T,S}, x::T) where {T,S}
    if x<S[1]
        return 1
    elseif x>S[end]
        return length(S)+1
    else
        i = 1
        while S[i] < x < S[i+1]
            i = i + 1
        end
        return i+1
    end
end

for i in 5:10
    s = SVector(sort(rand(5))
    x = 3*rand()-1.5
    I = PiecewiseInterval(s)
    @test region(I, x) == dumb_region(I,x)
end

I = PiecewiseInterval(SVector(-2.0,-1.0,0.0,1.0,2.0))
I_analytic = PiecewiseInterval(SVector(Array(-4.0:1.0:4.0)))
@test I ≈ conv(I,I)
