local loops = {}

local createdLoops = {}
local events = {}

function loops:CreateLoop(name, callback, interval)
	if createdLoops[name] ~= nil then
		warn("You're replacing loops by reusing the name! You may not want that!")
		createdLoops[name]:Unbind()
	end
	
	local funcs = {}
	local floop = true
		
	task.spawn(function()
		while task.wait(interval) and floop do
			callback()
		end
	end)
	
	function funcs:Unbind()
		createdLoops[name] = nil
		floop = false
	end
	
	createdLoops[name] = funcs
	
	return funcs
end

function loops:UnbindLoop(name)
	if createdLoops[name] ~= nil then
		createdLoops[name]:Unbind()
	else
		warn("Loop with name "..name.." does not exist!")
	end
end

function loops:AddRobloxEvent(a: RBXScriptConnection)
	table.insert(events,a)
end

function loops:UpdateRobloxEvents()
	for _,v: RBXScriptConnection in pairs(events) do
		if not v.Connected then
			table.remove(events,table.find(events,v))
		end
	end
end

function loops:UnbindAll()
	for i,v in pairs(createdLoops) do
		v:Unbind()
	end
	for i,v in pairs(events) do
		v:Disconnect()
	end
end

return loops
