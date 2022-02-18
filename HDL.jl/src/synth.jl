using Printf
import Base.:+

export synth

function add_text(s::String, fmt::String, args...)
	f = Printf.Format(fmt)
	return s *= (" " ^ (scope.level * 4)) * Printf.format(f, args...)
end

function add_line(s::String, fmt::String, args...)
	f = Printf.Format(fmt)
	return s *= (" " ^ (scope.level * 4)) * Printf.format(f, args...) * "\n"
end

function synth(c::Component, b::Union{Bundle, Nothing}=nothing)
	if c.synthed
		return ""
	end

	scope.component = c
	nargs = first(methods(scope.component.process)).nargs
	if nargs == 1
		scope.component.process()
	elseif nargs == 2
		if c.bundle !== nothing
			scope.component.process(c.bundle)
		elseif b !== nothing
			scope.component.process(b)
		end
	else
		error("could not dispatch component's body function")
	end

	s = ""
	for l in c.links
		s *= synth(l)
		s *= "\n"
	end

	s *= "module " * c.name * "(\n"
	for (i, input) in enumerate(c.inputs)
		s *= "    input " * synth_def(input)
		if (i != length(c.inputs) || length(c.outputs) > 0)
			s *= ","
		end
		s *= "\n"
	end
	for (i, output) in enumerate(c.outputs)
		s *= "    output " * synth_def(output)
		if (i != length(c.outputs))
			s *= ","
		end
		s *= "\n"
	end
	s *= ");\n"

	if length(c.signals) > 0
		s *= "\n"
		for sig in c.signals
			s = add_line(s, "%s", synth_def(sig))
		end
	end

	if length(c.signals) > 0
		s *= "\n"
		for arr in c.arrays
			s = add_line(s, "%s", synth(arr))
		end
	end

	if length(c.signals) > 0
		s *= "\n"
		for b in c.scopes
			s = add_line(s, "%s", synth(b))
		end
	end

	# modules
	if length(c.links) > 0
		s *= "\n"
		for l in c.links
			inst_name = l.name * "_" * string(scope.inst_counter)
			scope.inst_counter = scope.inst_counter + 1
			s *= l.name * " " * inst_name * "("
			if l.bundle !== nothing
				names = fieldnames(typeof(l.bundle))
				for (i, name) in enumerate(names)
					field = getfield(l.bundle, name)
					if field.created_from !== nothing
						s *= field.created_from.name
					else
						s *= field.name
					end
					if i != length(names)
						s *= ","
					end
				end
			end

			s *= ");\n\n"
		end
	end

	s *= "endmodule\n"

	scope.component = nothing
	return s
end

function synth(b::Block)
	s = ""
	if b.sync
		s *= "always_ff ("
		s *= synth(b.cond)
		s *= ") begin\n"
	else
		s *= "always_comb begin\n"
	end

	scope.level += 1
	if length(b.assigns) > 0
		for a in b.assigns
			s = add_line(s, "%s", synth(a, sync=b.sync))
		end
	end

	if length(b.scopes) > 0
		for scope in b.scopes
			s = add_text(s, "%s", synth(scope))
		end
	end
	scope.level -= 1

	s *= "end\n"
	return s
end

function synth(c::SyncCondition)
	s = ""
	if c.posedge
		s *= "posedge " * c.signal.name
	else
		s *= "negedge " * c.signal.name
	end
	return s
end

function synth_def(sig::BaseSignal)
	s = "logic "
	if sig.name == ""
		sig.name = "sig_" * string(scope.signal_counter)
		scope.signal_counter += 1
	end

	if sig.width > 1
		s *= @sprintf("[%d:0] %s", sig.width - 1, sig.name)
	else
		s *= sig.name
	end

	if isa(sig, Union{Signal, Output})
		if sig.default !== nothing
			s *= " = " * synth(sig.default)
		end
	end

	return s
end

function synth(sig::BaseSignal)
	return sig.name
end

function synth(sig::ArrayIndex)
	return sig.array.name * "[" * synth(sig.index) * "]"
end

function synth(b::ConditionBlock)
	s = "if "
	s *= synth(b.cond)
	s *= " begin\n"

	scope.level += 1
	for a in b.assigns
		s = add_line(s, "%s", synth(a, sync=scope.block.sync))
	end
	scope.level -= 1
	s = add_line(s, "%s", "end")
	return s
end

function synth(c::Condition)
	s = "("
	if c.b === nothing
		# unary
		s *= c.op
		s *= synth(c.a)
	end
	s *= ")"
	return s
end

function synth(a::Assign; sync::Bool)
	op = sync ? " <= " : " = "
	s = ""
	s *= synth(a.left)
	s *= op
	s *= synth(a.right)
	return s
end

# logic [DATA_WIDTH - 1:0] bram [0 : 2 ** ADDR_WIDTH - 1];
function synth(arr::SignalArray)
	s = @sprintf("logic [%d:0] %s [0:%d];", arr.element_width - 1, arr.name, arr.count - 1)
	return s
end

function synth(op::Op)
	s = "("
	if op.b === nothing
		s *= op.op
		s *= synth(op.a)
	else
		s *= synth(op.a)
		s *= " " * op.op * " "
		s *= synth(op.b)
	end
	s *= ")"
	return s
end

function synth(n::Number)
	return string(n)
end
