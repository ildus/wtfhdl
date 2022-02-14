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

	s *= "module " * c.name * "()\n"
	s *= "begin\n"
	for b in c.scopes
		s *= synth(b)
	end
	s *= "end\n"

	scope.component = nothing
	return s
end

function synth(b::Block)
	s = ""
	if b.sync
		s *= "always_ff ("
		s *= synth(b.cond)
	else
		s *= "always_comb ("
	end

	s *= ") begin\n"
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
