@reexport module Unknowns
export Unknown, unknown, isunknown

"""`Unknown{T}` wraps a value of either type `T` or `typeof unknown`. It further carries a callback
function `loader` which is called when the value is requested. This allows for lazy loading of
values, especially if these values are bound by slow IO operations.

`loader` should return the value synchronously. If the process itself is asynchronous, the
overarching call to `load` itself should be wrapped in a `@async` block.

`Unknown` does not require any arguments. When an argument is passed, it will typically treat
Functions as loader. If this function is intended to be the value, pass two arguments with the
second being `() -> unknown` - `unknown` as return type is treated specially and will not be
assigned to the value when loaded.
"""
mutable struct Unknown{T}
  value::Union{T, Unknown{Nothing}}
  loader::Function
  Unknown{T}(v, loader = () -> unknown) where T = new{T}(v, loader)
  Unknown(v, loader::Function = () -> unknown) = new{typeof(v)}(v, loader)
end
Unknown{T}(loader::Function = () -> unknown) where T = Unknown{T}(unknown, loader)
Unknown(loader::Function = () -> unknown) = Unknown{Any}(unknown, loader)

"""`unknown` is a special `Unknown(nothing)` which is used to indicate that the value has not yet
been loaded. This differs from `nothing` which indicates that the value has been loaded, but is
literally `nothing`. Treat `unknown` as another sibling of the `nothing` and `missing` family.
"""
const unknown = Unknown(nothing)

Base.eltype(::Type{Unknown{T}}) where T = T
Base.show(io::IO, ::Unknown{Nothing}) = print(io, "unknown")
Base.show(io::IO, value::Unknown{T}) where T = print(io, "Unknown{$T}($(repr(value.value)))")

"""Load the value into memory from an external store if not already loaded. You may specify the
`force` keyword argument to force loading anyways.

If the value returned by the `Unknown`'s loader is itself `unknown`, the current value will not be
overridden. However, this does not apply to `nothing` or `missing`.
"""
function load(value::Unknown{T}; force::Bool = false) where T
  if force || isunknown(value)
    tmp = value.loader()::T
    if !isunknown(tmp)
      value.value = tmp
    end
  end
  return value.value
end

"""Unload the value, allowing GC to reclaim the memory. You may later then `load` it again to bring
it back into memory from the external store.
"""
unload(value::Unknown) = value.value = unknown

"""Check if the value is loaded into memory."""
isunknown(value::Unknown{Nothing}) = true
isunknown(value::Unknown) = isunknown(value.value)
isunknown(value) = value === unknown || value isa Unknown{Nothing}

end # module Unknown
