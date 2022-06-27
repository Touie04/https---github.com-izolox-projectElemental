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

local module = shared.ClassGenerator:extend()

local SkillStats = script.Stats
function module:new(PlayerObject)
	self.PlayerObject = PlayerObject
	self.SkillName = script.Name	
	self.HoldTime = 0
	self.SkillAssets = {}
	self.CastedSkill = false
	self.CD = false
	self.Input = false
	self.InputBegantime = 0
	self:inherit(require(shared.SharedClasses.SkillClass))
end

function module:InputBegan(Info)

	if  not self.PlayerObject or  self.Input or self.CD or not self.PlayerObject:CheckForAction("CanAttack") then return end
	self.InputBegantime = 0
	self.CD = true
	self.Input = false
	
	self.Action = Instance.new("IntValue")
	self.Action.Name = "UsingSkill"
	self.Action.Parent = self.PlayerObject.ActionFolder
	
	self.Anchored = Instance.new("StringValue")
	self.Anchored.Name = "Anchor"
	self.Anchored.Parent = self.PlayerObject.ActionFolder

	local Character = self.PlayerObject.Character
	self.CastedSkill = false
	self.AnimationHitEnd = false

	self.Animation =  self.PlayerObject.Animator:LoadAnimation(script.Animation)
	self.Animation:Play()
	self. Animation:AdjustSpeed(1.5)
	self.CastingCircleObj = (self.CastingCircleObj and self.CastingCircleObj.Attachment and self.CastingCircleObj) or require(shared.SharedClasses.MagicCircleClass)( shared.SharedAssets.CastingCircle.Attachment:Clone(),self.PlayerObject.RightCastingAttach)
	self.PlayerObject.SpawnedAssets[self.SkillName .. "MagicCircleAttachment"] =  self.CastingCircleObj


	self.Animation.KeyframeReached:Connect(function(keyname)
		if keyname == "Impact" then
			if self.CastingCircleObj then

				self.CastingCircleObj:Emit()
				self:PlayCastingSound("MagicCast")
			end
		elseif keyname == "End" then
			self.AnimationHitEnd = true
			self.Animation:AdjustSpeed(0)
		end
	end)
	self.Animation.Stopped:Connect(function()
		self:EndCast()
	end)
	task.spawn(function()
		while true do
			if self.CleaningUp or not self.CastingCircleObj or not self.CastingCircleObj.Attachment  then
				self:CleanUp("Cancel")
				break
			elseif self.CastedSkill and self.HoldTime >= SkillStats.BaseChargeTime.Value then
				break

			end
			wait(1)
			self.HoldTime = self.HoldTime+1 

			if self.HoldTime >= SkillStats.ChargeTime.Value and self.CastingCircleObj.Attachment and not self.CastedSkill then
				self:PlayCastingSound("Charged")
				for i,v in pairs(self.CastingCircleObj.Attachment:GetChildren()) do

					if v:IsA("ParticleEmitter") then
						v.RotSpeed =  NumberRange.new(v.RotSpeed.Min * 10,v.RotSpeed.Max * 10)

						v:Emit(1)
						v.Enabled = true
					elseif v:IsA("PointLight") then

					end
				end
				self.CastingCircleObj:Emit() 
				-- Do Charged effect
				break
			end
		end
	end)
	self.PlayerObject.Character:SetAttribute("AutoRotate",true)
end
function module:InputEnded(Info)
	if self.Animation and not self.CastedSkill  then
		print("Input ended")
		self.CD = true
		self.CastedSkill = true
		if self.HoldTime >= SkillStats.ChargeTime.Value then
			print("Input ended 2")
			self:Charged()
		else
			if self.AnimationHitEnd and self.HoldTime >= SkillStats.BaseChargeTime.Value then
				print("Input ended 3")
				self:NoneCharged()	
			else	
				repeat wait() print(self.HoldTime) until self.AnimationHitEnd and self.HoldTime >= SkillStats.BaseChargeTime.Value
				print("IIIII BBBB")
				self:NoneCharged()
			end	
		end	
	elseif self.CastedSkill and not self.Animation then

		print("Animation not there")
		self:Destroy()
		return
	end

end

function module:MouseButton2_InputBegan(Info)

end

function module:MouseButton2_InputEnded(Info)

end
-- Equip/UnEquip
function module:Equip()
end
function module:UnEquip()
	if not self.CastedSkill then
		self:CleanUp("Cancel")
	end
end
-- Skills
--
function module:NoneCharged()
	if self.InputBegantime >= 1 then return end
	print("InputBegan",self.InputBegantime)
	self.InputBegantime += 1
	self.CastedSkill = true
	print("Fired this sh")
	
	local Mana = self.PlayerObject.Character:GetAttribute("Mana")	
	self.PlayerObject.Character:SetAttribute("Mana", Mana - SkillStats.NoneChargeCost.Value)
	
	self.PlayerObject.Character:SetAttribute("AutoRotate",false)
	--local MouseInfo = shared.Remotes.RequestInfo:InvokeClient(self.PlayerObject.Player,"RequestMousePosition")


	self.CastedSkill = true
	self.CD = true


	local ActiveFireballs = self.PlayerObject.ActiveFireballs
	
	local HeavenlyWind = script.HeavenlyWind:Clone()
	HeavenlyWind.Parent = workspace.Projectiles
	HeavenlyWind.Position = self.PlayerObject.Character.HumanoidRootPart.Position + Vector3.new(0,-4,0)
	self.SkillAssets[HeavenlyWind.Name] = HeavenlyWind


	for i,v in pairs(HeavenlyWind:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = true
		end
	end

	self:EndCast()

	local bv = Instance.new("BodyVelocity")
	bv.Name = "PushUP"
	bv.MaxForce = Vector3.new(1,1,1) * 10^20
	bv.P = 4000
	bv.Velocity = self.PlayerObject.Character.HumanoidRootPart.CFrame.UpVector * 80
	
	bv.Parent = self.PlayerObject.Character.HumanoidRootPart

	
	game.Debris:AddItem(bv,0.2)


	wait(1)

	
	local waittime = 0

	for i,v in pairs(HeavenlyWind:GetChildren()) do
		if v:IsA("ParticleEmitter") then
		if waittime < v.Lifetime.Max then waittime = v.Lifetime.Max end
			v.Enabled = false
		end
	end

	wait(waittime)

	
	self:CleanUp()

	task.spawn(function()
		wait(SkillStats.CD.Value)

		if self.Action  then
			self.Action:Destroy()
			self.Action = nil
		end
		self.CD = false
	end)


end
function module:Charged()
	self.PlayerObject.Character:SetAttribute("AutoRotate",false)
	self.CastedSkill = true
	local MouseInfo = shared.Remotes.RequestInfo:InvokeClient(self.PlayerObject.Player,"RequestMousePosition")
	local b = {
		Type = "MousePosition",
		MaxMagnitude = 200,
		Value = MouseInfo,
	}
	local MouseInfoIsValid = self.PlayerObject:ValidateClientInfo(b)

	if not MouseInfoIsValid  then
		self:CleanUp("Cancel")
		return
	end
	
	local Mana = self.PlayerObject.Character:GetAttribute("Mana")	
	self.PlayerObject.Character:SetAttribute("Mana", Mana - SkillStats.ChargeCost.Value)

	local ActiveFireballs = self.PlayerObject.ActiveFireballs

	local HeavenlyWind = script.HeavenlyWind:Clone()
	HeavenlyWind.Parent = workspace.Projectiles
	HeavenlyWind.Position = self.PlayerObject.Character.HumanoidRootPart.Position + Vector3.new(0,-4,0)
	self.SkillAssets[HeavenlyWind.Name] = HeavenlyWind



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

	bv.Velocity = self.PlayerObject.Character.HumanoidRootPart.CFrame.UpVector * 150

	bv.Parent = self.PlayerObject.Character.HumanoidRootPart


	game.Debris:AddItem(bv,0.1)
	self:EndCast()

	wait(1)


	local waittime = 0

	for i,v in pairs(HeavenlyWind:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			if waittime < v.Lifetime.Max then waittime = v.Lifetime.Max end
		
			v.Enabled = false
		end
	end

	wait(waittime)

	
	self:CleanUp()
	task.spawn(function()
		wait(SkillStats.CD.Value)
		self.CD = false
	end)

end
function module:Unequip()
	if self.Input then
		self:Destroy()
	end
	self.Input = false
end
return module
