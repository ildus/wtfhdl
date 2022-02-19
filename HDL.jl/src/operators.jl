function Base.:<=(left::LValue, right::Operand)
	a = Assign(left,right)
	push!(scope.current.assigns, a)
	return a
end

export ⇐

function ⇐(left::LValue, right::Operand)
	left <= right
end

function Base.:getindex(left::SignalArray, index::Union{Operand, Number})
	ArrayIndex(left, index)
end

function Base.:^(left::Operand, right::Operand)
	Op(left,right, "^")
end

function Base.:!(oper::Operand)
	Condition(oper,nothing, "!")
end

function Base.:+(left::Operand, right::Operand)
	Op(left, right, "+")
end
