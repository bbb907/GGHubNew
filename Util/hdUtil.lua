local hdUtil = {}

local signals = game:GetService("ReplicatedStorage"):FindFirstChild("HDAdminHDClient")

if signals then
	signals = signals.Signals
else
	return nil
end

function hdUtil:SendCommand(cmd)
	signals.RequestCommandSilent:InvokeServer(cmd)
end

return hdUtil
