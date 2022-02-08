include("types.jl")

function posedge(sig::Signal)
	cond = SyncCondition(sig)
	return cond
end

function negedge(sig::Signal)
	cond = SyncCondition(sig)
	return cond
end
