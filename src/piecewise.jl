function piecewise(x::Symbol,c::Expr,f::Expr) # from https://stackoverflow.com/questions/27664881/define-piecewise-functions-in-julia
  n=length(f.args)
  @assert n==length(c.args)
  @assert c.head==:vect
  @assert f.head==:vect
  vf=Vector{Function}(n)
  for i in 1:n
    vf[i]=@eval $x->$(f.args[i])
  end
  return @eval ($x)->($(vf)[findfirst($c)])($x)
end
