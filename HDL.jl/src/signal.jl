include("types.jl")

function signal(width=1; pin=0, component=nothing, name="")
	return Signal(width, pin, component, name)
end

function input(width=1; pin=0, name="")
	if (scope.component === nothing)
		error("input should be defined in a component scope")
	end

	s = Input(width, pin, component, name)
	push!(scope.component.inputs, s)
	return s
end

function output(width=1; pin=0, name="")
	return signal(name, width, pin=pin)
end

function posedge(sig::Signal)
	cond = SyncCondition(sig, true)
	return cond
end

function negedge(sig::Signal)
	cond = SyncCondition(sig, false)
	return cond
end
