using Rewrite

@theory! begin
           #Counting
           z => FreeTheory()
           s => FreeTheory()
           e => FreeTheory()
           π => FreeTheory()
           im => FreeTheory()
           (+) => ACTheory()
           (-) => FreeTheory()
           (*) => ACTheory()
           (/) => FreeTheory()
           inv => FreeTheory()

           #Calculus
           ∂ => FreeTheory()

           # Powers/logs
           (^) => FreeTheory()
           log => FreeTheory()

           # Elementary functions
           sin => FreeTheory()
           cos => FreeTheory()
end

@rules Math [x, y, t] begin
       # Arithmetic
       x + z := x
       x + s(y) := s(x + y)

       x - z := x
       z - x := -x
       x - s(y) := s(x-y)-s(z)

       x * z := z
       x * s(y) := x + x * y

       # Division
       s(z)/x := inv(x)
       inv(x)*x := s(z)
       z/x := z
       inv(inv(x)) := x
       y*inv(x) := y/x
       (y + t)/x := y/x + y/t
       y*(x/t) := (y*x)/t
       (x/y)/t := x/(y*t)
       x/(y/t) := x*t/y

       s(y)/x := inv(x)*y + inv(x)

       inv(x)*x := s(z)


       # Powers
       x^z := s(z)
       x^s(z) := x
       x^s(y) := x^(y+s(z))
       x^(y+t) := (x^y)*(x^t)
       (x^y)^t := x^(y*t)

       # logs
       log(x, x^y) := y
       x^log(x, y) := y
       log(t, x*y) := log(t, x) + log(t, y)

       #Complex Numbers
       im := (-s(z))^(inv(s(s(z))))
       e^(im*x) := cos(x) + im*sin(x)
       e^(im*π) := -s(z)

       #Differentiation
       ∂(x, x) := s(z)
       ∂(z, t) := z
       ∂(s(x), t) := ∂(x, t)
       ∂(x + y, t) := ∂(x,t) + ∂(y,t)
       ∂(x * y, t) := ∂(x,t)*y + x*∂(y,t)
       ∂(x^y, x) := y*x^(y-s(z))
       ∂(e^x, t) := ∂(x, t)*e^x
  end
