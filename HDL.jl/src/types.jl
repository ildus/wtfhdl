abstract type LValue end
abstract type Scope end

struct Signal <: LValue
    width::Int32
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

struct Component
    name::String
    scopes::Array{Block}
end

mutable struct CurrentScope
    component::Union{Component,Nothing}
    block::Union{Block,Nothing}
    conditional::Union{ConditionBlock,Nothing}
end
