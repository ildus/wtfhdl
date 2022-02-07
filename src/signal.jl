module Signals

export posedge, negedge

include("types.jl")
using .Types

function posedge(sig::Signal)
	cond = SyncCondition(sig)
	return cond
end

function negedge(sig::Signal)
	cond = SyncCondition(sig)
	return cond
end

end
