export
	comb,
	component,
	link,
	otherwise,
	sync,
	when

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
	new_block(f, cond, true, "a synchronous")
end

function comb(f::Function)
	new_block(f)
end

function new_conditional(f::Function, cond::Union{Condition, Nothing}, cond_type::ConditionType)
	current_scope = scope.current
	if current_scope === nothing
		current_scope = scope.block
	end

	if current_scope === nothing
		error("`when` expects a parent scope")
	end

	conditional = ConditionBlock(cond, cond_type, [], [])
	prev_scope = scope.current
	scope.current = conditional
	f()
	scope.current = prev_scope
	push!(current_scope.scopes, conditional)

	return conditional
end

function when(f::Function, cond::Condition)
	new_conditional(f, cond, ct_when)
end

function when(f::Function, s::BaseSignal)
	cond = Condition(s, nothing, "")
	return when(f, cond)
end

function otherwise(f::Function, cond::Union{Condition, Nothing}=nothing)
	new_conditional(f, cond, ct_otherwise)
end

function otherwise(f::Function, s::BaseSignal)
	cond = Condition(s, nothing, "")
	return otherwise(f, cond)
end

function component(f::Function, name::String, ioType=Nothing)
	Component{ioType}(name, f, [], ioType, nothing, [], [], [], [], [], false)
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
