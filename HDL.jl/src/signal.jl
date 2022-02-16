include("types.jl")

function signal(width=1; pin=0, name="")
	s = Signal(width, pin, name, nothing)
	if scope.component !== nothing
		push!(scope.component.signals, s)
	end
	return s
end

function input(width=1; pin=0, name="")
	s = Input(width, pin, name, nothing)
	if scope.component !== nothing
		push!(scope.component.inputs, s)
	end
	return s
end

function output(width=1; pin=0, name="")
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
	res = input(s.width, pin=s.pin, name=s.name)
	res.created_from = s
	scope.component = prev
	return res
end

function Base.convert(::Type{T}, s::Union{Signal, Input}) where {T<:Output}
	prev = scope.component
	scope.component = nothing
	res = output(s.width, pin=s.pin, name=s.name)
	res.created_from = s
	scope.component = prev
	return res
end
