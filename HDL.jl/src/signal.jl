include("types.jl")

function signal(width=1; pin=0)
	return Signal(width, pin)
end

function input(width=1; pin=0)
	return signal(width, pin=pin)
end

function output(width=1; pin=0)
	return signal(width, pin=pin)
end

function posedge(sig::Signal)
	cond = SyncCondition(sig, true)
	return cond
end

function negedge(sig::Signal)
	cond = SyncCondition(sig, false)
	return cond
end
