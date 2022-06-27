
-- Services
local players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ts = game:GetService("TweenService")
-- Modules

-- Classes

-- Variables
local DashCD = 0.7
-- Functions

-- Module
local module = {}

local begancalled = false
function module:InputBegan(Key,Info)

	if self.IsDead then return end
	self.KeysPressed[Key] = true
	if self.NeededKeys[Key]  then

		if self[self.NeededKeys[Key]] and typeof(self[self.NeededKeys[Key]]) == "function" then
				self[self.NeededKeys[Key]](self,"InputBegan",Info)
			end
		for i,v in pairs(self.NeededKeys) do
			if Key == i then
				if string.find(v,"Skill")  then
					self:EquipSkill(v,Info)
				end
			end
		end
	end
	if Key == "MouseButton1" then
		print(Info["MouseOnUi"])
		if self.EquippedSkill and not Info["MouseOnUi"] then
			begancalled = true
			self:UseSkill("InputBegan",Info)
		end
		if Info["MouseOnUi"] and self.ToolBar[Info["MouseOnUi"]] then
			if self.EquippedSkill == Info["MouseOnUi"] then
				self:UnEquipSkill(Info["MouseOnUi"])
			else
				self:EquipSkill(Info["MouseOnUi"])
			end
		end
 	elseif Key == "MouseButton2" then
		
	end

end
function module:InputEnded(Key,Info)
	if self.IsDead then return end
	self.KeysPressed[Key] = false
	if self.KeysPressed[Key] then
		self.KeysPressed[Key] = nil
	end

	if self.NeededKeys[Key] then
		
		if self[self.NeededKeys[Key]] and typeof(self[self.NeededKeys[Key]]) == "function" then
			
			self[self.NeededKeys[Key]](self,"InputEnded",Info)
		end
	end
	if Key == "MouseButton1"  then
		print(Info["MouseOnUi"])
		if self.EquippedSkill  and not Info["MouseOnUi"]  and begancalled  then
			begancalled = false
			self:UseSkill("InputEnded",Info)
		end
	
	elseif Key == "MouseButton2" then

	end
	--for i,v in pairs(self.NeededKeys) do
	--	if Key == i then
	--		if string.find(v,"Skill") and self.Data.EquippedSkills[v] then
	--			self:UseSkill(self.Data.EquippedSkills[v],"InputEnded",Info)
	--		end
	--	end
	--end
end  
function module:Dash(Type,Info) -- Dashing
	if Type == "InputBegan" and not Info["gpe"] then
		local Stamina = self.Character:GetAttribute("Stamina")
		--print("Dashing",self.KeysPressed,self:CheckForAction("CanDash"),self.DashCD,Stamina)
		if not self:CheckForAction("CanDash") or Stamina < self.BaseDashDrain or self.DashCD then return end
		self.Character:SetAttribute("Stamina",Stamina - self.BaseDashDrain)
		self.DashCD = true
		local Dash  = Instance.new("StringValue")
		Dash.Name = "Dahing"
		Dash.Parent = self.ActionFolder
		game.Debris:AddItem(Dash,0.6)
		local DTrail1 = shared.Shared.Assets.DashTrail.DTrail1:Clone()
		local DTrail2 = shared.Shared.Assets.DashTrail.DTrail2:Clone()
		DTrail1.Parent = self.HumanoidRootPart
		DTrail2.Parent = self.HumanoidRootPart
		DTrail1.DashTrail.Attachment0 = DTrail1
		DTrail1.DashTrail.Attachment1 = DTrail2

		game.Debris:AddItem(DTrail2,0.5)
		game.Debris:AddItem(DTrail1,0.5)

		local bvel = Instance.new("BodyVelocity")
		bvel.Name = "DashVel"
		bvel.MaxForce = Vector3.new(1,1,1) * 10^5

		local CameraInfo = shared.Remotes.RequestInfo:InvokeClient(self.Player,"RequestCameraInfo")
		local MouseBehavior = shared.Remotes.RequestInfo:InvokeClient(self.Player,"RequestMouseBehavior")
		
		local con1 
		con1 = self.ActionFolder.ChildAdded:Connect(function(child)
			if not Dash  or not Dash.Parent == self.ActionFolder or not bvel or not bvel.Parent == self.ActionFolder then

				con1:Disconnect()
			end
			if not self:CheckForAction("CanDash","ChildAdded",child.Name) then
				bvel:Destroy()
				Dash:Destroy()
				con1:Disconnect()
			end
		end)

		local keystodash = {"W","A","S","D"}
	local multiplekeyspressed: boolean = false
		local keycount = 0
		for i,v in pairs(keystodash) do
			if self.KeysPressed[v] then
				keycount += 1
				if keycount >= 2 then
					multiplekeyspressed = true
					break
				end
			end
		end
		if self.KeysPressed["W"] then
			local anim = self.Animator:LoadAnimation(script.DashFoward)
			anim:Play()
			anim:AdjustSpeed(1.5)
			bvel.Velocity = (not multiplekeyspressed and CameraInfo.LookVector * 100) or  self.HumanoidRootPart.CFrame.LookVector * 100
			-- bvel.Velocity = self.HumanoidRootPart.CFrame.LookVector * 100
			bvel.Parent = self.HumanoidRootPart 
			game.Debris:AddItem(bvel,0.25)
		elseif self.KeysPressed["S"] then
			local anim = (MouseBehavior == "LockCenter" and self.Animator:LoadAnimation(script.DashBackward)) or self.Animator:LoadAnimation(script.DashFoward)
			anim:Play()
			anim:AdjustSpeed(1.5)
			bvel.Velocity =     MouseBehavior == "LockCenter" and CameraInfo.LookVector * -100 or (not multiplekeyspressed and CameraInfo.LookVector * -100 or self.HumanoidRootPart.CFrame.LookVector * 100)
			bvel.Parent = self.HumanoidRootPart		
			game.Debris:AddItem(bvel,0.25)
		elseif self.KeysPressed["A"] then
			local anim = (MouseBehavior == "LockCenter" and self.Animator:LoadAnimation(script.DashLeft)) or self.Animator:LoadAnimation(script.DashFoward)
			anim:Play()
			anim:AdjustSpeed(1.5)
			bvel.Velocity =   MouseBehavior == "LockCenter" and CameraInfo.RightVector * -100 or ((not multiplekeyspressed and  CameraInfo.RightVector * -100) or self.HumanoidRootPart.CFrame.LookVector *  100)
			bvel.Parent = self.HumanoidRootPart
			game.Debris:AddItem(bvel,0.25)
		elseif self.KeysPressed["D"] then
			local anim = (MouseBehavior == "LockCenter" and self.Animator:LoadAnimation(script.DashRight)) or self.Animator:LoadAnimation(script.DashFoward)
			anim:Play()
			anim:AdjustSpeed(1.5)
			bvel.Velocity =   MouseBehavior == "LockCenter" and CameraInfo.RightVector * 100 or (not multiplekeyspressed and CameraInfo.RightVector * 100 or self.HumanoidRootPart.CFrame.LookVector * 100)
			bvel.Parent = self.HumanoidRootPart 
			game.Debris:AddItem(bvel,0.25)	
		else
			local anim = self.Animator:LoadAnimation(script.DashFoward)
			anim:Play()
			anim:AdjustSpeed(1.5)
			bvel.Velocity =   self.HumanoidRootPart.CFrame.LookVector * 100	
			bvel.Parent = self.HumanoidRootPart
			game.Debris:AddItem(bvel,0.25)	
		end

		--//CD\\--
		task.spawn(function()
			task.wait(DashCD)
			self.DashCD = false
		end)
	elseif Type == "InputEnded" then

	end
end
function module:Block(Type,Info) -- Block/ManaShield
	if Type == "InputBegan" and not self.ManaShieldCD and not Info["gpe"] then
		
		local Drain =self.ShieldDrain
		if self.Character:GetAttribute("Mana") <= Drain * -1.5 or self.SpawnedAssets["ManaShield"] then return end
		self.ManaShieldCD = true
		-- Calculate Drain


		if not self.ManaShieldDrain then
			self.ManaShieldDrain = Instance.new("IntValue")
			self.ManaShieldDrain.Name = "ManaDrain"
			self.ManaShieldDrain.Value = Drain
			self.ManaShieldDrain.Parent = self.ActionFolder

		end
		if not self.ManaShieldAction  then

			self.ManaShieldAction = Instance.new("StringValue")
			self.ManaShieldAction.Name = "ManaShield"
			self.ManaShieldAction.Parent = self.ActionFolder
		end


		local ManaShield = shared.SharedAssets:FindFirstChild("ManaShieldModel"):Clone()
		-- local MagicCircle = shared.SharedAssets.MagicCircle.Attachment:Clone()
		-- local ManaCircleObject = require(shared.SharedClasses.MagicCircleClass)(MagicCircle,self.Character.HumanoidRootPart)
		-- ManaCircleObject:Emit(1,1)

		self.SpawnedAssets["ManaShield"] = ManaShield
		-- self.SpawnedAssets["ManaCircleObject"] = ManaCircleObject		
		if ManaShield:IsA("Model") then
			ManaShield.Parent = workspace.Projectiles
			ManaShield:SetPrimaryPartCFrame(self.Character.HumanoidRootPart.CFrame)
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = self.Character.HumanoidRootPart
			weld.Part1 = ManaShield.PrimaryPart
			weld.Parent= weld.Part1
			for i,v in pairs(ManaShield:GetChildren()) do
				local ti = TweenInfo.new(0.15,Enum.EasingStyle.Quad)
				local goal = {}
				goal.Transparency = 0.6
				goal.Size = v.Size * 7

				local tween = ts:Create(v,ti,goal)
				tween:Play()
			end
			task.spawn(function()
				while true do 
					if ManaShield and ManaShield.Parent == workspace.Projectiles then
						for i,v in pairs(ManaShield:GetChildren()) do
							local effect = v:Clone()

							local weld = Instance.new("WeldConstraint")
							weld.Part0 = effect
							weld.Part1 = ManaShield.PrimaryPart
							weld.Parent= weld.Part1

							effect.Parent = v
							local ti = TweenInfo.new(0.2,Enum.EasingStyle.Cubic)
							local goal = {}
							goal.Transparency = 1
							goal.Size = effect.Size * 2

							local tween = ts:Create(effect,ti,goal)
							tween:Play()
							tween.Completed:Wait()
							effect:Destroy()
							break
						end
						wait(1)
					else
						break
					end

				end
			end)
		else
			ManaShield.Parent = workspace.Projectiles
			ManaShield.Position = self.Character.HumanoidRootPart.Position

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = self.Character.HumanoidRootPart
			weld.Part1 = ManaShield
			weld.Parent= self.Character.HumanoidRootPart

			local ti = TweenInfo.new(0.1,Enum.EasingStyle.Bounce)
			local goal = {}
			goal.Transparency = 0.6
			goal.Size = ManaShield.Size * 7

			local tween = ts:Create(ManaShield,ti,goal)
			tween:Play()

			task.spawn(function()
				while true do 
					if ManaShield and ManaShield.Parent == workspace.Projectiles then
						local effect = ManaShield:Clone()
						local weld = Instance.new("WeldConstraint")
						weld.Part0 = effect
						weld.Part1 = ManaShield
						weld.Parent= weld.Part1

						effect.Parent = effect
						local ti = TweenInfo.new(0.2,Enum.EasingStyle.Cubic)
						local goal = {}
						goal.Transparency = 1
						goal.Size = effect.Size * 2

						local tween = ts:Create(effect,ti,goal)
						tween:Play()
						tween.Completed:Wait()
						effect:Destroy()
						wait(1)
					else
						break
					end

				end
			end)
		end


	elseif Type == "InputEnded" then
		local ManaShield =  self.SpawnedAssets["ManaShield"]
		local ManaCircle = self.SpawnedAssets["ManaCircleObject"]
		if ManaCircle  then
			ManaCircle:Destroy()
			self.SpawnedAssets["ManaCircleObject"] = nil
		end

		if ManaShield then

			if ManaShield:IsA("Model") then
				for i,v in pairs(ManaShield:GetChildren()) do
					local ti =  TweenInfo.new(0.2,Enum.EasingStyle.Cubic)
					local goal = {}
					goal.Transparency = 1
					goal.Size = v.Size * 2

					local tween = ts:Create(v,ti,goal)
					tween:Play()
				end
				wait(0.15)
			else
				print("Not Model")
				local ti =  TweenInfo.new(0.2,Enum.EasingStyle.Cubic)
				local goal = {}
				goal.Transparency = 1
				goal.Size = self.SpawnedAssets["ManaShield"].Size * 2

				local tween = ts:Create(self.SpawnedAssets["ManaShield"],ti,goal)
				tween:Play()
				tween.Completed:Wait()
			end
			if self.SpawnedAssets["ManaShield"]  then
				self.SpawnedAssets["ManaShield"]:Destroy()
				self.SpawnedAssets["ManaShield"] = nil
			end
		end

		if self.ManaShieldDrain  then
			self.ManaShieldDrain:Destroy()
			self.ManaShieldDrain = nil
		end
		if self.ManaShieldAction then
			self.ManaShieldAction:Destroy()
			self.ManaShieldAction = nil
		end
		wait(0.2)
		self.ManaShieldCD = false

	elseif Type == "BreakShield" then
		local ManaShield =  self.SpawnedAssets["ManaShield"]
		local ManaCircle = 	self.SpawnedAssets["ManaCircleObject"]
		if ManaCircle  then
			ManaCircle:Destroy()
			self.SpawnedAssets["ManaCircleObject"] = nil
		end

		if self.ManaShieldDrain  then
			self.ManaShieldDrain:Destroy()
			self.ManaShieldDrain = nil
		end
		if self.ManaShieldAction then
			self.ManaShieldAction:Destroy()
			self.ManaShieldAction = nil
		end
		if ManaShield then

			self.SpawnedAssets["ManaCircleObject"] = nil
			if ManaShield:IsA("Model") then
				for i,v in pairs(ManaShield:GetChildren()) do
					v.Color = Color3.fromRGB(250, 0, 0)
					local ti =  TweenInfo.new(0.2,Enum.EasingStyle.Cubic)
					local goal = {}
					goal.Transparency = 1
					goal.Size = v.Size * 2
					goal.Color = Color3.new(0.494118, 0, 0.00784314)
					local tween = ts:Create(v,ti,goal)
					tween:Play()
				end
				wait(0.15)
			else
				ManaShield.Color = Color3.fromRGB(250, 0, 0)
				local ti = TweenInfo.new(0.1,Enum.EasingStyle.Back)
				local goal = {}
				goal.Transparency = 1
				goal.Size = self.SpawnedAssets["ManaShield"].Size * 1.3
				goal.Color = Color3.new(0.494118, 0, 0.00784314)
				local tween = ts:Create(self.SpawnedAssets["ManaShield"],ti,goal)
				tween:Play()
				tween.Completed:Wait()
			end
			if self.SpawnedAssets["ManaShield"]  then
				self.SpawnedAssets["ManaShield"]:Destroy()
				self.SpawnedAssets["ManaShield"] = nil
			end
			wait(3)
			self.ManaShieldCD = false
		end
	end
end
function module:Sprint(Type,Info)
	if self.Settings.SprintToggle then
		if Type == "InputBegan" then
			if not self.ActionFolder:FindFirstChild("Sprinting") then
				local Stamina = self.Character:GetAttribute("Stamina")
				if not self:CheckForAction("CanSprint") or Stamina < 2  then return end

				local sprint = Instance.new("StringValue")
				sprint.Name = "Sprinting"
				sprint.Parent = self.ActionFolder

				self.Humanoid.WalkSpeed = self:CalculateStat("DefaultSprintSpeed")
			else
				if self.ActionFolder:FindFirstChild("Sprinting") then
					self.ActionFolder:FindFirstChild("Sprinting"):Destroy()
				end

				self.Humanoid.WalkSpeed = self:CalculateStat("DefaultWalkSpeed")
			end
		
		end
	else
		if Type == "InputBegan" then
			local Stamina = self.Character:GetAttribute("Stamina")
			if not self:CheckForAction("CanSprint") or Stamina < 2  then return end

			local sprint = Instance.new("StringValue")
			sprint.Name = "Sprinting"
			sprint.Parent = self.ActionFolder

			self.Humanoid.WalkSpeed = self:CalculateStat("DefaultSprintSpeed")

		elseif Type == "InputEnded" then
			if self.ActionFolder:FindFirstChild("Sprinting") then
				self.ActionFolder:FindFirstChild("Sprinting"):Destroy()
			end

			self.Humanoid.WalkSpeed = self:CalculateStat("DefaultWalkSpeed")
		end	
	end
end
function module:CalculateStat(StatName)
	local ManaPool = self.Character:GetAttribute("ManaControl")
	local Focus = self.Character:GetAttribute("Focus")
	local Endurance = self.Character:GetAttribute("Endurance")
	local Durability = self.Character:GetAttribute("Durability")
	local ManaControl = self.Character:GetAttribute("ManaControl")
	local Damage = self.Character:GetAttribute("Damage")
	local Agility = self.Character:GetAttribute("Agility")
	if not Focus or not ManaPool or not Endurance or not Durability or not ManaControl then print("Sum sus going on catch this bug") end

	local StatCalculations = {
		["ManaRegen"] = (ManaPool and (self.BaseManaRegen +  (ManaControl/self.BaseManaRegen)) ),
		["StaminaRegen"] = (Focus and (self.BaseStaminaRegen + (Focus/20))),
		["HealthRegen"] = (Endurance and self.BaseHealthRegen + (Endurance/60)),
		["Damage"] = (Damage/100),
		["DefaultWalkSpeed"] = math.max(Agility/100) + 16,
		["DefaultSprintSpeed"] = math.max(Agility/35) + 30,
		["DefaultJumpHeight"] =  math.max(Agility/100) + 10,
	}
	return StatCalculations[StatName]
end
function module:ValidateClientInfo(Info)
	local Type = Info["Type"]
	local Value = Info["Value"]
	if not Type or not Value then print("U aint send the right info monkey", Info) return false end

	if Type == "MousePosition" then

		if typeof(Value) == "Vector3" then

			local maxmagnitude = Info["MaxMagnitude"] or 40
			print((Value - self.Character.HumanoidRootPart.Position).Magnitude  <=maxmagnitude)

			return (Value - self.Character.HumanoidRootPart.Position).Magnitude  <=maxmagnitude

		else
			print("Cant compare without vector3", typeof(Value)) return false
		end

	end

end

return module
