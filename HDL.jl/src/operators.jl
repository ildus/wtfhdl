function Base.:<=(left::LValue, right::Operand)
	a = Assign(left,right)
	push!(scope.current.assigns, a)
	return a
end

function Base.:getindex(left::SignalArray, index::Union{Operand, Number})
	index = ArrayIndex(left, index)
	return index
end

function Base.:^(left::Operand, right::Operand)
	res = Op(left,right, "^")
	return res
end

function Base.:!(oper::Operand)
	res = Condition(oper,nothing, "!")
	return res
end

function Base.:+(left::Operand, right::Operand)
	res = Op(left, right, "+")
	return res
end
