module TestModule

include("../src/hdl.jl")

using .HDL

function run_test()
	hdl = Signal()
	println("test")
end

clk = Signal(5)

sync() do
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
