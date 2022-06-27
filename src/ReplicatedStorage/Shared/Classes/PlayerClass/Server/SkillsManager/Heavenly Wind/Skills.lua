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
 --   end self.Anchored = self.Anchored and self.Anchored:Destroy() and nil

	local mana = self.PlayerObject.Character:GetAttribute("Mana")
	self.PlayerObject.Character:SetAttribute("Mana",mana-self.Info.ManaDrain.Value)

	local HeavenlyWind = self.Assets.HeavenlyWind:Clone()
	HeavenlyWind.Parent = workspace.Projectiles
	HeavenlyWind.Position = self.PlayerObject.Character.HumanoidRootPart.Position + Vector3.new(0,-4,0)
	self.SpawnedAssets[HeavenlyWind.Name] = HeavenlyWind




	
	print("abt to push up")

	for i,v in pairs(HeavenlyWind:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = true
		end
	end
	
	

	local bv = Instance.new("BodyVelocity")
	bv.Name = "PushUP"
	bv.MaxForce = Vector3.new(1,1,1) * 10^20
	bv.P = 4000
	bv.Velocity = self.PlayerObject.Character.HumanoidRootPart.CFrame.UpVector * 80
	bv.Parent = self.PlayerObject.Character.HumanoidRootPart
	game.Debris:AddItem(bv,0.1)

	wait(1)
	local waittime = 0
	for i,v in pairs(HeavenlyWind:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			if waittime < v.Lifetime.Max then waittime = v.Lifetime.Max end
			v.Enabled = false
		end
	end

	task.wait(waittime)
    self:Destroy("skill")
    task.spawn(function()  -- CoolDown
        task.wait(self.Info.CD.Value)
        self.CD = false
    end)
end

 function module:ChargedSkill()
 	self.SkillCasted = true
     print(" charged skill called")


 	local Mana = self.PlayerObject.Character:GetAttribute("Mana")	
 	self.PlayerObject.Character:SetAttribute("Mana", Mana - self.Info.ManaDrain.Value)


	local HeavenlyWind = self.Assets.HeavenlyWind:Clone()
	HeavenlyWind.Parent = workspace.Projectiles
	HeavenlyWind.Position = self.PlayerObject.Character.HumanoidRootPart.Position + Vector3.new(0,-4,0)
	self.SpawnedAssets[HeavenlyWind.Name] = HeavenlyWind


	self.Anchored = self.Anchored and self.Anchored:Destroy() and nil


	for i,v in pairs(HeavenlyWind:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			if v.Name == "Slash" or v.Name == "Slash2" then
				v.Speed = NumberRange.new(v.Speed.Min * 3,v.Speed.Max * 3)
			end
			v.Enabled = true
		end
	end



	local bv = Instance.new("BodyVelocity")
	bv.Name = "PushUP"
	bv.MaxForce = Vector3.new(1,1,1) * 10^20
	bv.P = 4000
	bv.Velocity = self.PlayerObject.Character.HumanoidRootPart.CFrame.UpVector * 150
	bv.Parent = self.PlayerObject.Character.HumanoidRootPart
	game.Debris:AddItem(bv,0.1)

	wait(1)
	
	local waittime = 0
	for i,v in pairs(HeavenlyWind:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			if waittime < v.Lifetime.Max then waittime = v.Lifetime.Max end
			v.Enabled = false
		end
	end

	task.wait(waittime)
	self:Destroy("skill")

     task.spawn(function() -- CoolDown
         task.wait(self.Info.CD.Value)
         self.CD = false 
     end)
 end
return module
