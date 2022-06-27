
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

-- Module
local module = {}
local StatsRegenDT = 0
local StatsDrainDT = 0
local dttick = 0
module.BozoAlert = "Bozo action manager"
function module:SetupActionManager()
	-- Variables --
	local EditStat = {
		Mana = function(Amt)
			local currentvalue = self.Character:GetAttribute("Mana")
			local maxvalue =self.Character:GetAttribute("MaxMana")
			self.Character:SetAttribute("Mana",math.clamp(currentvalue + Amt,0, maxvalue))
		
		end,
		Health = function(Amt)
			self.Humanoid.Health =  math.clamp(self.Humanoid.Health + Amt,0,self.Humanoid.MaxHealth)
	
		end,
		Stamina = function(Amt)
			local currentvalue = self.Character:GetAttribute("Stamina")
			local maxvalue =self.Character:GetAttribute("MaxStamina")
			self.Character:SetAttribute("Stamina",math.clamp(currentvalue + Amt,0, maxvalue))
	
		end,
	}
	if self.Connection then print("Connection already exists") self.Connection:Disconnect() end
	self.Connection = nil
	--- Connection --
	self.Connection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		if not self.Player or not self.Character or not self.Player:IsDescendantOf(game.Players) then return end
		if self.IsDead then return end
		dttick += dt
		if dttick >= 0.05 then
			dttick = 0
			local IsAnchored =false
			local DrainTable = {}
			if self.ActionFolder  then
				for i,v in pairs(self.ActionFolder:GetChildren()) do
					if v.Name == "ManaDrain" and (v:IsA("NumberValue") or v:IsA("IntValue")) then
						if self.Character:GetAttribute("Mana") <= (v.Value * -1) then
							module.RemoveAction(self,v)
						end
						DrainTable["Mana"] = true 
							
						EditStat["Mana"](v.Value * dt)
					elseif v.Name =="StaminaDrain" and(v:IsA("NumberValue") or v:IsA("IntValue"))  then
						if self.Character:GetAttribute("Stamina") <= v["StaminaDrain"]* -1 then
							module.RemoveAction(self,v)
						end
						DrainTable["Stamina"] = true
						EditStat["Stamina"](v.Value * dt)
					elseif v.Name == "HealthDrain" and (v:IsA("NumberValue") or v:IsA("IntValue"))  then
						if self.Humanoid.Health <= v.Value* -1 then
							module.RemoveAction(self,v)
						end
						DrainTable["Health"] = true
						EditStat["Health"](v.Value * dt)
						-- Stuns/Misc --
					elseif v.Name == "Anchor" then
						IsAnchored = true
					end
				end
				if IsAnchored then 
			
					for i,v in pairs(self.HumanoidRootPart:GetChildren()) do
						if v:IsA("BodyVelocity") or v:IsA("BodyPosition") and v.Name ~= "anchorbp" then
							
							v:Destroy()
							self.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
						end
					end
					
				
					local anchorbp = self.HumanoidRootPart:FindFirstChild("anchorbp") 
					if not anchorbp then
						anchorbp = Instance.new("BodyVelocity")
						anchorbp.Name = "anchorbp"
						anchorbp.MaxForce = Vector3.new(1,1,1) * 10^20
						anchorbp.Velocity = Vector3.new(0,0,0)
						anchorbp.Parent = self.HumanoidRootPart
					end
					--self.Character.HumanoidRootPart.Anchored = true
				else
					local anchorbp = self.HumanoidRootPart:FindFirstChild("anchorbp")
					if anchorbp then
						anchorbp:Destroy()
						self.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
						
					end
					self.Character.HumanoidRootPart.Anchored = false
				end
			else
				print("No ActionFolder found")
			end	

			--print(DrainTable,not DrainTable["Mana"])

			local MaxMana = self.Character:GetAttribute("MaxMana")
			local Mana = self.Character:GetAttribute("Mana")
			local Stamina = self.Character:GetAttribute("Stamina")
			local MaxStamina = self.Character:GetAttribute("MaxStamina")



			if not DrainTable["Health"] then
				local HealthRegen = ((self.CalculateStat(self,"HealthRegen")) or 1/100 )* dt
				self.Humanoid.Health = math.clamp(self.Humanoid.Health+(HealthRegen),0,self.Humanoid.MaxHealth)
			end
			if not DrainTable["Mana"] then
				local ManaRegen = ((self.CalculateStat(self,"ManaRegen")) or 1 ) * dt
				self.Character:SetAttribute("Mana",math.clamp(Mana+(ManaRegen),0,MaxMana))
			end
			if not DrainTable["Stamina"] then
				local StaminaRegen = ((self.CalculateStat(self,"StaminaRegen"))  or 1) * dt
				self.Character:SetAttribute("Stamina",math.clamp(Stamina+(StaminaRegen),0,MaxStamina))
			end

			if self.Character:GetAttribute("AutoRotate") then
				--local MouseInfo = shared.Remotes.RequestInfo:InvokeClient(self.Player,"RequestMousePosition")

				--local  dir = (MouseInfo - self.Character.HumanoidRootPart.Position).Unit

				--if (MouseInfo - self.Character.HumanoidRootPart.Position).Magnitude >=6  then
				--	print(CFrame.lookAt(self.Character.HumanoidRootPart.Position,MouseInfo))
				--	self.Character.HumanoidRootPart.CFrame = CFrame.lookAt(self.Character.HumanoidRootPart.Position,MouseInfo)
				--end
			end
		end
	end)
end
function module:GetAct()
	return self.ActionFolder
end
function module:CheckForAction(Action,Type,ActionToCheck)
	local ActionChecks = {
		CanAttack = {"PerformingAction","UsingSkill","CastingSpell","Stun","ManaShield"},
		CanDash = {"PerformingAction","UsingSkill","CastingSpell","Stun","ManaShield","Dashing"},
		CanSprint = {"PerformingAction","UsingSkill","CastingSpell","Stun","ManaShield","Dashing","Sprinting"},
	}
	if Type and Type == "ChildAdded" then  -- Child Added
		if ActionChecks[Action] then
			local found = false
			for i,v in pairs(ActionChecks[Action]) do
				if ActionToCheck == v then
					found = true
					break
				end
			end
			return not found
		else
			print("Action not found")
			return false
		end
	else -- Regular check
		if self.ActionFolder:FindFirstChild(Action) then
			print("B")
			return true
		elseif ActionChecks[Action] then
			local found = false
			for i,v in pairs(ActionChecks[Action]) do
				if self.ActionFolder:FindFirstChild(v) then
					found = true
					break
				end
			end
			return not found
		else 
			print("b")
			return false
		end

	end


end
function module:AddAction(Action)
	print("Addactioncalled", self.ActionTable)
end
function module:RemoveAction(Action)
	if not Action then return end
	if typeof(Action) == "Instance" then
		Action:Destroy()
	else
		if self.ActionFolder:FindFirstChild(Action) then
			self.ActionFolder[Action]:Destroy()
		end

	end


	print("RemoveActionCalled",Action, self.ActionTable)
end
return module
