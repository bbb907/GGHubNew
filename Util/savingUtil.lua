local saving = {}
local data_profiles = {}
local httpService = game:GetService("HttpService")

local folderPath

function saving:init(fp)

	if not writefile or not listfiles or not readfile or not makefolder or not isfolder or not isfile then
		warn("SavingUtil: Your executor does not support standard UNC filesystem functions.")
		return
	end

	folderPath = fp

	if isfolder(folderPath) then
		saving:LoadAllProfiles()
		return
	end

	makefolder(folderPath)

end

local function getFuncs(name)
	local funcs = {}
	local isSaving = false

	function funcs:Get()
		return data_profiles[name]
	end

	function funcs:Set(p)
		data_profiles[name] = p
	end

	function funcs:Save()
		if isSaving then return end

		isSaving = true

		task.delay(2, function()
			writefile(folderPath.."/"..name, httpService:JSONEncode(data_profiles[name]))
			isSaving = false
		end)
	end

	return funcs
end

function saving:CreateProfile(name)
	local profile = data_profiles[name]

	if profile then
		warn("Profile already exists!")
		return saving:GetProfile(name)
	end

	data_profiles[name] = {}

	return getFuncs(name)
end

function saving:GetProfile(name)
	local profile = data_profiles[name]

	if not profile then
		warn("Profile does not exist!")
		return
	end

	return getFuncs(name)
end

function saving:LoadProfile(path)
	local s, e = pcall(function()
		local content = readfile(path)

		local fileName = string.match(path, "([^/]+)$") 

		if fileName then
			data_profiles[fileName] = httpService:JSONDecode(content)
		end
	end)

	if not s then
		warn("Failed to load profile (".. tostring(path) .."): " .. tostring(e))
	end
end

function saving:LoadAllProfiles()
	for _, v in pairs(listfiles(folderPath)) do
		v = string.gsub(v, "\\", "/")

		if not isfile(v) then
			warn("Invalid file path: " .. v)
			continue
		end

		saving:LoadProfile(v)
	end
end

return saving
