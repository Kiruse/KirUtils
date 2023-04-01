@reexport module Unknowns
export Unknown, unknown, isunknown

"""`Unknown{T}` wraps a value of either type `T` or `typeof unknown`. It further carries a callback
function `loader` which is called when the value is requested. This allows for lazy loading of
values, especially if these values are bound by slow IO operations.

`loader` should return the value synchronously. If the process itself is asynchronous, the
overarching call to `load` itself should be wrapped in a `@async` block.
"""
struct Unknown{T}
  value::Union{T, unknown}
  loader::Function
end
Unknown(v) = Unknown{typeof(v)}(v)
Unknown{T}() = Unknown{T}(unknown)
Unknown() = Unknown{Any}(unknown)

"""`unknown` is a special `Unknown(nothing)` which is used to indicate that the value has not yet
been loaded. This differs from `nothing` which indicates that the value has been loaded, but is
literally `nothing`.
"""
const unknown = Unknown(nothing)

"""Load the value into memory from an external store, such as a GPU or a remote server."""
load(value::Unknown) = value.value = value.loader()
"""Unload the value, allowing GC to reclaim the memory. You may later then `load` it again to bring
it back into memory from the external store.
"""
unload(value::Unknown) = value.value = unknown

"""Check if the value is loaded into memory."""
isunknown(value::Unknown) = isunknown(value.value)
isunknown(value) = value === unknown || value isa Unknown{Nothing}

end # module Unknown
