# KirUtils
KirUtils is a collection of simple data structures & algorithms which I find myself commonly reimplementing in various projects. For example, the `Ident{:symbol}` meta type can be used effectively in multiple dispatch to act as a switch statement, and the `Unknown` type represents a value which may or may not be loaded.

## Types

### Ident
`Ident` is short for `Identifier`. It is primarily intended to be used with Symbols, and allows the Julia runtime to dispatch a function call based on symbol values by wrapping it in a meta type. This allows building a switch-like family of functions:

```julia
using KirUtils.Idents

struct Foo
  name
end

my_dispatcher(foo::Foo) = _dispatched(Ident{foo.name}())

_dispatched(::Ident{:SomeValue}) = "some value"
_dispatched(::Ident{:OtherValue}) = "other value"
_dispatched(::Ident{42}) = 42

println(my_dispatcher(Foo(42)))
# 42
```

### Unknown
`Unknown{T}` represents a value of type `T` which may or may not be currently loaded. When unloaded, its `value` will be `unknown`, which is an instance of `Unknown{Nothing}`. You may test whether an `Unknown` is loaded by comparing its `value` against `unknown`, or by calling `isunknown(my_unknown)`.

You can simply assign the `value` of an `Unknown` or clear it by assigning `unknown` to it. Alternatively, you may call `KirUtils.Unknowns.load` to load the value using the assigned loader, if any; and `KirUtils.Unknowns.unload` to clear the value.

`Unknown`s are especially useful for locally resembling a remote value for which retrieval may cost valuable runtime. This applies to both values retrieved from a remote database, but also values stored elsewhere in the local system such as the filesystem or in a GPU buffer.

```julia
using KirUtils.Unknowns

# initially unloaded Unknown{Any}
val = Unknown()

# Unknown{Int}
val = Unknown(42)

# Unknown{Any} w/ loader
val = Unknown(() -> 42)

# load "remote" value
Unknowns.load(val)
println(val.value) # 42

# unload cached value - equivalent to `val.value = unknown`
Unknowns.unload(val)
println(val.value) # unknown
```
