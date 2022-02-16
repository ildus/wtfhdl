scope = CurrentScope(nothing, nothing, nothing, 0)

function sync(f::Function, cond::SyncCondition)
	if scope.component === nothing
		error("a synchronous block can be defined only in a component")
	end

	block = Block(true, cond, [])
	push!(scope.component.scopes, block)
	scope.block = block
	f()
	return block
end

function comb(f::Function)
	if scope.component === nothing
		error("an asynchronous block can be defined only in a component")
	end

	block = Block(false, nothing, [])
	push!(scope.component.scopes, block)
	scope.block = block
	f()
	return block
end

function when(f::Function, cond::Condition)
	block = ConditionBlock(cond, [])
	push!(scope.block.scopes, block)
	f()
	return block
end

function when(f::Function, s::BaseSignal)
	cond = Condition(s, nothing, "")
	return when(f, cond)
end

function otherwise(::Any)
end

function component(f::Function, name::String, ioType=Nothing)
	c = Component{ioType}(name, f, [], ioType, nothing, [], [], [], [], false)
	return c
end

function link(c::Component, b::Bundle)
	if scope.component === nothing
		error("link")
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

	push!(scope.component.links, c)
end
