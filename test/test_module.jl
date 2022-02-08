module TestModule

include("../HDL.jl/src/HDL.jl")
using .HDL

top = component("top") do
	clk = signal()
	a = signal(5)

	sync(posedge(clk)) do
		when() do
			a <= a + 1

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
