#!/usr/bin/env julia

module TestModule

include("../HDL.jl/src/HDL.jl")
using .HDL

struct RAM <: HDL.Bundle
	clk::Input
	addr::Input
	we::Input
	wdata::Input
	rdata::Output
end

# TODO: addr_with, data_witdh parameters
ram = component("ram", RAM) do io
	addr = signal(io.addr.width, name="addr")
	#bram = array(signal(), 10)

	sync(posedge(io.clk)) do
		#addr <= io.addr

		when(io.we) do
			#bram[io.addr] <= io.wdata
		end
	end

	comb() do
		#io.rdata <= bram[addr]
	end
end

# TODO: add io for Top, with fields like Input{5}
top = component("top") do
	clk = input(name="clk")
	led1 = output(name="led1")

	ram_out = signal(5, name="ram_out")

	ram_ctrl = RAM(clk, signal(5), signal(), signal(16), signal(16))
	link(ram, ram_ctrl)

	sync(posedge(clk)) do
		#ram_out <= ram_ctrl.val + 1
	end

	comb() do
	end
end

s = synth(top)
println(s)

end
