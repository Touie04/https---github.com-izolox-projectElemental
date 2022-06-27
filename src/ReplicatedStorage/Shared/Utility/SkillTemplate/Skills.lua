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

function module:Skill()
    print("skill called")
	self.SkillCasted = true

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
	
	
	
	
    self:Destroy("skill")
    task.spawn(function()  -- CoolDown
        task.wait(self.Info.CD.Value)
        self.CD = false
    end)
end
-- function module:ChargedSkill()
-- 	self.SkillCasted = true
--     print(" charged skill called")

--     local mousepos = shared.Remotes.RequestInfo:InvokeClient(self.PlayerObject.Player,"RequestMousePosition")
--     local MouseInfo = self.PlayerObject:ValidateClientInfo(mousepos)  and mousepos
--     if not  MouseInfo then
--         print("sum wrong with mouseinfo")
--         return 
--     end     


-- 	local Mana = self.PlayerObject.Character:GetAttribute("Mana")	
-- 	self.PlayerObject.Character:SetAttribute("Mana", Mana - self.Info.ManaDrain.Value)




--     task.spawn(function() -- CoolDown
--         task.wait(self.Info.CD.Value)
--         self.CD = false 
--     end)
-- end
return module
