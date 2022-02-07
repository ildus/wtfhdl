module HDL

export sync, comb, when, otherwise

include("signal.jl")
using Signals

struct Condition
end

struct Module
end

mutable struct Block
	sync::Bool
end

function sync(::Any)
end

function comb(::Any)
end

function when(::Any)
end

function otherwise(::Any)
end

end
