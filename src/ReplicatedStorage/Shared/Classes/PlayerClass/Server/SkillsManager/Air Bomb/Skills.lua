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
	--      return error("sum wrong with mouseinfo")
 --   end 
	local mana = self.PlayerObject.Character:GetAttribute("Mana")
	self.PlayerObject.Character:SetAttribute("Mana",mana-self.Info.ManaDrain.Value)

	local Airbomb = self.Assets.AirBomb:Clone()
	Airbomb.Parent = workspace.Projectiles
	Airbomb.Position = self.PlayerObject.Character.HumanoidRootPart.Position
	Airbomb.Anchored = true

	self.SpawnedAssets[Airbomb] = Airbomb


	local waittime = 0

	for i,v in pairs(Airbomb:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			waittime = (v.Lifetime.Max > waittime and v.Lifetime.Max) or waittime
			v:Emit(v:GetAttribute("EmitCount"))
		end
	end
	--// Hit Registration \\--
	local hbtab = {
		Origin = Airbomb,
		Range = 30,
	}
	local targs = shared.HitBoxManager.GetMagHitbox(self.PlayerObject.Character,hbtab)
	
	
	if targs then
		for i,v in pairs(targs) do
			local TagTab = {
				Damage = 60,
				Stun = 1,
				BodyVelocity = {
					Velocity =  ((v.HumanoidRootPart.Position - Airbomb.Position ) * 8),
					Lifetime = 0.25
				},
			}
			shared.TagHumanoid.TagHumanoid(self.PlayerObject.Character,v,TagTab,self.PlayerObject)
		end

	end
	
	wait(waittime)
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
