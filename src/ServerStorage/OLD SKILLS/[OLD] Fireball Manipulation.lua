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
	
	
	local Character = self.PlayerObject.Character
	self.CastedSkill = false
	self.AnimationHitEnd = false

	self.Anchored = Instance.new("StringValue")
	self.Anchored.Name = "Anchor"
	self.Anchored.Parent = self.PlayerObject.ActionFolder
	
	
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
		if self.CastingCircleObj then
			self.CastingCircleObj:Pause()
		end
		if self.Anchored then
			self.Anchored:Destroy()
		end
		
	end)
	task.spawn(function()
		while true do
			if self.CleaningUp or not self.CastingCircleObj or not self.CastingCircleObj.Attachment  then
				self:CleanUp("Cancel")
				break
			elseif self.CastedSkill  and self.HoldTime >= SkillStats.BaseChargeTime.Value then
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
			self:Charged()
		else
			if self.AnimationHitEnd and self.HoldTime >= SkillStats.BaseChargeTime.Value  then
				self:NoneCharged()	
			else	
				repeat wait() until self.AnimationHitEnd and self.HoldTime >= SkillStats.BaseChargeTime.Value
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
	print("Fired this sh")
	
	local Mana = self.PlayerObject.Character:GetAttribute("Mana")	
	self.PlayerObject.Character:SetAttribute("Mana", Mana - SkillStats.NoneChargeCost.Value)
	
	self.PlayerObject.Character:SetAttribute("AutoRotate",false)
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
	self.CastedSkill = true
	self.CD = true


	local ActiveFireballs = self.PlayerObject.ActiveFireballs
	
	local waittime = 0
	local Ball = ActiveFireballs[next(ActiveFireballs)]
	if Ball  then
		ActiveFireballs[next(ActiveFireballs)] = nil
		Ball:SetNetworkOwner(nil)
		local StartPosition = Ball.Position
		local EndPosition = MouseInfo
		
		local Magnitude = (StartPosition - EndPosition).Magnitude
		local Midpoint = StartPosition:Lerp(EndPosition,0.5)
		
		local sp = Vector3.new(12,12,32)
		local ep = Vector3.new(2,3,4)
		print(sp/ep)


		local PointA = Midpoint
		local PointB = Midpoint + Vector3.new(math.random(-10,1), 30, math.random(-10,10))
		local PointC = EndPosition + Vector3.new(math.random(-10,10), 30, math.random(-10,10) )

		local fireexplode = script.FireExplode:Clone()
		fireexplode.Position = MouseInfo
		fireexplode.Parent = workspace.Projectiles
		self.SkillAssets["FireExplode"] = fireexplode
		local magic_circle = fireexplode.Circle
		local MagicCircleClass = require(shared.SharedClasses.MagicCircleClass)(magic_circle,fireexplode)
		self.SkillAssets["FireExplodeCircle"] = MagicCircleClass
		MagicCircleClass:Emit()
		local sound = script.ignite2:Clone()
		sound.Parent = Ball
		sound:Play()
		game.Debris:AddItem(sound,sound.TimeLength)
		local spd = 2                 
		for i = 1,Magnitude,spd do
			
			local p = i/Magnitude
			local curv = require(shared.SharedModules.UtilityModule):cubicBezier(p,StartPosition,PointA,PointB,PointC,EndPosition)
			Ball.CFrame = Ball.CFrame:Lerp(CFrame.new(curv, EndPosition), p)
			game:GetService("RunService").Heartbeat:Wait()
		end
		local tf = script.TinyFire:Clone()
		tf.Parent = fireexplode.Att
		tf.Enabled = true
		
		
		
		local sound = script.magicexplosion1:Clone()
		sound.Parent = fireexplode
		game.Debris:AddItem(sound,4)
		Ball:Destroy()
		sound:Play()
		wait(1)
		tf:Destroy()
		for i,v in pairs(fireexplode:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(v:GetAttribute("EmitCount"))
				if v.Lifetime.Max > waittime then waittime = v.Lifetime.Max end
			elseif v:IsA("Attachment") then
				for o,p in pairs(v:GetChildren()) do
					task.spawn(function()
						p.Enabled = true
						wait(0.6)
						p.Enabled = false
					end)
				end
			end
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
	local Mana = self.PlayerObject.Character:GetAttribute("Mana")	
	self.PlayerObject.Character:SetAttribute("Mana", Mana - SkillStats.ChargeCost.Value)
	
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
	
	local ActiveFireballs = self.PlayerObject.ActiveFireballs
	local firepillar = script.FirePillar:Clone()
	firepillar.Position = MouseInfo
	firepillar.Parent = workspace.Projectiles

	local fireexplode = firepillar.FireExplode
	local magiccircleclass = require(shared.SharedClasses.MagicCircleClass)(firepillar.Circle,firepillar)
	fireexplode.Position = MouseInfo
	self.SkillAssets["FirePillar"] = firepillar
	self.SkillAssets["FirePillarCircle"] = magiccircleclass


	magiccircleclass:Emit()

	for i = 1,3 do
		
		local Ball = ActiveFireballs[next(ActiveFireballs)]
		if Ball  then
			ActiveFireballs[next(ActiveFireballs)] = nil
			Ball:SetNetworkOwner(nil)
			task.spawn(function()
				local StartPosition = Ball.Position
				local EndPosition = MouseInfo
				
		
				local Magnitude = (StartPosition - EndPosition).Magnitude
				local Midpoint = StartPosition:Lerp(EndPosition,0.5)

				local PointA = Midpoint
				local PointB = Midpoint + Vector3.new(math.random(-10,10), 30, math.random(-10,10))
				local PointC = EndPosition + Vector3.new(math.random(-10,10), 30, math.random(-10,10) )

				
				local sound = script.ignite2:Clone()
				sound.Parent = Ball
				sound:Play()
				game.Debris:AddItem(sound,sound.TimeLength)

				local spd = 2                 
				for i = 1,Magnitude,spd do

					local p = i/Magnitude
					local curv = require(shared.SharedModules.UtilityModule):cubicBezier(p,StartPosition,PointA,PointB,PointC,EndPosition)
					Ball.CFrame = Ball.CFrame:Lerp(CFrame.new(curv, EndPosition), p)
					game:GetService("RunService").Heartbeat:Wait()
				end
				local tf = script.TinyFire:Clone()
				tf.Parent = fireexplode.Att
				tf.Enabled = true

				Ball:Destroy()

				wait(1)
				tf:Destroy()
			end)
			wait(0.2)
		end
	end
	
	local sound2 = script.magicexplosion1:Clone()
	sound2.Parent = firepillar
	sound2:Play()
	game.Debris:AddItem(sound2,sound2.TimeLength)
	
	local s3 = script.Burning:Clone()
	s3.Parent = firepillar
	s3:Play()
	
	local s4 = script["Lava Bubbling Boiling Loop"]:Clone()
	s4.Parent = firepillar
	s4:Play()
	wait(1)


	for i,v in pairs(fireexplode:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			v:Emit(v:GetAttribute("EmitCount"))
		elseif v:IsA("Attachment") then
			for o,p in pairs(v:GetChildren()) do
				task.spawn(function()
					p.Enabled = true
					wait(1)
					p.Enabled = false
				end)
			end
		end
	end
	wait(0.2)
	for i,v in pairs(firepillar:GetChildren()) do
		if v:IsA("ParticleEmitter")  then
			v.Enabled = true
		elseif v:IsA("PointLight") then
			v.Enabled = true

		end	
	end

	wait(3)
	self.CastingCircleObj:Pause()
	local waittime = 0
	for i,v in pairs(firepillar:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			if waittime < v.Lifetime.Max then waittime = v.Lifetime.Max end
			v.Enabled = false

		elseif v:IsA("PointLight") then
			v.Enabled = false

		end	
	end

	wait(waittime)
	s3:Destroy()
	s4:Destroy()
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
