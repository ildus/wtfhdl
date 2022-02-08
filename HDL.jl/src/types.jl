struct Component
	name::String
end

mutable struct Block
	sync::Bool
end

struct Signal
	mod::Component
	width::Int32
end

struct Condition
end

struct SyncCondition
	signal::Signal
	posedge::Bool
end
