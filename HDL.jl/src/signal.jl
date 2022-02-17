include("types.jl")

function signal(width=1; pin=0, name="")
	s = Signal(width, pin, name, nothing)
	if scope.component !== nothing
		push!(scope.component.signals, s)
	end
	return s
end

function signal(name::String, width=1; pin=0)
	return signal(width, pin=pin, name=name)
end

function input(name, width=1; pin=0)
	s = Input(width, pin, name, nothing)
	if scope.component !== nothing
		push!(scope.component.inputs, s)
	end
	return s
end

function copy(s::Input)
	return Input(s.width, s.pin, s.name, s)
end

function copy(s::Output)
	return Output(s.width, s.pin, s.name, s)
end

function output(name, width=1; pin=0)
	s = Output(width, pin, name, nothing)
	if scope.component !== nothing
		push!(scope.component.outputs, s)
	end
	return s
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
	scope.component = prev
	return res
end
