module Debounce

include("../HDL.jl/src/HDL.jl")
using .HDL

mutable struct DebounceCtrl <: HDL.Bundle
	clk::Input
	button_in_1::Input
	button_in_2::Input
	raised::Output
end

debounce_3pin = component("debounce_3pin", DebounceCtrl) do io
	init = signal(default=0)
	old_pin1 = signal(default=0)
	old_pin2 = signal(default=0)
	pin1 = signal()
	pin2 = signal()
	out = signal()
	pinout = signal()

	# set default output
	io.raised.default = 0

	comb() do
		out ≔ io.button_in_1 ^ io.button_in_2
		pinout ≔ pin1 ^ pin2
	end

	sync(posedge(out)) do
		pin1 ≔ io.button_in_1
		pin2 ≔ io.button_in_2
	end

	sync(posedge(io.clk)) do
		when(!init) do
			old_pin1 ≔ io.button_in_1
			old_pin2 ≔ io.button_in_2
			init ≔ 1

			otherwise() do
				#when(pinout && pin1 != old_pin1 && pin2 != old_pin2) do
				when(pinout) do
					io.raised ≔ 1;
					old_pin1 ≔ pin1;
					old_pin2 ≔ pin2;

					otherwise() do
						io.raised ≔ 0;
					end
				end
			end
		end
	end
end


function main()
	ctrl = DebounceCtrl(signal(), signal(), signal(), signal())
	link(debounce_3pin, ctrl)
	s = synth(debounce_3pin)
	println(s)
end

main()

end
