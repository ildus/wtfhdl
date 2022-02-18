include("types.jl")

export array, signal, input, output, posedge, negedge

function signal(width=1; pin=0, name="", default=nothing)
	s = Signal(width, pin, name, nothing, default)
	if scope.component !== nothing
		push!(scope.component.signals, s)
	end
	return s
end

function signal(name::String, width=1; pin=0, default=nothing)
	return signal(width, pin=pin, name=name, default=default)
end

function input(name, width=1; pin=0)
	s = Input(width, pin, name, nothing)
	if scope.component !== nothing
		push!(scope.component.inputs, s)
	end
	return s
end

function output(name, width=1; pin=0, default=nothing)
	s = Output(width, pin, name, nothing, default)
	if scope.component !== nothing
		push!(scope.component.outputs, s)
	end
	return s
end

function array(name, element_width, count)
	arr = SignalArray(name, element_width, count)
	if scope.component !== nothing
		push!(scope.component.arrays, arr)
	end
	return arr
end

function Base.copy(s::Input)
	return Input(s.width, s.pin, s.name, s)
end

function Base.copy(s::Output)
	return Output(s.width, s.pin, s.name, s, s.default)
end

function posedge(sig::BaseSignal)
	cond = SyncCondition(sig, true)
	return cond
end

function negedge(sig::BaseSignal)
	cond = SyncCondition(sig, false)
	return cond
end

function Base.convert(::Type{T}, s::Union{Signal, Output}) where {T<:Input}
	prev = scope.component
	scope.component = nothing
	res = input(s.name, s.width, pin=s.pin)
	res.created_from = s
	scope.component = prev
	return res
end

function Base.convert(::Type{T}, s::Union{Signal, Input}) where {T<:Output}
	prev = scope.component
	scope.component = nothing
	res = output(s.name, s.width, pin=s.pin)
	res.created_from = s

	# if signal goes to output, we move default value to it
	if s.default !== nothing
		res.default = s.default
		s.default = nothing
	end

	scope.component = prev
	return res
end
