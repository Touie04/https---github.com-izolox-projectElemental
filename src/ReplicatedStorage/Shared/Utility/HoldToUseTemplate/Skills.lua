-- Services
local players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local ts = game:GetService("TweenService")

-- Modules

-- Classes

-- Variables

-- Functions

-- Modules
local module = {}

function module:SkillStart()
	if self.SkillCasted then return error("Skill is already casted") end


	
	--self.Anchored = self.Anchored and self.Anchored:Destroy() and nil
	--self.PlayerObject.HumanoidRootPart.Anchored =false
	task.spawn(function()
		repeat 
			
			wait(0.2)

		until not self.SkillCasted 


	end)

end



--// Getting-Validating mouseinfo \\--

--   local b = {
--	Type = "MousePosition",
--	MaxMagnitude = 200,
--	Value = shared.Remotes.RequestInfo:InvokeClient(self.PlayerObject.Player,"RequestMousePosition"),
--}
--   local MouseInfo = self.PlayerObject:ValidateClientInfo(b)  and b.Value
--   if not  MouseInfo then
--	return error("sum wrong with mouseinfo")
--end 





function module:SkillEnd()
	print("skill ended")
	self.SkillCasted = false
	local waittime = 1
	
	self.ManaDrain = self.ManaDrain and self.ManaDrain:Destroy() and nil

	
	self:Destroy("Skill")

	task.spawn(function() -- CoolDown
		task.wait(self.Info.CD.Value)
		self.CD = false 
	end)
end




return module
