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

ram = component("ram", RAM) do io
	sync(posedge(io.clk)) do
	end

	comb() do
	end
end

top = component("top") do
	clk = input("clk")

	ram_ctrl = RAM(clk, signal("addr", 5), signal("write", 16), signal("val"))
	link(ram, ram_ctrl)

	sync(posedge(clk)) do
	end

	comb() do
	end
end

s = synth(top)
println(s)

end
