module HDL

export
	Component,
	signal,
	input,
	output,
	component,
	sync,
	comb,
	when,
	otherwise,
	posedge,
	negedge,
	synth

include("signal.jl")
include("flow.jl")
include("synth.jl")
include("oper.jl")

end
