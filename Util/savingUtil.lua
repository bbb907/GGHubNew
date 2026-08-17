local saving = {}
local data_profiles = {}
local httpService = game:GetService("HttpService")

local folderPath

function saving:init(fp)
	
	if not writefile or not listfiles or not readfile or not makefolder or not isfolder or not isfile then
		warn("SavingUtil: Your bad executor has like 0 unc, get a new one.")
		return
	end
	
	folderPath = fp
	
	if isfolder(folderPath) then
		saving:LoadAllProfiles()
		return
	end
	
	makefolder(folderPath)
	
end

function getFuncs(name)
	local funcs = {}
	local saving = false

	function funcs:Get()
		return data_profiles[name]
	end

	function funcs:Set(p)
		data_profiles[name] = p
	end

	function funcs:Save()
		if saving then return end
		
		saving = true
		
		task.delay(2,function()
			writefile(folderPath.."/"..name,httpService:JSONEncode(data_profiles[name]))
			saving = false
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

	data_profiles[name] = {}

	return getFuncs(name)
end

function saving:LoadProfile(path)
	local s,e = pcall(function()
		data_profiles[string.split(path,"\\")[2]] = httpService:JSONDecode(readfile(path))
	end)
end

function saving:LoadAllProfiles()
	for _,v in pairs(listfiles(folderPath)) do
		v = string.gsub(v,"\\","/")
		
		if not isfile(v) then
			warn("Invalid file path: "..v)
			continue
		end
		
		saving:LoadProfile(v)
	end
end

return saving
