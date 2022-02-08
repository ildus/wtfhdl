scope = CurrentScope(nothing, nothing, nothing)

function sync(f::Function, cond::SyncCondition)
	block = Block(sync=true, cond=cond)
	push!(scope.component.scopes, block)
	scope.block = block
	f()
	return block
end

function comb(::Any)
end

function when(f::Function, cond::Condition)
	block = ConditionBlock(cond=cond)
	push!(scope.block.scopes, block)
	f()
	return block
end

function otherwise(::Any)
end

function component(::Any, name::String)
	c = Component(name, [])
	scope.component = c
	return c
end

function signal(width::UInt8=0x1)
	return Signal(width=width)
end
