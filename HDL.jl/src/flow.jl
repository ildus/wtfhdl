scope = CurrentScope(nothing, nothing, nothing)

function init(f::Function, c::Component)
	prev = scope.component
	scope.component = c
	f()
	scope.component = prev
end

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

function component(f::Function, name, args=Nothing)
	c = Component{args}(name, [], args, nothing)
	scope.component = c
	f()
	scope.component = nothing
	return c
end
