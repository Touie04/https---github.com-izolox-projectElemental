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
local bp = Instance.new("BodyPosition")
bp.MaxForce = Vector3.new(1,1,1) * 1000
bp.P = 1000
bp.D = 200
-- Functions

local module = shared.ClassGenerator:extend()

local SkillStats = script.Stats
function module:new(PlayerObject)
	print(PlayerObject.Player)
	self.PlayerObject = PlayerObject
	self.SkillName = script.Name	
	self.HoldTime = 0
	self.SkillAssets = {}
	self.Weld = {}
	self.CastedSkill = false
	self.CD = false
	self.PlayerObject.ActiveFireballs = {}
	self:inherit(require(shared.SharedClasses.SkillClass))
	self.InputBegantime = 0
end
-- MouseButton1 ---
function module:InputBegan(Info)

	if not self.PlayerObject or self.OnCD or not self.PlayerObject:CheckForAction("CanAttack") then return end
	self.InputBegantime = 0
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
			self.CastingCircleObj:Emit() 
			self:PlayCastingSound("MagicCast")
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
			if self.CleaningUp or not self.CastingCircleObj or not self.CastingCircleObj.Attachment then
				self:CleanUp("Cancel")
				break
			elseif self.CastedSkill or self.CleaningUp   and self.HoldTime >= SkillStats.BaseChargeTime.Value then
				break

			end
			wait(1)
			self.HoldTime = self.HoldTime+1 
			if self.HoldTime >= SkillStats.ChargeTime.Value and self.CastingCircleObj.Attachment and not self.CastedSkill then
				self:PlayCastingSound("Charged")
				for i,v in pairs(self.CastingCircleObj.Attachment:GetChildren()) do

					if v:IsA("ParticleEmitter") then
						v.RotSpeed =  NumberRange.new(v.RotSpeed.Min * 10,v.RotSpeed.Max * 10)
						print(v.RotSpeed,i)
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
	--self.PlayerObject.Character:SetAttribute("AutoRotate",true)
end
function module:InputEnded(Info)
		

	if self.Animation and not self.CastedSkill  then
		
		if self.HoldTime >= SkillStats.ChargeTime.Value then
			self:Charged()
		else
			if self.AnimationHitEnd and self.HoldTime >= SkillStats.BaseChargeTime.Value then
				self:NoneCharged()	
			else	
				repeat  if self.CastedSkill or self.CleaningUp then break end  wait() 
				until self.AnimationHitEnd and self.HoldTime >= SkillStats.BaseChargeTime.Value
	
				self:NoneCharged()
			end	
		end	
	elseif self.CastedSkill and not self.Animation then

		print("Animation not there")
		self:Destroy()
		return
	end
	
end

--function module:MouseButton2_InputBegan(Info)

--end

--function module:MouseButton2_InputEnded(Info)

--end
-- Equip/UnEquip
function module:Equip()
	print("Equipped")
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
	
	local Mana = self.PlayerObject.Character:GetAttribute("Mana")	
	self.PlayerObject.Character:SetAttribute("Mana", Mana - SkillStats.NoneChargeCost.Value)

	self.PlayerObject.Character:SetAttribute("AutoRotate",false)
	print("Casting skill now")
	self.CastedSkill = true
	local MouseInfo = shared.Remotes.RequestInfo:InvokeClient(self.PlayerObject.Player,"RequestMousePosition")
	print(MouseInfo)
	

	local fireballs 	
	if 	self.Weld["FireBall"]  then
		fireballs = self.Weld["FireBall"] 
	else
		fireballs = script.FireBalls:Clone()
		fireballs.PrimaryPart = fireballs["Center"]
		fireballs:SetPrimaryPartCFrame(self.PlayerObject.Character.HumanoidRootPart.CFrame * CFrame.new(0,2,6))
		local weld = Instance.new("WeldConstraint")
		weld.Part1 = fireballs.PrimaryPart
		weld.Part0 = self.PlayerObject.Character.HumanoidRootPart
		weld.Parent = weld.Part1
		fireballs.Parent = workspace.Projectiles
		self.Weld["FireBall"] = fireballs
	end
	

	self.MagicCircleObjects = self.MagicCircleObjects or {}
	for i,v in pairs(fireballs:GetChildren()) do
		if v:IsA("Part") and v:FindFirstChild("Circle") then
			if not self.MagicCircleObjects[v.Parent] then
				self.MagicCircleObjects[v] = require(shared.SharedClasses.MagicCircleClass)(v:FindFirstChild("Circle"),v)	
			end
		end
	end
	
	--for i,v in pairs(self.MagicCircleObjects) do
	--	print("Emiting thing")
	--	v:Emit()
	--	--self.SkillAssets["FireBallMagicCirclObjects" .. i.Name] = v
	--	wait(0.2)
	--end

	self.connection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		if not fireballs.Parent then print("Bozo what") self.connection:Disconnect() end
		local positions = fireballs
		local ActualBalls = self.PlayerObject.ActiveFireballs
		if ActualBalls  then
			for i,v in pairs(ActualBalls) do
				if not i or not v  then continue end
				if positions:FindFirstChild(v.Name)  and v:FindFirstChild("FollowPlayerBp") then
					local bp = v:FindFirstChild("FollowPlayerBp")
					bp.Position = positions:FindFirstChild(v.Name) .Position
					v.Orientation = positions:FindFirstChild(v.Name) .Orientation
				end
			end
		end

	end)
	for i,v in pairs(fireballs:GetChildren()) do
		if v.Name == "Center" or self.PlayerObject.ActiveFireballs[i] ~= nil  then continue end
		
		print(self.PlayerObject.ActiveFireballs[i])
		self.MagicCircleObjects[v]:Emit()

		wait(0.1)
		if i == 5 then print("5", v)  end
		local ActualBallObject = v:Clone()
		ActualBallObject.Parent = workspace.Projectiles
		local sound = script.fireballsound:Clone()
		sound.Parent = ActualBallObject
		
		game.Debris:AddItem(sound,1)
		sound:Play()
		
		local EffectTable = {
			Part = ActualBallObject,
			EffectType = "BodyPosition",
			EffectInformation = {
				Type = "FollowPart",
				PartToFollow = v
			}	
		}
		ActualBallObject:SetNetworkOwner(self.PlayerObject.Player)
		shared.Remotes.ClientToServerPlayer:FireClient(self.PlayerObject.Player,"HandleClientEffects",EffectTable)

		self.PlayerObject.ActiveFireballs[i] = ActualBallObject
		for _,child in pairs(ActualBallObject:GetChildren()) do
			if child:IsA("ParticleEmitter") and child.Name ~= "Lines" then
				child.Enabled = true
			elseif child:IsA("Attachment") and child:FindFirstChild("Trail") then
				print("Has a trail")
				child.Trail.Enabled = true
			end
		end

	end
	
	self:EndCast()

	for i,v in pairs(self.MagicCircleObjects) do

		v:Pause()
		--self.SkillAssets["FireBallMagicCirclObjects" .. i] = v
		wait(0.2)
	end

	
	self:CleanUp("Cancel")

	task.spawn(function()
		wait(SkillStats.CD.Value)

		self.CD = false
	end)


end
function module:Charged()
	self.PlayerObject.Character:SetAttribute("AutoRotate",false)
	self.CastedSkill = true
	local MouseInfo = shared.Remotes.RequestInfo:InvokeClient(self.PlayerObject.Player,"RequestMousePosition")
	
	local Mana = self.PlayerObject.Character:GetAttribute("Mana")	
	self.PlayerObject.Character:SetAttribute("Mana", Mana - SkillStats.NoneChargeCost.Value)
	
	self:CleanUp()
	task.spawn(function()
		wait(SkillStats.CD.Value)

		if self.Action  then
			self.Action:Destroy()
			self.Action = nil
		end

	end)

end
function module:Destroy()
	if self.PlayerObject.ActiveFireballs  then
		for i,v in pairs(self.PlayerObject.ActiveFireballs) do
			v:Destroy()
		end
		self.PlayerObject.ActiveFireballs = {}
	end
	for i,v in pairs(self.SkillAssets) do
		if v["Destroy"] then
			v:Destroy()
		end
	end
end
return module
