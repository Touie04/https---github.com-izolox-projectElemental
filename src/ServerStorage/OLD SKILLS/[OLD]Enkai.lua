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
	print(PlayerObject.Player)
	self.PlayerObject = PlayerObject
	self.SkillName = script.Name	
	self.HoldTime = 0
	self.SkillAssets = {}
	self.CastedSkill = false
	self.OnCD = false
	self.InputBegantime = 0
	self:inherit(require(shared.SharedClasses.SkillClass))
end
-- MouseButton1 ---
function module:InputBegan(Info)

	if not self.PlayerObject or self.OnCD or not self.PlayerObject:CheckForAction("CanAttack") or not next(self.PlayerObject.ActiveFireballs) then return end

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
			if self.CastedSkill  and self.HoldTime >= SkillStats.BaseChargeTime.Value or not self.CastingCircleObj  then
				break
			end
			wait(1)
			self.HoldTime = self.HoldTime+1 
			if self.HoldTime >= SkillStats.ChargeTime.Value and self.CastingCircleObj.Attachment and not self.CastedSkill then
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
	self.PlayerObject.Character:SetAttribute("AutoRotate",true)
end
function module:InputEnded(Info)
	if self.Animation and not self.CastedSkill  then
		if self.HoldTime >= SkillStats.ChargeTime.Value then
			self:Charged()
		else
			if self.AnimationHitEnd then
				self:NoneCharged()	
			else	
				repeat wait() until self.AnimationHitEnd and self.HoldTime >= SkillStats.BaseChargeTime.Value
				self:NoneCharged()
			end	
		end	
	elseif self.CastedSkill and not self.Animation and self.HoldTime >= SkillStats.BaseChargeTime.Value then

		print("Animation not there")
		self:Destroy()
		return
	end

	print("done",self)
end

function module:MouseButton2_InputBegan(Info)
	
end

function module:MouseButton2_InputEnded(Info)
	
end
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
	self.InputBegantime += 1
	
	local Mana = self.PlayerObject.Character:GetAttribute("Mana")	
	self.PlayerObject.Character:SetAttribute("Mana", Mana - SkillStats.NoneChargeCost.Value)
	

	print("Casting skill now")
	self.CastedSkill = true
	local MouseInfo = shared.Remotes.RequestInfo:InvokeClient(self.PlayerObject.Player,"RequestMousePosition")
	print(MouseInfo)
	local ActiveFireballs = self.PlayerObject.ActiveFireballs
	local EndPosition = self.PlayerObject.Character.HumanoidRootPart.Position + Vector3.new(0,30,0)
	print(ActiveFireballs)
	if #ActiveFireballs >= 5 then
		
		for i,v in pairs(ActiveFireballs) do
			
			
			v:SetNetworkOwner(nil)
			v.Anchored = true
			
			task.spawn(function()
				
				local StartPosition = v.Position
				

				local Magnitude = (StartPosition - EndPosition).Magnitude
				local Midpoint = StartPosition:Lerp(EndPosition,math.random(0.1,0.9))

				local PointA = Midpoint  + Vector3.new(math.random(-40,40),0,math.random(-40,40))

				local spd = 0.5                 
				for i = 1,Magnitude,spd do
					local p = i/Magnitude
					local curv = require(shared.SharedModules.UtilityModule):quadBezier(p,StartPosition,PointA,EndPosition)
					v.CFrame = v.CFrame:Lerp(CFrame.new(curv, EndPosition), p)
					game:GetService("RunService").Heartbeat:Wait()
				end

				v.Position = EndPosition
				
				wait(0.1)
				v:Destroy()
			end)	
		end
		self.PlayerObject.ActiveFireballs = {}
		wait(0.7)
		
		
		local enkai = script.Entei:Clone()
		enkai.Parent = workspace.Projectiles

		enkai.Position = EndPosition
		
		for i,v in pairs(enkai:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				
				v.Enabled = true
				
			elseif v:IsA("PointLight") then
				v.Enabled = true
				
			elseif v:IsA("Attachment") and v:FindFirstChild("Smoke") then
				v:FindFirstChild("Smoke").Enabled = true		
				
			end
		end
		
		self.SkillAssets["Enkai"] = enkai
		
		
		
		
		wait(2)
		
		enkai.SmokeAttach.Smoke.Enabled = false
		local Ep = MouseInfo
		local StartPosition = enkai.Position
		
		local Magnitude = (StartPosition - Ep).Magnitude
		local Midpoint = (StartPosition - Ep) / 2

		local PointA = Midpoint

		local spd = 2   
		self:EndCast()
		for i = 1,Magnitude,spd do
			local p = i/Magnitude
			
			enkai.CFrame = CFrame.new(StartPosition,Ep):Lerp(CFrame.new(Ep,StartPosition),p)
			game:GetService("RunService").Heartbeat:Wait()
		end
		print("Done lerping entei")
	
		for i,v in pairs(enkai:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v:Destroy()
				
			elseif v:IsA("PointLight") then
				v:Destroy()
			
			elseif v:IsA("Attachment") and v:FindFirstChild("Smoke") then
				v:Destroy()
	

			end
		end
		
		local waittime = 0
		enkai.EnteiEXP.Position = MouseInfo
		for i,v in pairs(enkai.EnteiEXP:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				if waittime < v.Lifetime.Max then waittime = v.Lifetime.Max end
				v:Emit(v:GetAttribute("EmitCount"))
				
			elseif v:IsA("Attachment") and v:FindFirstChild("Smoke")  then
				task.spawn(function()
					v:FindFirstChild("Smoke").Enabled =true
					wait(0.5)
					v:FindFirstChild("Smoke").Enabled =false
				end)
				for i,v in pairs(v:GetChildren()) do
					if v.Name ~= "Smoke" and v:IsA("ParticleEmitter") then
						v:Emit(v:GetAttribute("EmitCount"))
					end
				end
			elseif v:IsA("PointLight") then
				task.spawn(function()
					v.Enabled =true
					wait(0.5)
					v.Enabled =false
				end)
			
			end
		end
		
		wait(waittime)
	end
	

	self:CleanUp()

	task.spawn(function()
		wait(SkillStats.CD.Value)

		if self.Action  then
			self.Action:Destroy()
			self.Action = nil
		end

	end)


end
function module:Charged()
	self.PlayerObject.Character:SetAttribute("AutoRotate",false)
	self.CastedSkill = true
	local Mana = self.PlayerObject.Character:GetAttribute("Mana")	
	self.PlayerObject.Character:SetAttribute("Mana", Mana - SkillStats.ChargeCost.Value)
	
	local MouseInfo = shared.Remotes.RequestInfo:InvokeClient(self.PlayerObject.Player,"RequestMousePosition")
	
	
	self:CleanUp()
	task.spawn(function()
		wait(SkillStats.CD.Value)

		if self.Action  then
			self.Action:Destroy()
			self.Action = nil
		end

	end)
	
	

end
return module
