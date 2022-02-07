module Types

export Signal, Condition, SyncCondition

struct Signal
	width::Int32
end

struct Condition
end

struct SyncCondition
	signal::Signal
	posedge::Bool
end

end
