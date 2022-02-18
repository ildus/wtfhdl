function Base.:<=(left::LValue, right::Union{BaseSignal, Op})
	a = Assign(left,right)
	push!(scope.current.assigns, a)
	return a
end

function Base.:getindex(left::SignalArray, index::Union{BaseSignal, Op, Number})
	index = ArrayIndex(left, index)
	return index
end
