module HDL

export
	Component,
	comb,
	component,
	input,
	link,
	negedge,
	otherwise,
	output,
	posedge,
	signal,
	sync,
	synth,
	when

include("signal.jl")
include("flow.jl")
include("synth.jl")
include("oper.jl")

end
