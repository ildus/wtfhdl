function +(a::Union{LValue, Op}, b)
	op = Op(a=a, b=b, op="+", false)
	return op
end

function <=(a::LValue, b)
	assign = Assign(left=a, right=b)
	return assign
end
