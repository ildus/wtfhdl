include("types.jl")

function posedge(sig::Signal)
	cond = SyncCondition(sig, true)
	return cond
end

function negedge(sig::Signal)
	cond = SyncCondition(sig, false)
	return cond
end
