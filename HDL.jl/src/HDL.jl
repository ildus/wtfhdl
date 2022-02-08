module HDL

export Component, signal, component
export sync, comb, when, otherwise, posedge, negedge, synth

include("signal.jl")
include("flow.jl")
include("synth.jl")
include("oper.jl")

end
