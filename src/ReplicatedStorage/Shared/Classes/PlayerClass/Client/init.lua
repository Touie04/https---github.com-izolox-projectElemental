-- Services
local players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local Uis = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local ts = game:GetService("TweenService")

-- Modules

-- Classes

-- Functions

-- Variables
local bp = Instance.new("BodyPosition")
bp.MaxForce = Vector3.new(1,1,1) * 1000
bp.P = 1000
bp.D = 500

local DoubleJumpCD = 0.5
-- Module

local Class = shared.ClassGenerator:extend()

function Class:new(Object)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
	self.Player = Object
	
	-- Implementations
	self:implement(require(script:WaitForChild("UiManager")))
	self:implement(require(script:WaitForChild("LoadingScreen")))
	self:implement(require(script:WaitForChild("RequestFunctions")))
	
	--ImplementationSetup--
	task.spawn(function()
		self:LoadingScreen_Setup()
		self:Init_Hud()
	end)
	
	-- Loading ui ---
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	self.Hud = self.PlayerGui:WaitForChild("Hud")
	self.Stats = self.Hud:WaitForChild("Stats")
	self.StatsUI = self.Hud:WaitForChild("StatsUI")
	self.ExpBar = self.Stats:WaitForChild("EXP")
	self.HealthBar = self.Stats:WaitForChild("HP")
	self.ManaBar = self.Stats:WaitForChild("MP")
	self.StaminaBar = self.Stats:WaitForChild("SP")
	self.Money = self.StatsUI:WaitForChild("Money")
	self.Level = self.StatsUI:WaitForChild("Level")
	self.ToolBar = self.Hud:WaitForChild("ToolBar")
	self.Elements = self.Hud:WaitForChild("Elements")
	self.ClientRenderedEffects = {}

	self.Loaded = true
	self.Character = self.Player.Character or self.Player.CharacterAdded:Wait()
	self.Humanoid = self.Character:WaitForChild("Humanoid")	
	self.HumanoidRootpart = self.Character:WaitForChild("HumanoidRootPart")
	self.HasDoubleJumped = false
	self.CanDoubleJump  = false
	self.Animations = script.Parent:WaitForChild("Animations")
	


	for i,v in pairs(self.Animations:GetChildren()) do
		if v:IsA("Animation") then
			self.Humanoid:LoadAnimation(v):Play()
		end
	end
	-- RemoteEvents/Functions --
	shared.CommunicationRemote.OnClientEvent:Connect(function(Type,Info)
		if self[Type] then self[Type](self,Info) end

	end)
	shared.Remotes.RequestInfo.OnClientInvoke = function(Type)
		if Type == "RequestMousePosition" then
			return self.Player:GetMouse().Hit.Position
			elseif  self[Type] then
				if type(self[Type]) == "function" then
					return self[Type](self)
				else
					return self[Type]
			end
 		end
	end
	repeat wait() until self.ServerLoaded 
	
	for i,v in pairs(self.AttributeChangedFunctions) do
		v(self)
	end
	
	-- Attribute management
	self.Character.AttributeChanged:Connect(function(AttributeName)
		if self.AttributeChangedFunctions[AttributeName] then
			self.AttributeChangedFunctions[AttributeName](self)
		end
	end)
	self.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		self.AttributeChangedFunctions["Health"](self)
	end)
	self.Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
		self.AttributeChangedFunctions["Health"](self)
	end)
	-- HumanoidStateMachine --
	self.Humanoid.StateChanged:Connect(function(old,new)
		if new == Enum.HumanoidStateType.Jumping then
			if not self.CanDoubleJump then
				task.wait(.2)
				if self.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
					self.CanDoubleJump = true
				end
			end
		elseif new == Enum.HumanoidStateType.Landed then
			self.CanDoubleJump = false
			self.HasDoubleJumped = false
		end
	end)
	--- Input Management--
	Uis.InputBegan:Connect(function(key,gpe)
		local keyname =  (key.UserInputType == Enum.UserInputType.Keyboard and key.KeyCode.Name) or ((key.UserInputType == Enum.UserInputType.MouseButton1 or key.UserInputType == Enum.UserInputType.MouseButton2 ) and key.UserInputType.Name)
		if keyname then
			local Info = {}
			Info["Mouse"] = self.Player:GetMouse()
			Info["gpe"] = gpe
			Info["MouseOnUi"] = self.MouseOnUi
			shared.CommunicationRemote:FireServer("InputBegan",keyname,Info)
			
		end
	end)
	Uis.InputEnded:Connect(function(key,gpe)
		local keyname = (key.UserInputType == Enum.UserInputType.Keyboard and key.KeyCode.Name) or ((key.UserInputType == Enum.UserInputType.MouseButton1 or key.UserInputType == Enum.UserInputType.MouseButton2 ) and key.UserInputType.Name)
		if keyname then
			local Info = {}
			Info["Mouse"] = self.Player:GetMouse()
			Info["gpe"] = gpe
			Info["MouseOnUi"] = self.MouseOnUi
			shared.CommunicationRemote:FireServer("InputEnded",keyname,{})
		end
	end)
	Uis.JumpRequest:Connect(function()
		if  self.CanDoubleJump and not self.HasDoubleJumped and self.Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
			self.HasDoubleJumped = true
			self.Humanoid.Animator:LoadAnimation(self.Animations.Flip):Play()
			self.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			spawn(function()
				self.CanDoubleJump = false	
			end)

		end
	end)


	-- RenderStepped ---
	game:GetService("RunService").RenderStepped:Connect(function()
		if not self.ClientRenderedEffects then return end
		for i,v in pairs(self.ClientRenderedEffects) do
			if v["Part"] and v["EffectType"]  and v["EffectInformation"] then
				if v["EffectType"] == "BodyPosition" and v["Part"] and v["Part"]:FindFirstChild("BodyPosition") then
					if  v["EffectInformation"]["Type"] == "FollowPart" and v["EffectInformation"]["PartToFollow"]  then
						v["Part"]:FindFirstChild("BodyPosition").Position = v["EffectInformation"]["PartToFollow"].Position
						v["Part"].Orientation = v["EffectInformation"]["PartToFollow"].Orientation
					end
				end
			end
		end
	end)

	--task.spawn(function()
	--	wait(10)
	--	print("waited my 10")
	--	self.Loaded = true
	--end)
end
function Class:OnServerSideLoaded()
	print("Server loaded")
	self.ServerLoaded = true
end
function Class:HandleClientEffects(Info)
	if not Info["EffectType"] then print("No effects type given") return end
	Info["Part"].Anchored = true
	local EffectsType = Info["EffectType"]
	if EffectsType == "BodyPosition"  and Info["Part"] then
		if Info["EffectInformation"] and Info["EffectInformation"]["Type"] == "FollowPart" then
			local PartToFollow = Info["EffectInformation"]["PartToFollow"] 
			if not PartToFollow then print("No Part to follow") return end
			print("Bozoman")

			Info["Part"].Anchored = true
			local bp =	bp:Clone()
			bp.P = math.random(700,1200)
			bp.D =( bp.P / math.random(2.2,3))
			bp.Parent = Info["Part"]
			bp.Position = PartToFollow.Position

			self.ClientRenderedEffects[Info["Part"]] = Info
			Info["Part"].Anchored = false
		end
	elseif EffectsType == "BodyVelocity" then
		
	end
end



return Class