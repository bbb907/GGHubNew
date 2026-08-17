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

return btools
