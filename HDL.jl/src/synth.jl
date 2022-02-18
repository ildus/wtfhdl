using Printf
import Base.:+

export synth

function synth(c::Component)
	if c.synthed
		return ""
	end

	scope.component = c
	nargs = first(methods(scope.component.process)).nargs
	if nargs == 1
		scope.component.process()
	elseif nargs == 2
		scope.component.process(c.bundle)
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
		s *= "\t input " * synth_def(input)
		if (i != length(c.inputs) || length(c.outputs) > 0)
			s *= ","
		end
		s *= "\n"
	end
	for (i, output) in enumerate(c.outputs)
		s *= "\t output " * synth_def(output)
		if (i != length(c.outputs))
			s *= ","
		end
		s *= "\n"
	end
	s *= ");\n"
	for sig in c.signals
		s *= synth_def(sig)
		s *= ";\n"
	end
	for arr in c.arrays
		s *= synth(arr)
		s *= "\n"
	end

	for b in c.scopes
		s *= synth(b)
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

	if length(b.assigns) > 0
		for a in b.assigns
			s *= synth(a, sync=b.sync)
			s *= "\n"
		end
	end

	if length(b.scopes) > 0
		for scope in b.scopes
			s *= synth(scope)
		end
	end

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
		error("signal doesn't have a name!")
	end

	if sig.width > 1
		s *= @sprintf("[%d:0] %s", sig.width - 1, sig.name)
	else
		s *= sig.name
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
	for a in b.assigns
		s *= synth(a, sync=scope.block.sync)
		s *= "\n"
	end
	s *= "end\n"
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
