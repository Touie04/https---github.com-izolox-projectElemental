local HitBoxManager = {}

local function isAttachedToHumanoid(part)
	return part.Parent:FindFirstChildOfClass("Humanoid") or 
		part.Parent.Parent:FindFirstChildOfClass("Humanoid")
end
--  Properties --

-- Origin = origin position
-- Range = Range
--

HitBoxManager.GetMagHitbox = function(char,properties)
	
	local fcalltick = tick()
	local root = char:FindFirstChild("HumanoidRootPart")
	local origin = properties["Origin"] or root
	local range = properties["Range"] or 7
	local maxhit = properties["MaxHit"] or #workspace.Live:GetChildren()
	local targs = {}
	for _,v in pairs(workspace.Live:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= char then
			local eroot = v:FindFirstChild("HumanoidRootPart")
			local dist = eroot.Position - origin.Position
			local result = (dist).Magnitude < range
			--result = result and char:FindFirstChild("ActionFolder")
			if properties["Width"] then
				result = result and math.abs((origin.CFrame:Inverse() * eroot.CFrame).X) < properties["Width"]			
			end
			if properties["Length"] then	
				result = result and (origin.CFrame:Inverse() * eroot.CFrame).Z < properties["Length"]
			end
			if properties["Height"] then
				result = result and math.abs((origin.CFrame:Inverse() * eroot.CFrame).Y) < properties["Height"]
			end
			if result then
				if #targs < maxhit then		
					if not table.find(targs,v) then
						table.insert(targs,v)
					end
				else
					for int,alrin in ipairs(targs) do
						if alrin:IsA("Model") and alrin:FindFirstChild("Humanoid") and alrin:FindFirstChild("HumanoidRootPart") and alrin ~= char then
							if (alrin["HumanoidRootPart"].Position - root.Position).Magnitude > (dist).Magnitude then
								print(alrin)
								table.remove(targs,int)
								table.insert(targs,v)
							end
						else
							table.remove(targs,int)
							table.insert(targs,v)
						end
					end
				end
			end	
		end
	end	
	if #targs > 0 then
		if properties["TagHumanoid"] then
			for i,v in pairs(targs) do
				shared.TagHumanoid.TagHumanoid(char,v,properties["TagHumanoid"])
			end
		end
		return targs
	else 
		return nil
	end
end




function HitBoxManager:ListenToHitbox(part : BasePart, func : (Humanoid) -> ())
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
	
	function self:ForceCleanUp()
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
	return setmetatable(self, {__index = HitBoxManager})
end




return HitBoxManager
