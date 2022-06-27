--[[
created by ya boy qut100

HOW TO USE!!!!

module:ListenToHitbox(Hitbox, ListeningFunction)
	the listening function parses in the humanoid so you can modify it to whatever
	supports loops and will auto stop them when the humanoid is no longer touching the hitbox
	
module:ForceCleanUp()
	will clean up all connnections, stops all running loops, and basically :Destroy the object

have fun!
]]

local module = {}

local function isAttachedToHumanoid(part)
	return part.Parent:FindFirstChildOfClass("Humanoid") or 
		part.Parent.Parent:FindFirstChildOfClass("Humanoid")
end

function module:ListenToHitbox(part : BasePart, func : (Humanoid) -> ())
	local self = {
		cache = {}
	}
	self.connections = {
		part.Touched:Connect(function(target : BasePart)
			local potential = isAttachedToHumanoid(target)
			if potential == nil then return end
			
			local thread = task.spawn(func, potential)
			self.cache[potential] = thread
		end),
		part.TouchEnded:Connect(function(target : BasePart)
			local potential = isAttachedToHumanoid(target)
			if potential == nil then return end
			local potentialCache = self.cache[potential]
			if potentialCache == nil then return end
			
			task.cancel(potentialCache)
		end)
	}
	
	return setmetatable(self, {__index = module})
end

function module:ForceCleanUp()
	for i,v in pairs(self.connections) do
		v:Disconnect()
	end
	for i,v in pairs(self.cache) do
		task.cancel(v)
	end
	self.connections = nil
	self.cache = nil
	self = nil
end

return module