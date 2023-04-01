@reexport module Idents
export Ident
"""`Ident{T}` is a meta type wrapping around `T` to provide a unique type for each `T`. This is
especially useful for dispatching on specific values such as `Ident{:MySymbol}`, and allows
implementing a sort of `switch` statement through multiple dispatch.
"""
struct Ident{T} end
end # module Idents
