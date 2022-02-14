include("types.jl")

function signal(name, width=1; pin=0, component=nothing)
	return Signal(width, pin, component, name)
end

function input(name, width=1; pin=0)
	if (scope.component === nothing)
		error("input should be defined in a component scope")
	end

	s = signal(name, width, pin=pin, component=scope.component)
	push!(scope.component.inputs, s)
	return s
end

function output(name, width=1; pin=0)
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
