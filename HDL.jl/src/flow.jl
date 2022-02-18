export
	comb,
	component,
	link,
	otherwise,
	sync,
	when

scope = CurrentScope(nothing, nothing, nothing, 0)

function new_block(f::Function, cond::Union{SyncCondition,Nothing}=nothing, sync=false, block_type="an asynchronous")
	if scope.component === nothing
		error(block_type * " block can be defined only in a component")
	end

	block = Block(sync, cond, [], [])
	push!(scope.component.scopes, block)
	scope.block = block
	scope.current = block
	f()
	scope.current = nothing
	return block
end

function sync(f::Function, cond::SyncCondition)
	return new_block(f, cond, true, "a synchronous")
end

function comb(f::Function)
	return new_block(f)
end

function when(f::Function, cond::Condition)
	if scope.block === nothing
		error("`when` expects parent sync or comb blocks")
	end

	block = ConditionBlock(cond, [], [])
	prev_scope = scope.current
	scope.current = block
	f()
	scope.current = prev_scope
	push!(scope.block.scopes, block)
	return block
end

function when(f::Function, s::BaseSignal)
	cond = Condition(s, nothing, "")
	return when(f, cond)
end

function otherwise(::Any)
	if scope.block === nothing
		error("`otherwise` expects parent `when` block")
	end
end

function component(f::Function, name::String, ioType=Nothing)
	c = Component{ioType}(name, f, [], ioType, nothing, [], [], [], [], [], false)
	return c
end

function link(c::Component, b::Bundle)
	names = fieldnames(typeof(b))
	for name in names
		field = getfield(b, name)
		if field.created_from === nothing
			# we should make a copy of a field and use in the bundle instead of original signal
			field_copy = copy(field)
			setfield!(b, name, field_copy)
		end
	end

	# extract names for signals
	names = fieldnames(typeof(b))
	for name in names
		field = getfield(b, name)
		field.name = string(name)
		if field.created_from !== nothing && field.created_from.name == ""
			field.created_from.name = c.name * "_" * string(name)
		end

		if isa(field, Input)
			push!(c.inputs, field)
		elseif isa(field, Output)
			push!(c.outputs, field)
		end
	end

	if c.bundle === nothing
		if typeof(b) == c.ioType
			c.bundle = b
		else
			error("wrong type of bundle for " * c.name)
		end
	end

	if scope.component !== nothing
		push!(scope.component.links, c)
	end
end
