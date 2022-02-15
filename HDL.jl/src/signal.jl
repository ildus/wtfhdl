include("types.jl")

function signal(width=1; pin=0, name="")
	return Signal(width, pin, name)
end

function input(width=1; pin=0, name="")
	if (scope.component === nothing)
		error("input should be defined in a component scope")
	end

	s = Input(width, pin, name)
	push!(scope.component.inputs, s)
	return s
end

function output(width=1; pin=0, name="")
	if (scope.component === nothing)
		error("input should be defined in a component scope")
	end

	s = Output(width, pin, name)
	push!(scope.component.outputs, s)
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

Base.convert(::Type{T}, s::Union{Signal, Output}) where {T<:Input} =
	input(s.width, pin=s.pin, name=s.name)
Base.convert(::Type{T}, s::Union{Signal, Input}) where {T<:Output} =
	output(s.width, pin=s.pin, name=s.name)
