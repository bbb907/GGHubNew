local btools = {
	scaleInfo = {}
}

function fetchRemote()
	local btools = btools.fetchBtools()
	
	if btools then
		return btools.SyncAPI.ServerEndpoint
	end
end

function btools.fetchBtools()
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

function btools:GetCurrentSelections()
	local selections = {}
	
	for _,v in pairs(game.Players.LocalPlayer.PlayerGui:GetDescendants()) do
		if v.Name == "BTSelectionBox" and v:IsA("SelectionBox") then
			if v.Adornee ~= nil then
				table.insert(selections, v.Adornee)
			end
		end
	end
	
	return selections
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

function btools:MoveObject(obj,cf)
	local remote = fetchRemote()

	if remote then
		remote:InvokeServer(table.unpack({
			[1] = "SyncMove",
			[2] = {
				[1] = {
					["Part"] = obj,
					["CFrame"] = cf,
				},
			},
		}))
		
		return true
	end
	
	return false
end

function btools:MakePart(loc)
	local remote = fetchRemote()

	if remote then
		remote:InvokeServer(table.unpack({
			[1] = "CreatePart",
			[2] = "Normal",
			[3] = loc,
			[4] = workspace,
		}))
		
		local part = nil
		local tim = tick()
		
		while part == nil and tick() - tim < 3 do
			for _,v in pairs(workspace:GetChildren()) do
				if v:IsA("BasePart") and v.Position == loc.Position then
					part = v
				end
			end
			task.wait()
		end
		
		return part
	end
	
	return false
end

function btools:SetLocked(part,state)
	local remote = fetchRemote()
	
	if remote then
		remote:InvokeServer(table.unpack({
			[1] = "SetLocked",
			[2] = {
				[1] = part,
			},
			[3] = state,
		}))
	end
end

function btools:SetManyLocked(parts,state)
	local remote = fetchRemote()

	if remote then
		local data = {}
		
		for _,v in pairs(parts) do
			table.insert(data,v)
		end
		
		remote:InvokeServer("SetLocked",data,state)
	end
end

function btools:RotatePart(part,cf)
	local remote = fetchRemote()
	
	if remote then
		remote:InvokeServer(table.unpack({
			[1] = "SyncRotate",
			[2] = {
				[1] = {
					["Part"] = part,
					["CFrame"] = cf,
				},
			},
		}))
	end
end

function btools:RotateManyParts(partRotationInfo)
	local remote = fetchRemote()

	if remote then
		remote:InvokeServer("SyncRotate",partRotationInfo)
	end
end

local AxisPositioningMultipliers = {
	[Enum.NormalId.Top] = Vector3.new(0, 1, 0),
	[Enum.NormalId.Bottom] = Vector3.new(0, -1, 0),
	[Enum.NormalId.Front] = Vector3.new(0, 0, -1),
	[Enum.NormalId.Back] = Vector3.new(0, 0, 1),
	[Enum.NormalId.Left] = Vector3.new(-1, 0, 0),
	[Enum.NormalId.Right] = Vector3.new(1, 0, 0)
}

local AxisSizeMultipliers = {
	[Enum.NormalId.Top] = Vector3.new(0, 1, 0);
	[Enum.NormalId.Bottom] = Vector3.new(0, 1, 0);
	[Enum.NormalId.Front] = Vector3.new(0, 0, 1);
	[Enum.NormalId.Back] = Vector3.new(0, 0, 1);
	[Enum.NormalId.Left] = Vector3.new(1, 0, 0);
	[Enum.NormalId.Right] = Vector3.new(1, 0, 0);
}

local FaceAxisNames = {
	[Enum.NormalId.Top] = 'Y',
	[Enum.NormalId.Bottom] = 'Y',
	[Enum.NormalId.Front] = 'Z',
	[Enum.NormalId.Back] = 'Z',
	[Enum.NormalId.Left] = 'X',
	[Enum.NormalId.Right] = 'X',
}

function btools.scaleInfo.new(obj)
	local Face = Enum.NormalId.Top
	local Distance = 1
	local BothDirections = false
	
	local funcs
	funcs = {
		build = function()
			if BothDirections then
				Distance = Distance * 2
			end

			local AxisSizeMultiplier = AxisSizeMultipliers[Face]
			local IncrementVector = Distance * AxisSizeMultiplier
			local AxisName = FaceAxisNames[Face]
			local TargetSize = obj.Size[AxisName] + Distance
			local newSize = obj.Size + IncrementVector

			local newcf = nil

			if not BothDirections then
				newcf = obj.CFrame * CFrame.new(AxisPositioningMultipliers[Face] * Distance / 2)
			else
				newcf = obj.CFrame
			end

			return {
				["Part"] = obj,
				["CFrame"] = newcf,
				["Size"] = newSize
			}
		end,
		setDistance = function(a)
			Distance = a
			return funcs
		end,
		setFace = function(a)
			Face = a
			return funcs
		end,
		setBothDirections = function(a)
			BothDirections = a 
			return funcs
		end,
	}
	
	return funcs
end


function btools:ScalePart(scaleInfo)
	local remote = fetchRemote()
	
	local obj = scaleInfo.Part
	
	if remote then
		remote:InvokeServer(table.unpack({
			[1] = "SyncResize",
			[2] = {
				[1] = {
					["Part"] = obj,
					["CFrame"] = scaleInfo.CFrame,
					["Size"] = scaleInfo.Size,
				},
			},
		}))
		return true
	end
	
	return false
end

return btools
