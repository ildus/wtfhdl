abstract type LValue end
abstract type Scope end
abstract type Bundle end
abstract type BaseComponent end
abstract type BaseSignal <: LValue end

mutable struct Signal <: BaseSignal
    width::Int64
	pin::Int64
	name::String
end

mutable struct Input <: BaseSignal
    width::Int64
	pin::Int64
	name::String
end

mutable struct Output <: BaseSignal
    width::Int64
	pin::Int64
	name::String
end

# TODO: add methods
struct InOut <: BaseSignal
    width::Int64
	pin::Int64
	name::String
end

struct Slice <: LValue
    signal::BaseSignal
end

struct SyncCondition
    signal::BaseSignal
    posedge::Bool
end

struct Op
	a::Union{BaseSignal, Op}
	b::Union{BaseSignal, Op, Nothing}
    op::String
end

struct Condition
	a::Union{BaseSignal, Op}
	b::Union{BaseSignal, Op, Nothing}
	op::String
end

struct Assign
    left::LValue
    right::Op
end

mutable struct ConditionBlock <: Scope
    cond::Condition
    scopes::Array{ConditionBlock}
end

mutable struct Block <: Scope
    sync::Bool
	cond::Union{SyncCondition, Nothing}
    scopes::Array{ConditionBlock}
end

mutable struct Component{T <: Union{Bundle,Nothing}} <: BaseComponent
    name::String
	process::Function
	scopes::Array{Block}
	ioType::Type
	bundle::Union{T,Nothing}
	inputs::Array{Input}
	outputs::Array{Input}
	links::Array{Component}
	synthed::Bool
end

mutable struct CurrentScope
    component::Union{Component,Nothing}
    block::Union{Block,Nothing}
    conditional::Union{ConditionBlock,Nothing}
end
