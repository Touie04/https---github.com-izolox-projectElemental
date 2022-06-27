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


	print("skill called")
	self.SkillCasted = true

	local WindBreath = self.Assets["Wind Breath"]:Clone()
	WindBreath.Parent = workspace.Projectiles
	WindBreath.CFrame = self.PlayerObject.Character.Head.CFrame


	local weld = Instance.new("WeldConstraint")
	weld.Part1 = self.PlayerObject.HumanoidRootPart
	weld.Part0 = WindBreath
	weld.Parent = weld.Part0

	self.SpawnedAssets["WindBreath"] = WindBreath

	for i,v in pairs(WindBreath:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v:Emit((v:GetAttribute("EmitCount") or 150))
			v.Enabled = true
		end
	end
	--self.Anchored = self.Anchored and self.Anchored:Destroy() and nil
	--self.PlayerObject.HumanoidRootPart.Anchored =false
	task.spawn(function()
		repeat 
			local tab = {
				Origin = WindBreath,
				Range = 35,
				Length = 35,
				Width = 10,
				Height = 10,
			}
			local targs = shared.HitBoxManager.GetMagHitbox(self.PlayerObject.Character,tab)

			if targs then
				for i,v in pairs(targs) do
					local TagTab = {
						Damage = 5,
						Stun = 0.1,
					}
					shared.TagHumanoid.TagHumanoid(self.PlayerObject.Character,v,TagTab,self.PlayerObject)
				end
			end

			wait(0.2)

		until not self.SkillCasted or not WindBreath or not WindBreath.Parent


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

	if self.SpawnedAssets["WindBreath"] then

		for i,v in pairs(self.SpawnedAssets["WindBreath"]:GetDescendants()) do
			if v:IsA("ParticleEmitter") or v:IsA("Light") then
				v.Enabled = false
			end
		end

	end
	self.Anchored = self.Anchored and self.Anchored:Destroy() and nil
	
	wait(waittime)
	self:Destroy("Skill")

	task.spawn(function() -- CoolDown
		task.wait(self.Info.CD.Value)
		self.CD = false 
	end)
end




return module
