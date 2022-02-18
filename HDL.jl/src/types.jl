export
	Input,
	Output,
	InOut

abstract type LValue end
abstract type Scope end
abstract type Bundle end
abstract type BaseComponent end
abstract type BaseSignal <: LValue end

SignalDefault = Union{Integer, Nothing}

mutable struct Signal <: BaseSignal
    width::Int64
	pin::Int64
	name::String
	created_from::Union{BaseSignal, Nothing}
	default::SignalDefault
end

mutable struct Input <: BaseSignal
    width::Int64
	pin::Int64
	name::String
	created_from::Union{BaseSignal, Nothing}
end

mutable struct Output <: BaseSignal
    width::Int64
	pin::Int64
	name::String
	created_from::Union{BaseSignal, Nothing}
	default::SignalDefault
end

mutable struct SignalArray
	name::String
	element_width::Int64
	count::Int64
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

Operand = Union{BaseSignal, Op, Integer}

struct ArrayIndex <: BaseSignal
	array::SignalArray
	index::Operand
end

struct Condition
	a::Union{BaseSignal, Op}
	b::Union{Operand, Nothing}
	op::String
end

struct Assign
    left::LValue
	right::Operand
end

@enum ConditionType begin
	ct_when
	ct_otherwise
end

mutable struct ConditionBlock <: Scope
	cond::Union{Condition, Nothing}
	cond_type::ConditionType
    scopes::Array{ConditionBlock}
	assigns::Array{Assign}
end

mutable struct Block <: Scope
    sync::Bool
	cond::Union{SyncCondition, Nothing}
    scopes::Array{ConditionBlock}
	assigns::Array{Assign}
end

mutable struct Component{T <: Union{Bundle,Nothing}} <: BaseComponent
    name::String
	process::Function
	scopes::Array{Block}
	ioType::Type
	bundle::Union{T,Nothing}
	inputs::Array{Input}
	outputs::Array{Output}
	signals::Array{Signal}
	arrays::Array{SignalArray}
	links::Array{Component}
	synthed::Bool
end

mutable struct CurrentScope
    component::Union{Component,Nothing}
    block::Union{Block,Nothing}
    current::Union{Scope,Nothing}
	inst_counter
	signal_counter
	level
end

scope = CurrentScope(nothing, nothing, nothing, 0, 0, 0)
