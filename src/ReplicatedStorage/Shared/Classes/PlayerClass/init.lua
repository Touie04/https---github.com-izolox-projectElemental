if game:GetService("RunService"):IsClient() then
	return require(script.Client)
else
	return require(script.Server)
end
