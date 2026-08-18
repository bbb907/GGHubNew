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

function btools:DestroyManyObjects(objs)
	local remote = fetchRemote()

	if remote then
		remote:InvokeServer("Remove",objs)
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

function btools:SetAnchored(obj,state)
	local remote = fetchRemote()
		
	if remote then
		remote:InvokeServer(table.unpack({
			[1] = "SyncAnchor",
			[2] = {
				[1] = {
					["Part"] = obj,
					["Anchored"] = state,
				},
			},
		}))
		return true
	end
	
	return false
end

function btools:CreateLight(obj,range,brightness)
	local remote = fetchRemote()

	if remote then
		remote:InvokeServer(table.unpack({
			[1] = "CreateLights",
			[2] = {
				[1] = {
					["Part"] = obj,
					["LightType"] = "PointLight",
				},
			},
		}))
		task.wait(0.01)
		remote:InvokeServer(table.unpack({
			[1] = "SyncLighting",
			[2] = {
				[1] = {
					["Part"] = workspace.Part,
					["LightType"] = "PointLight",
					["Range"] = range,
				},
			},
		}))
		task.wait(0.01)
		remote:InvokeServer(table.unpack({
			[1] = "SyncLighting",
			[2] = {
				[1] = {
					["Part"] = workspace.Part,
					["LightType"] = "PointLight",
					["Brightness"] = brightness,
				},
			},
		}))
		
		return true
	end
	
	return false
end

function btools:CreateManyLights(objs,range,brightness)
	local remote = fetchRemote()
	
	local createLightArgs = {}
	
	for _,v in pairs(objs) do
		table.insert(createLightArgs,{
			["Part"] = v,
			["LightType"] = "PointLight",
		})
	end
	
	local rangeLightArgs = {}
	
	for _,v in pairs(objs) do
		table.insert(rangeLightArgs,{
			["Part"] = v,
			["LightType"] = "PointLight",
			["Range"] = range,
		})
	end
	
	local brightnessLightArgs = {}
	
	for _,v in pairs(objs) do
		table.insert(brightnessLightArgs,{
			["Part"] = v,
			["LightType"] = "PointLight",
			["Brightness"] = brightness,
		})
	end
	
	if remote then
		remote:InvokeServer("CreateLights",createLightArgs)
		task.wait(0.01)
		remote:InvokeServer("SyncLighting",rangeLightArgs)
		task.wait(0.01)
		remote:InvokeServer("SyncLighting",brightnessLightArgs)

		return true
	end

	return false
end

function btools:RemoveLights(obj)
	local remote = fetchRemote()

	if remote then
		
		if not obj["PointLight"] then
			return false
		end
		
		remote:InvokeServer(table.unpack({
			[1] = "Remove",
			[2] = {
				[1] = obj["PointLight"],
			},
		}))
		
		return true
	end
	
	return false
end

function btools:RemoveManyLights(objs)
	local remote = fetchRemote()

	if remote then
		
		local args = {}
		
		for _,v: BasePart in pairs(objs) do
			if v:FindFirstChildOfClass("PointLight") == nil then
				continue
			end
			
			table.insert(args,v:FindFirstChildOfClass("PointLight"))
		end

		remote:InvokeServer("Remove",args)

		return true
	end

	return false
end

return btools
