local events = {}

local listeners = {}

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()

local events = {
	["Death"] = {},
	["Respawn"] = {}
}

function events.addEvent(name,typ,func)
	events[typ][name] = func
end

function events.removeEvent(name,typ)
	events[typ][name] = nil
end

local function createDeathEvent()
	if listeners["Death"] ~= nil then
		listeners["Death"]:Disconnect()
	end
	
	listeners["Death"] = char:WaitForChild("Humanoid").Died:Connect(function()
		for _,v in pairs(events["Death"]) do
			v()
		end
		
		char = plr.Character or plr.CharacterAdded:Wait()
		
		task.wait()
		
		for _,v in pairs(events["Respawn"]) do
			v()
		end
		
		createDeathEvent()
	end)
end

function events.init()
	createDeathEvent()
end

return events
