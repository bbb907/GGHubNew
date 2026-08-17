local loops = {}

local createdLoops = {}

function loops:CreateLoop(name, callback, interval)
	if createdLoops[name] ~= nil then
		warn("You're replacing loops by reusing the name! You may not want that!")
		createdLoops[name]:Unbind()
	end
	
	local funcs = {}
	local floop = coroutine.create(function()
		while task.wait(interval) do
			callback()
		end
	end)
	
	function funcs:Unbind()
		createdLoops[name] = nil
		floop.close()
	end
	
	createdLoops[name] = funcs
	
	floop.resume()
	
	return funcs
end

return loops
