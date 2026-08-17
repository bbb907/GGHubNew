local btools = {}

function fetchRemote()
	local btools = fetchBtools()
	
	if btools then
		return btools.SyncAPI.ServerEndpoint
	end
end

function fetchBtools()
	for _,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
		if v:IsA("Tool") and v:FindFirstChild("SyncAPI") then
			return v
		end
	end
	
	for _,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
		if v:IsA("Tool") and v:FindFirstChild("SyncAPI") then
			return v
		end
	end
	
	return nil
end

function btools:DestroyObject(obj)
	local remote = fetchRemote()
	
	if remote then
		remote:InvokeServer(table.unpack({
			[1] = "Remove",
			[2] = {
				[1] = obj,
			},
		}))
		return true
	end
	
	return false
end

function btools:SetCollision(obj, state)
	local remote = fetchRemote()

	if remote then
		remote:InvokeServer(table.unpack({
			[1] = "SyncCollision",
			[2] = {
				[1] = {
					["Part"] = obj,
					["CanCollide"] = state,
				},
			},
		}))
		return true
	end
	
	return false
end

function btools:SetCFrame(obj, cf)
	local remote = fetchRemote()

	if remote then
		remote:InvokeServer("SyncMove",{
			{
				["Part"] = obj,
				["CFrame"] = cf,
			}
		})
		return true
	end

	return false
end

function btools:SetManyCollision(objs, state)
	local remote = fetchRemote()

	local arg = {}

	for _,v in pairs(objs) do
		table.insert(arg,{
			["Part"] = v,
			["CanCollide"] = state,
		})
	end

	if remote then
		remote:InvokeServer("SyncCollision",arg)
		return true
	end

	return false
end

function btools:SetManyCFrame(objs, cf)
	local remote = fetchRemote()
	
	local arg = {}
	
	for _,v in pairs(objs) do
		table.insert(arg,{
			["Part"] = v,
			["CFrame"] = cf,
		})
	end
	
	if remote then
		remote:InvokeServer("SyncMove",arg)
		return true
	end

	return false
end

return btools
