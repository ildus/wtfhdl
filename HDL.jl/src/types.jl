abstract type LValue end
abstract type Scope end
abstract type Bundle end
abstract type BaseComponent end

struct Signal <: LValue
    width::Int64
	pin::Int64
	component::Union{BaseComponent, Nothing}
	name::String
end

struct Slice <: LValue
    signal::Signal
end

struct SyncCondition
    signal::Signal
    posedge::Bool
end

struct Condition end

struct Op
    a::Any
    b::Any
    op::String
    unary::Bool
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
	inputs::Array{Signal}
	links::Array{Component}
	synthed::Bool
end

mutable struct CurrentScope
    component::Union{Component,Nothing}
    block::Union{Block,Nothing}
    conditional::Union{ConditionBlock,Nothing}
end
