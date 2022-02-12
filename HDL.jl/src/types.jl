abstract type LValue end
abstract type Scope end
abstract type Bundle end

struct Signal <: LValue
    width::Int64
	pin::Int64
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
    cond::SyncCondition
    scopes::Array{ConditionBlock}
end

mutable struct Component{T <: Union{Bundle,Nothing}}
    name::String
	scopes::Array{Block}
	args::Type
	bundle::Union{T,Nothing}
end

mutable struct CurrentScope
    component::Union{Component,Nothing}
    block::Union{Block,Nothing}
    conditional::Union{ConditionBlock,Nothing}
end
