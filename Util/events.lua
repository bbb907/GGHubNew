local events = {}

local listeners = {}

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()

local deathEvents = {}
local respawnEvents = {}

function events.onDead(func)
	table.insert(deathEvents,func)
end

function events.onRespawn(func)
	table.insert(respawnEvents,func)
end

local function createDeathEvent()
	if listeners["Death"] ~= nil then
		listeners["Death"]:Disconnect()
	end
	
	listeners["Death"] = char:WaitForChild("Humanoid").Died:Connect(function()
		for _,v in pairs(deathEvents) do
			v()
		end
		
		char = plr.Character or plr.CharacterAdded:Wait()
		
		task.wait()
		
		for _,v in pairs(respawnEvents) do
			v()
		end
		
		createDeathEvent()
	end)
end

createDeathEvent()

return events
