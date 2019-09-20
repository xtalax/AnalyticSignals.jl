abstract type SignalFunction{Dims,Amplitude,Scaling,Offset} <: Function end

triangle(t) = -1<t<1 ? (t >0 ? -t+1 : t+1) : zero(t)
Windows.rect(t) = -1/2 <= t <= 1/2 ? one(t) : zero(t)

struct ElementaryFunction{Order, Dims, Amplitude, Scaling, Offset} <: SignalFunction{Dims,Amplitude,Scaling,Offset}
    ElementaryFunction{Order, Dims}() = new{Order, Dims, 1, SVector(ones(Int, Dims)), SVector(zeros(Int, Dims))}()
end

Const{N, A, S, O} = ElementaryFunction{SVector(zeros(Int,N)), N, A, S, O}
Rect{N, A, S, O} = ElementaryFunction{SVector(ones(Int,N)), N, A, S, O}
Triangle{N, A, S, O} = ElementaryFunction{SVector(fill(2,N)), N, A, S, O}
Spline{Order, N, A, S, O} = ElementaryFunction{SVector(fill(Order, N)), N, A, S, O}
Gaussian{N, A, S, O} = ElementaryFunction{Inf, N, A, S, O}

Rect{N}() = ElementaryFunction{0,N}()
Triangle{N}() = ElementaryFunction{1.N}()
Spline{N}(order::Int = 2) = ElementaryFunction{order, N}()
Gaussian{N}() = ElementaryFunction{Inf,N}()

function support(T, ::ElementaryFunction{order, N, A, scaling, offset}) where {order, N, A, scaling, offset}
    if order isa Real
        domain = SVector{N, Interval{T}}(convert(T, -order*scaling[d]/2 + offset[d])..convert(T, order*scaling[d]/2 + offset[d]) for d in 1:N)
    elseif order isa SVector
        domain = SVector{N, Interval{T}}((convert(T,-order[d]*scaling[d]/2 + offset[d])..convert(T, order[d]*scaling[d]/2 + offset[d]) for d in 1:N)
    else
        throw(ArgumentError("Critical error, the order should never be of this type, got typeof(order)"))
    end
    return domain
end

for op in (:*, :/, :\)
    @eval Base.$op(x::Number, ::ElementaryFunction{K,D,A,S,O}) where {K,D,A,S,O} = ElementaryFunction{K,D,$op(A,x),S,O}()
    @eval Base.$op(::ElementaryFunction{K,D,A,S,O}, x::Number) where {K,D,A,S,O} = ElementaryFunction{K,D,$op(x,A),S,O}()
end

function (::Rect{Dims,Amplitude,Scaling, Offset})(t̄::Vararg{Dims, T}) where {T, Order,Dims,Amplitude,Scaling, Offset}
    if all(t̄ .∈ support(::Rect{Dims,Amplitude,Scaling, Offset}))
        return Amplitude
    else
        return zero(typeof(Amplitude))
    end
end

function (::Triangle{D,A,S,O})(t̄::Vararg{Dims, T}) where {T,D,A,S,O}
    if all(t̄ .∈ support(T, ::Triangle{D,A,S,O}))
        return A*(1-abs(t/s.-offset))
    else
        return zero(typeof(Amplitude))
    end
end

function get_new_order(K1::SVector{N,T}, K2::SVector{N,T})
    order = zeros(Int, N)
    for (i,K) in enumerate(zip(K1, K2))
        order[i] = maximum(K)
    end
    return order
end


function conv(::ElementaryFunction{K1, D1, A1, S, O1}, ::ElementaryFunction{K2, D2, A2, S, O2}) where {K1, D1, A1, S, O1, K2, D2, A2, S, O2, N, I}
    get_new_order(K1, K2)

    return ElementaryFunction{K, maximum([D1,D2]), A1*A2, S, O1 .+ O2}()
end
