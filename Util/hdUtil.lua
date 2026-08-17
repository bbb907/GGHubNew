local hdUtil = {
	HDAdminEnabled = false
}

local signals = game:GetService("ReplicatedStorage"):FindFirstChild("HDAdminHDClient")

if signals then
	signals = signals.Signals
	hdUtil.HDAdminEnabled = true
end

function hdUtil:SendCommand(cmd)
	if not hdUtil.HDAdminEnabled then return false end
	
	signals.RequestCommandSilent:InvokeServer(cmd)
	
	return true
end

return hdUtil
