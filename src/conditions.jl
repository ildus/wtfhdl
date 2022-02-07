module Conditions

export Condition, SyncCondition

struct Condition
end

struct SyncCondition
	signal::Signal
	posedge::Bool
end

end
