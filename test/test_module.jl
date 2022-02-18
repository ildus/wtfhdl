#!/usr/bin/env julia

module TestModule

include("../HDL.jl/src/HDL.jl")
using .HDL

mutable struct RAM <: HDL.Bundle
	clk::Input
	addr::Input
	we::Input
	wdata::Input
	rdata::Output
end

# TODO: addr_with, data_witdh parameters
ram = component("ram", RAM) do io
	addr = signal("ram_addr", io.addr.width)
	bram = array("bram", io.rdata.width, 2 ^ addr.width)

	sync(posedge(io.clk)) do
		addr <= io.addr

		when(io.we) do
			bram[io.addr] <= io.wdata
		end
	end

	comb() do
		io.rdata <= bram[addr]
	end
end

mutable struct TopCtrl <: HDL.Bundle
	clk::Input
	led1::Output
end

# TODO: add io for Top, with fields like Input{5}
top = component("top", TopCtrl) do io
	ram_out = signal("ram_out", 5)

	ram_ctrl = RAM(io.clk, signal(5), signal(), signal(16), signal(16))
	link(ram, ram_ctrl)

	sync(posedge(io.clk)) do
		#ram_out <= ram_ctrl.val + 1
	end

	comb() do
	end
end

function main()
	top_ctrl = TopCtrl(signal(), signal())
	link(top, top_ctrl)
	s = synth(top)
	println(s)
end

main()

end
