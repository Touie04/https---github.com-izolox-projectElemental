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
	self.SkillCasted = true


	local Asset = self.Assets.AirSuction:Clone()
	Asset.Parent = workspace.Projectiles
	Asset.CFrame = self.PlayerObject.Character.Head.CFrame * CFrame.new(0,0,-4)


	local weld = Instance.new("WeldConstraint")
	weld.Part1 = self.PlayerObject.HumanoidRootPart
	weld.Name = "WeldToRoot"
	weld.Part0 = Asset
	weld.Parent = weld.Part0


	self.SpawnedAssets["MainAsset"] = Asset


	for i,v in pairs(Asset:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("PointLight") or v:IsA("SpotLight") then
			v.Enabled = true
		end
	end

	local function validatepart(part)
		local tr =  (part.Parent:isA("Model") and part.Parent:FindFirstChild("Humanoid") and part.Parent~= self.PlayerObject.Character and part.Parent) or  (part.Parent.Parent:IsA("Model") and part.Parent.Parent:FindFirstChild("Humanoid") and part.Parent.Parent ~= self.PlayerObject.Character and part.Parent.Parent)  
		return tr
	end
	self.cachedhumanoids ={}
	--self.Anchored = self.Anchored and self.Anchored:Destroy() and nil
	--self.PlayerObject.HumanoidRootPart.Anchored =false
	self.Task = task.spawn(function()



		
		local tab = {
			Origin = Asset,
			Range = 30,
			Length = 1,
			Width = 10,
			Height = 10,
		}

		


		self.Connections.touched = Asset.Hitbox.Touched:Connect(function(part)
	
			if validatepart(part) then
				local echar = validatepart(part)
				local eroot = echar:FindFirstChild("HumanoidRootPart")
				if not self.cachedhumanoids[echar]  then
					print(echar,"Start touching")
					self.cachedhumanoids[echar] = {
						["Character"] = echar,
						["Parts"] = {}
					}
					table.insert(self.cachedhumanoids[echar]["Parts"],part)
					
					
					
					if eroot:FindFirstChildOfClass("BodyVelocity") then
						eroot:FindFirstChildOfClass("BodyVelocity"):Destroy()
					end
					if eroot:FindFirstChildOfClass("BodyPosition") then
						eroot:FindFirstChildOfClass("BodyPosition"):Destroy()
					end
					
					
					local AirSuctionBP = Instance.new("BodyPosition")
					AirSuctionBP.Name = "AirSuctionBP"
					AirSuctionBP.Position = Asset.Position + Vector3.new(0,0,-4)
					AirSuctionBP.MaxForce = Vector3.new(1,1,1) * 10^20
					AirSuctionBP.P = 1250
					AirSuctionBP.D = 400
					AirSuctionBP.Parent = eroot
					
				else
					if not table.find(self.cachedhumanoids[echar]["Parts"],part) then
						table.insert(self.cachedhumanoids[echar]["Parts"],part)
					end
				end
				
				
			end
		end)



		self.Connections.touchended = Asset.Hitbox.TouchEnded:Connect(function(part)
			
			if validatepart(part) then
				local echar = validatepart(part)
				local eroot = echar:FindFirstChild("HumanoidRootPart")
				if self.cachedhumanoids[echar]  then		
					if  table.find(self.cachedhumanoids[echar]["Parts"],part) then	
						table.remove(self.cachedhumanoids[echar]["Parts"],table.find(self.cachedhumanoids[echar]["Parts"],part))
					end	
					if not next(self.cachedhumanoids[echar]["Parts"]) then
						print(echar,"Done touching")
						if eroot:FindFirstChild("AirSuctionBP") then
							eroot:FindFirstChild("AirSuctionBP"):Destroy()
						end
						eroot.Velocity = Vector3.new(0,0,0)
						self.cachedhumanoids[echar] = nil
						
					end
				end
			end
		end)

		wait(0.2)

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
	if not	self.SkillCasted then return end
	self.SkillCasted = false
	local waittime = 1

	self.ManaDrain = self.ManaDrain and self.ManaDrain:Destroy() and nil
	
	if self.SpawnedAssets["MainAsset"] and self.SpawnedAssets["MainAsset"]:FindFirstChild("WeldToRoot") then
		self.SpawnedAssets["MainAsset"]:FindFirstChild("WeldToRoot"):Destroy()
		self.SpawnedAssets["MainAsset"].Anchored = true
	end
	
	
	self.Action = self.Action and self.Action:Destroy() and nil 
	self.Anchored = self.Anchored and self.Anchored:Destroy() and nil 
	
	
	if self.Task then
		task.cancel(self.Task)
		self.Task = nil
	end

	
	if self.Connections.touched then
		self.Connections.touched:Disconnect()
	end


	print(self.cachedhumanoids)
	if self.cachedhumanoids then
		for i,v in pairs(self.cachedhumanoids) do
			if v.Character  then
				print(v.Character)
				if v.Character.HumanoidRootPart:FindFirstChild("AirSuctionBP") then
					v.Character.HumanoidRootPart:FindFirstChild("AirSuctionBP"):Destroy()
				end
			end
			i.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
		end
	end

	
	if self.SpawnedAssets["MainAsset"] then
		local desc = self.SpawnedAssets["MainAsset"]:GetDescendants()

		for i,v in pairs(self.SpawnedAssets["MainAsset"]:GetDescendants()) do
			if v:IsA("ParticleEmitter") or v:IsA("PointLight") or v:IsA("SpotLight") then

				if v:IsA("ParticleEmitter") then
					if waittime < v.Lifetime.Max then
						waittime = v.Lifetime.Max
					end
				end
				v.Enabled = false
			end
		end
	end

	wait(waittime)
	self:Destroy("Skill")

	task.spawn(function() -- CoolDown
		task.wait(self.Info.CD.Value)
		self.CD = false 
	end)
end




return module
