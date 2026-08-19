local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local playerSelectors = {}

--[[
{
	profName: string,
	element: Instance
}
]]
local sustainedSelectors = {}

plr.CharacterAdded:Connect(function(c)
	char = c
end)

-- [[ Services ]]
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local loops = loadstring(game:HttpGet("https://raw.githubusercontent.com/bbb907/GGHubNew/refs/heads/main/Util/loopUtil.lua"))()
local btools = loadstring(game:HttpGet("https://raw.githubusercontent.com/bbb907/GGHubNew/refs/heads/main/Util/btoolsUtil.lua"))()
local saving = loadstring(game:HttpGet("https://raw.githubusercontent.com/bbb907/GGHubNew/refs/heads/main/Util/savingUtil.lua"))()
local hdUtil = loadstring(game:HttpGet("https://raw.githubusercontent.com/bbb907/GGHubNew/refs/heads/main/Util/hdUtil.lua"))()
local sha = loadstring(game:HttpGet("https://raw.githubusercontent.com/bbb907/GGHubNew/refs/heads/main/sha256.lua"))()

--[[ Setup ]]--
saving:init("GGHubData")

local statsProfile = saving:GetProfile("Stats")

if statsProfile == nil then
	statsProfile = saving:CreateProfile("Stats")

	statsProfile:Set({
		crashes = 0,
		tools = 0,
		commands = 0
	})

	statsProfile:Save()
end

local window = Rayfield:CreateWindow({
	name = "GG Hub V3.5",
	subtitle = "discord.gg/KbzSdnunVC",
	configuration = {
		autoSave = true,
		autoLoad = true,
		fileName = "Config",
		customFolder = "GGHubV3",
	},
})

--[[ Owner Admin Protection ]] --
local tab = window:CreateTab({ name = "Owner Admin", icon = 11656483170 })

local crashStopper: RBXScriptConnection
local anticrash = tab:CreateToggle({
	name = "Anti Crash",
	flag = "AntiCrash",
	callback = function(value)
		if value then
			window:Notify({
				title = "Anti-Crash",
				content = "You're now protected against crashes!",
				duration = 5,
			})
			crashStopper = plr.PlayerGui.DescendantAdded:Connect(function(s)
				if s.Name == "Crash" then

					task.wait()
					s:Destroy()

					local newStats = statsProfile:Get()

					if newStats["crashes"] == nil then
						newStats["crashes"] = 0
					end

					newStats.crashes += 1
					statsProfile:Set(newStats)
					statsProfile:Save()

					crashesPrevented:Set(newStats.crashes)

				end
			end)

			loops:AddRobloxEvent(crashStopper)
		elseif crashStopper ~= nil then
			window:Notify({
				title = "Anti-Crash",
				content = "You're no longer protected against crashes!",
				duration = 5,
			})

			crashStopper:Disconnect()

			loops:UpdateRobloxEvents()
		end
	end,
})

local alreadyCrashed = {}
table.insert(sustainedSelectors,{
	profName = "CrashBan",

	element = tab:CreateDropdown({
		name = "CrashBan",
		multiSelect = true,
		forgetState = true,
		options = {""},
		placeholder="Select plr",
		callback = function(selected)
			local profile = saving:GetProfile("CrashBan")

			if profile ~= nil then
				profile:Set(selected)
				profile:Save()
			end

			for _,v in pairs(selected) do
				if not table.find(alreadyCrashed,v) and game.Players:FindFirstChild(v) ~= nil then
					hdUtil:SendCommand(";crash "..v)
					table.insert(alreadyCrashed,v)
					task.wait(0.1)
				end
			end

		end,
	})
})

-- [[ Other command protection ]] --
local tab = window:CreateTab({ name = "AntiCommands", icon = 11656483170 })

local ogCamera = game.Workspace.Camera
local newCam = nil

tab:CreateToggle({
	name = "Anti Camera",
	flag = "AntiCamera",
	description="Commands like; warp, blur",
	callback = function(value)
		if value then
			newCam = ogCamera:Clone()
			newCam.Parent = workspace
			ogCamera.Parent = game.ReplicatedStorage
		elseif newCam then
			newCam:Destroy()
			ogCamera.Parent = game.Workspace
		end
	end,
})

tab:CreateToggle({
	name = "Anti Gamepass",
	flag = "AntiGamepass",
	description = "Prevent being given gamepass prompts.",
	callback = function(value)
		if value then
			loops:CreateLoop("AntiGamepass",function()
				if game.CoreGui:FindFirstChild("FoundationOverlay") then
					game.CoreGui.FoundationOverlay:Destroy()
				end
			end,1)
		else
			loops:UnbindLoop("AntiGamepass")
		end
	end,
})

local grid = tab:CreateGroup()
local dbTime = 20

local left = grid:CreateGroup({ direction = "column" })

local rl: RBXScriptConnection
local rld=false
left:CreateToggle({
	name = "Notice Ratelimit",
	flag = "NoticeRL",
	description = "Makes it so you can't get notice spammed.",
	callback = function(value)
		if value then
			if not plr.PlayerGui:FindFirstChild("HDAdminInterface") then
				window:Popup({
					title = "Not available",
					content = "This isn't available right now!",
					options = {
						{ text = "Okay!", style = "primary" },
					},
				})
				return
			end

			rl = plr.PlayerGui.HDAdminInterface.Notices.ChildAdded:Connect(function(s)
				if rld or dbTime == 0 then
					task.wait()
					s:Destroy()
				else
					rld = true
					task.wait(dbTime)
					rld = false
				end
			end)

			loops:AddRobloxEvent(rl)
		elseif rl ~= nil then
			rl:Disconnect()

			loops:UpdateRobloxEvents()
		end
	end,
})

local right = grid:CreateGroup({ direction = "column" })
right:CreateSlider({
	name = "Notice debounce",
	flag = "NoticeDB",
	range = { 0, 120 },
	increment = 1,
	value = 20,
	prefix = "s",
	callback = function(value)
		dbTime = value
	end,
})

tab:CreateToggle({
	name = "Anti Teleport",
	flag = "AntiTP",
	description = "Prevents you being teleported",
	callback = function(value)
		if value then
			local lastPos = char.PrimaryPart.Position*Vector3.new(1,0,1)

			loops:CreateLoop("AntiTP",function()
				if char.PrimaryPart == nil then
					return
				end

				local cpos = char.PrimaryPart.Position*Vector3.new(1,0,1)

				local diff = (cpos - lastPos).Magnitude

				if diff > 25 then
					char:PivotTo(CFrame.new(lastPos))
					return
				end

				lastPos = cpos
			end,0.1)
		else
			loops:UnbindLoop("AntiTP")
		end
	end,
})

tab:CreateToggle({
	name = "Anti Speed",
	flag = "AntiSpeed",
	callback = function(value)
		if value then
			loops:CreateLoop("AntiSpeed",function()
				if char then
					if char:FindFirstChildOfClass("Humanoid") then
						char:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
					end
				end
			end,0.1)
		else
			loops:UnbindLoop("AntiSpeed")
		end
	end,
})

--[[ BTools exploits ]]
local tab = window:CreateTab({ name = "BTools", icon = 127904742940104 })

tab:CreateSection({ name = "Restrictive", icon = 13793170713 })

local db = false

local antitool
antitool = tab:CreateToggle({
	name = "Anti Tool",
	description = "Prevent other people having tools",
	flag = "AntiTool",
	callback = function(value)
		if value then
			antitool:Set(false)
			window:Popup({
				title = "Blocked",
				content = "You've come across a paid feature, join the discord (linked at the top of the menu) for more info",
				options = {
					{ text = "Okay!", style = "primary" },
				},
			})
		end
	end,
})

table.insert(sustainedSelectors,{
	profName = "ToolBan",

	element = tab:CreateDropdown({
		name = "ToolBan",
		multiSelect = true,
		forgetState = true,
		description = "Prevents specific people having tools.",
		options = {""},
		placeholder="Select plr",
		callback = function(selected)
			local profile = saving:GetProfile("ToolBan")

			if profile ~= nil then
				profile:Set(selected)
				profile:Save()
			end

			for _,v in pairs(selected) do
				if not table.find(alreadyCrashed,v) and game.Players:FindFirstChild(v) ~= nil then
					local p = game.Players:FindFirstChild(v)
					local c = p.Character

					if c and c:FindFirstChildOfClass("Tool") then
						local success = btools:DestroyObject(c:FindFirstChildOfClass("Tool"))

						if not success then
							if not db then
								db = true

								window:Popup({
									title = "No btools",
									content = "Would you like to run the btools command?",
									options = {
										{ text = "Yes", style = "primary", callback = function() hdUtil:SendCommand(";btools") end },
										{ text = "Ignore", style = "danger" },
									},
								})

								task.delay(3,function()
									db = false
								end)
							end
						else
							local newSave = statsProfile:Get()

							if newSave["tools"] == nil then
								newSave["tools"] = 0
							end

							newSave.tools += 1
							statsProfile:Set(newSave)
							statsProfile:Save()

							toolsBlocked:Set(newSave.tools)
						end
					end
				end
			end

		end,
	})
})

table.insert(sustainedSelectors,{
	profName = "CharBan",

	element = tab:CreateDropdown({
		name = "CharBan",
		multiSelect = true,
		forgetState = true,
		description = "Makes sure certain people don't spawn.",
		options = {""},
		placeholder="Select plr",
		callback = function(selected)
			local profile = saving:GetProfile("CharBan")

			if profile ~= nil then
				profile:Set(selected)
				profile:Save()
			end

			for _,v in pairs(selected) do
				local plr = game.Players:FindFirstChild(v)

				if plr and plr.Character then
					btools:DestroyObject(plr.Character)
				end
			end

		end,
	})
})

local forceSpectate
forceSpectate = tab:CreateToggle({
	name = "Force Spectate",
	description = "Make other people spectate you",
	forgetState = true,
	callback = function(value)
		if value then
			forceSpectate:Set(false)
			window:Popup({
				title = "Blocked",
				content = "You've come across a paid feature, join the discord (linked at the top of the menu) for more info",
				options = {
					{ text = "Okay!", style = "primary" },
				},
			})
		end
	end,
})

tab:CreateSection({ name = "Silent commands", icon = 131152076952801 })

tab:CreateButton({
	name = "Kill All",
	callback = function()
		for _,v in pairs(game.Players:GetPlayers()) do
			if v ~= plr and v.Character then
				btools:DestroyObject(v.Character:FindFirstChild("Head"))
			end
		end
	end,
})

table.insert(playerSelectors, tab:CreateDropdown({
	name = "Kill",
	multiSelect = false,
	options = {""},
	forgetState = true,
	placeholder="Select plr",
	callback = function(selected)
		if selected == "" or selected == nil then return end

		local p: Player = game.Players:FindFirstChild(selected)

		if p ~= nil and p.Character then
			btools:DestroyObject(p.Character:FindFirstChild("Head"))
		end
	end,
}))

tab:CreateSection({ name = "Destructive", icon = 13424571211 })

tab:CreateButton({
	name = "Remove all",
	callback = function()
		local objs = {}

		for _,v:BasePart in pairs(workspace:GetChildren()) do
			if v:IsA("BasePart") or (v:IsA("Model") and v.PrimaryPart == nil) then
				if v:IsA("BasePart") then
					if v.Locked then
						continue
					end
				end

				table.insert(objs,v)
			end
		end

		btools:DestroyManyObjects(objs)
	end,
})

tab:CreateButton({
	name = "Break HDWorkspace",
	callback = function()
		window:Popup({
			title = "Blocked",
			content = "You've come across a paid feature, join the discord (linked at the top of the menu) for more info",
			options = {
				{ text = "Okay!", style = "primary" },
			},
		})
	end,
})

tab:CreateToggle({
	name = "Blinder",
	forgetState = true,
	callback = function(value)
		if value then
			loops:CreateLoop("Blinder",function()
				local objs = {}

				for _,v:BasePart in pairs(workspace:GetDescendants()) do
					if v:IsA("BasePart") and not v:IsA("Terrain") then
						table.insert(objs,v)
					end
				end

				btools:CreateManyLights(objs,100,1000)
				task.wait()
				btools:RemoveManyLights(objs)
			end,0)
		else
			loops:UnbindLoop("Blinder")
		end
	end,
})

tab:CreateSection({ name = "Anti Commands", icon = 98159911363596 })

local aj: RBXScriptConnection
aj=tab:CreateToggle({
	name = "Anti Jail",
	flag = "AntiJail",
	description = "Prevents; freeze, ice, jail",
	callback = function(value)
		if value then
			aj:Set(false)
			window:Popup({
				title = "Blocked",
				content = "You've come across a paid feature, join the discord (linked at the top of the menu) for more info",
				options = {
					{ text = "Okay!", style = "primary" },
				},
			})
		end
	end,
})

--[[ Stats ]]--
local tab = window:CreateTab({ name = "Stats", icon = 102994395432803 })

crashesPrevented = tab:CreateStat({
	name = "Crashes prevented",
	compact = true,
	changeMode = "absolute",
	value = statsProfile:Get().crashes,
})

toolsBlocked = tab:CreateStat({
	name = "Tools blocked",
	compact = true,
	changeMode = "absolute",
	value = statsProfile:Get().tools,
})

--[[ Final general section ]]--
local tab = window:CreateTab({ name = "General", icon = 76311199408449 })

tab:CreateButton({
	name = "Uninject",
	description = "Stops the whole script",
	callback = function()
		loops:UnbindAll()
		window:Unload()
	end,
})

tab:CreateDropdown({
	name = "Theme",
	flag="Theme",
	multiSelect = false,
	options = { "Default", "Cobalt","ember", "amethyst", "frost", "rose" },
	value = "Default",
	callback = function(selected)
		window:ChangeTheme(selected)
	end,
})

-- [[ Updaters ]] --

loops:CreateLoop("Update",function()
	for _,v in pairs(playerSelectors) do
		local names = {}

		for _,v1 in pairs(game.Players:GetPlayers()) do
			if v1 == plr then continue end

			table.insert(names,v1.Name)
		end

		v:Refresh(names)
	end
end,1)

loops:CreateLoop("Update2",function()
	for _,v in pairs(playerSelectors) do
		v:Set("")
	end
end,0.1)

for _,v in pairs(sustainedSelectors) do
	local profile = saving:GetProfile(v.profName)

	if profile == nil then
		profile = saving:CreateProfile(v.profName)
		profile:Set({})
		profile:Save()
	end
end

loops:CreateLoop("Update3",function()
	for _,v in pairs(sustainedSelectors) do
		local names = {}

		for _,v1 in pairs(game.Players:GetPlayers()) do
			if v1 == plr then continue end

			table.insert(names,v1.Name)
		end

		local profile = saving:GetProfile(v.profName)

		if profile then
			for _,v1 in pairs(profile:Get()) do
				if v1 == plr.Name then continue end

				table.insert(names,v1)
			end
		end

		v.element:Refresh(names)

		if profile then 
			v.element:Set(profile:Get())
		end
	end

end,1)

-- [[ Events ]] --

game.Players.PlayerAdded:Connect(function(plr)
	local crashBans = saving:GetProfile("CrashBan")

	if crashBans then
		if table.find(crashBans:Get(),plr.Name) then
			hdUtil:SendCommand(";crash "..plr.Name)
		end
	end
end)

game.Players.PlayerRemoving:Connect(function(plr)
	if table.find(alreadyCrashed,plr.Name) then
		table.remove(alreadyCrashed,table.find(alreadyCrashed,plr.Name))
	end
end)

-- [[ Warnings ]] --
if not hdUtil.HDAdminEnabled then
	window:Popup({
		title = "Notice",
		subtitle = "Missing support",
		boxes = {
			{ title = "No HD Admin", description = "This means you won't be able to use certain modules which run hd admin commands." },
			{ title = "What this may effect", description = "Things like CrashBan, getting btools back, and other things." },
		},
		options = { { text = "Got it", style = "primary" } },
	})
end
