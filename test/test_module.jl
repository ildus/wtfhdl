module TestModule

push!(LOAD_PATH, abspath(dirname(@__FILE__) * "/.."))

using HDL

top = component("top") do
	clk = signal(5)

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

end
