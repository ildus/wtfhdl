#!/usr/bin/env julia

module TestModule

include("../HDL.jl/src/HDL.jl")
using .HDL

struct RAM <: HDL.Bundle
	clk
	addr
	write
	val
end

ram = component("ram", RAM) do
end

top = component("top") do
	clk = input()

	ram_ctrl = RAM(clk, signal(5), signal(16), signal)
	link(ram, ram_ctrl)

	sync(posedge(clk)) do
		when() do
			otherwise() do
			end
			otherwise() do
			end
		end
	end

	comb() do
	end
end

s = synth(top)
println(s)

end
