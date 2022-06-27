local module = {}

function module:RequestCameraInfo ()
	return workspace.CurrentCamera.CFrame
end
function module:RequestMouseBehavior()
    local mousebehavior =  game:GetService("UserInputService").MouseBehavior.Name
return mousebehavior
end
return module