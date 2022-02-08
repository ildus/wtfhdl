module HDL

export Component, signal, component
export sync, comb, when, otherwise

include("signal.jl")

current_component = Nothing

function sync(SyncCondition)
end

function comb(::Any)
end

function when(::Any)
end

function otherwise(::Any)
end

function component(::Any, name::String)
	current_component = Component(name)
	return current_component
end

function signal(width::UInt8=0x1)
	return Signal(current_component, width)
end

end
