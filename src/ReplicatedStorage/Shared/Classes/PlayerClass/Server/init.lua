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
local DefaultMana = 100
local DefaultStamina = 100
local DefaultHealth = 100
local DefaultMoney = 1
local BaseExp = 100
-- Functions
local LevelMath = function(Type,exp,level)
	if not exp or not level then return end
	if level < 1 then level = 1 end

	if Type == "CheckExpToLevel" then
		local ExpToLevel 
		ExpToLevel = (BaseExp * level) + (level * 10)
		return ExpToLevel
	end
end

-- Module
local Class = shared.ClassGenerator:extend()

function Class:new(Object)
	if not Object or not Object:IsDescendantOf(players) then  return end
	
	
	self.Player = Object
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	for i,v in pairs(script.Gui:GetChildren()) do
		if not self.PlayerGui:FindFirstChild(v.Name) then
			v:Clone().Parent = self.PlayerGui
		end
	end
	self.IsDead = true
	self.BaseStaminaRegen = 6
	self.BaseManaRegen = 3
	self.BaseHealthRegen = 1/100
	self.SpawnedAssets = {}
	self.ShieldDrain = -3 
	self.BaseDashDrain = 10
	-- DATA MANAGEMENT/Loading character -- 
	self.Profile = shared.DataManager:LoadProfile(self.Player.UserId,self.Player)
	self.Data = self.Profile.Data
	if self.Data then
		self.Data.DataVersion += 1
		print(self.Data)
	else 
		self:Release()
	end
	self.Settings = self.Data.Settings
	self.KeysPressed = {}
	local keybinds  = self.Settings.KeyBinds
	self.NeededKeys = keybinds
	print(self.NeededKeys)
	-- IMPLEMENTATIONS
	task.spawn(function()
		--self:implement(require(script.Skill))
		self:implement(require(script.PlayerFunctions))
		self:implement(require(script.ActionManager)) 
		self:implement(require(script.SkillsManager))
	end)
	
	-- IMPLEMENTATION SETUP --
	self:SetupActionManager()
	self:SkillManager_Setup()
end
function Class:LoadCharacter(FirstLoad)
	if self.Player and self.Player:IsDescendantOf(players) then
		-- Character Variables-- 
		self.DashCD = false
		self.ManaShieldCD = false
		
		for i,v in pairs(script.Gui:GetChildren()) do
			if not self.PlayerGui:FindFirstChild(v.Name) then
				v:Clone().Parent = self.PlayerGui
			end
		end
		self.Player:LoadCharacter()

		self.Character = self.Player.Character
		self.Character.Parent = workspace.Live
		self.Humanoid = self.Character:WaitForChild("Humanoid")
		self.Animator = self.Humanoid:WaitForChild("Animator")
		self.HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart")
		self.Humanoid.UseJumpPower = false

		if FirstLoad  == "FirstTimeLoading" then
			self.PlayerGui:WaitForChild("LoadingScreen").Enabled = true
			self.HumanoidRootPart.CFrame = workspace.Spawns.NotLoadedSpawn.CFrame
		end
		self.ActionFolder = self.Character:FindFirstChild("ActionFolder")
		if not self.ActionFolder then
			local af = Instance.new("Folder")
			af.Name = "ActionFolder"
			af.Parent = self.Character
			self.ActionFolder = af
		end
		self.ActionFolder:ClearAllChildren()
		self.LeftCastingAttach = self.Character["LeftHand"]["LeftGripAttachment"]
		self.LeftCastingAttach.Orientation = Vector3.new(0,0,0)
		self.RightCastingAttach = self.Character["RightHand"]["RightGripAttachment"]
		self.RightCastingAttach.Orientation = Vector3.new(0,0,0)
		--- Setting Stats---
		for i,v in pairs(self.Data)do
			if type(v) ~= "table" then
				self.Character:SetAttribute(i,v)
			end
		end
		self.Humanoid.MaxHealth = DefaultHealth + self.Data.Durability
		self.Humanoid.Health = self.Humanoid.MaxHealth
		self.Character:SetAttribute("MaxMana",DefaultMana + self.Data.ManaPool)
		self.Character:SetAttribute("Mana",self.Character:GetAttribute("MaxMana"))
		self.Character:SetAttribute("Stamina",DefaultStamina + self.Data.Endurance)
		self.Character:SetAttribute("MaxStamina",DefaultStamina+ self.Data.Endurance)

		self.Character:SetAttribute("ExpToLevel", LevelMath("CheckExpToLevel",self.Data.Exp,self.Data.Level))
		self.AttributeFunctionTable = {
			Durability = function()
				local OldMax = self.Humanoid.MaxHealth
				self.Humanoid.MaxHealth = DefaultHealth + self.Data.Durability
				local change = self.Humanoid.MaxHealth - OldMax
				self.Humanoid.Health = math.clamp(self.Humanoid.Health + change,0,self.Humanoid.MaxHealth)
			end,
			ManaPool = function()
				local OldMax = self.Character:GetAttribute("MaxMana")
				self.Character:SetAttribute("MaxMana",DefaultMana + self.Data.ManaPool)
				local change = self.Character:GetAttribute("MaxMana") - OldMax
				local stamina = self.Character:GetAttribute("Mana")

				self.Character:SetAttribute("Mana",math.clamp(stamina+change,0,self.Character:GetAttribute("MaxMana")))
			end,
			Endurance = function()

				local OldMax = self.Character:GetAttribute("MaxStamina")

				self.Character:SetAttribute("MaxStamina",DefaultStamina + self.Data.Endurance)
				local StamChange = self.Character:GetAttribute("MaxStamina") - OldMax 
			
				self.Character:SetAttribute("Stamina",math.clamp(self.Character:GetAttribute("Stamina") + StamChange,0,self.Character:GetAttribute("MaxStamina")))
			end,
			Exp = function(oldval)
				local Exp = self.Character:GetAttribute("Exp")
				local Level = self.Character:GetAttribute("Level")
				local ExpToLevel = LevelMath("CheckExpToLevel",Exp,Level)
				self.Character:SetAttribute("ExpToLevel", ExpToLevel)
				if Exp > ExpToLevel then
					local AmountOfLevelsToGain = math.floor(Exp / ExpToLevel)
					if AmountOfLevelsToGain > 0  then
						local CalculatedLevels = 0
						local LeftOverExp = Exp
						for i = 1, AmountOfLevelsToGain do
							local expcalc = LevelMath("CheckExpToLevel",Exp,Level + CalculatedLevels)
							if LeftOverExp >= expcalc  then
								print("Exp is greater than the exp to level",AmountOfLevelsToGain,LeftOverExp)
								CalculatedLevels += 1
								LeftOverExp -= expcalc
							else 
								break
							end
						end
						self.Character:SetAttribute("Level",Level + CalculatedLevels)
						self.Character:SetAttribute("Exp",LeftOverExp)
						self.Character:SetAttribute("ExpToLevel", LevelMath("CheckExpToLevel",self.Data.Exp,self.Data.Level))
						print("Exp Set")
					end
				elseif Exp == ExpToLevel then
					self.Character:SetAttribute("Level",Level + 1)
					self.Character:SetAttribute("Exp",0)
					self.Character:SetAttribute("ExpToLevel", LevelMath("CheckExpToLevel",self.Data.Exp,self.Data.Level))
				end
			end,
			ExpToLevel = function(oldval)
				self.Character:SetAttribute("ExpToLevel", LevelMath("CheckExpToLevel",self.Data.Exp,self.Data.Level))
			end,
			Level = function(OldVal)
				OldVal = OldVal or 0
				local LevelChangeAmount = self.Character:GetAttribute("Level") - OldVal
			
				if LevelChangeAmount > 0 then
					self.Character:SetAttribute("SkillPoints",self.Character:GetAttribute("SkillPoints") + LevelChangeAmount)
					self.Character:SetAttribute("StatPoints",self.Character:GetAttribute("StatPoints") + LevelChangeAmount)

				else
					
				end
				self.AttributeFunctionTable["ExpToLevel"]()
				self.AttributeFunctionTable["Exp"]()
			end,
			Mana = function()	
				local curmana = self.Character:GetAttribute("Mana")
				local maxmana = self.Character:GetAttribute("MaxMana")
				if curmana <  0 then
					self.Character:SetAttribute("Mana",0)
				elseif curmana > maxmana then
					self.Character:SetAttribute("Mana",maxmana)
				elseif curmana <= math.abs(self.ShieldDrain) + 1  then
					if self.ActionFolder:FindFirstChild("ManaShield") then
						self:Block("BreakShield")
					end
				end
			end,
			Agility = function()
				self.Humanoid.WalkSpeed = self:CalculateStat("DefaultWalkSpeed")
				self.Humanoid.JumpHeight = self:CalculateStat("DefaultJumpHeight")
			end,
		}
		for i,v in pairs(self.AttributeFunctionTable) do
			v()
		end
		self.Character.AttributeChanged:Connect(function(AttributeName)
			--
			local OldVal = self.Data[AttributeName]

			if self.Data[AttributeName]  then
				self.Data[AttributeName] = self.Character:GetAttribute(AttributeName)
			end
			if self.AttributeFunctionTable[AttributeName] then
				self.AttributeFunctionTable[AttributeName](OldVal)
			end
		end)
		self.IsDead = false
		
		self.Humanoid.WalkSpeed = self:CalculateStat("DefaultWalkSpeed")
		self.Humanoid.JumpHeight = self:CalculateStat("DefaultJumpHeight")
		
		self.Humanoid.StateChanged:Connect(function(old,new)
			self.CurrentState = new.Name
		end)
		
		
		shared.Remotes.ClientToServerPlayer:FireClient(self.Player,"OnServerSideLoaded")
		if self.ToolBar  then
			for i,v in pairs(self.ToolBar) do
				shared.Remotes.ClientToServerPlayer:FireClient(self.Player,"OnToolChanged",{Number = i,Value = (v.Name or nil)})
			end
		end
		shared.Remotes.ClientToServerPlayer:FireClient(self.Player,"OnElementChanged",{ElementType = "Primary",Element = self.Data.Element1})
		shared.Remotes.ClientToServerPlayer:FireClient(self.Player,"OnElementChanged",{ElementType = "Secondary",Element = self.Data.Element2})
		
		self.Humanoid.Died:Connect(function(...)
			print(self.Player.Name .. " Has died",...)
			self.IsDead = true
			self:OnPlayerDeath()
		end)

		return true
	end
end
function Class:OnPlayerDeath()
	print("Player has died")
	for i,v in pairs(self.NeededKeys) do		
		if string.find(v,"Skill") and self.Data.EquippedSkills[v] then
			self:UseSkill(self.Data.EquippedSkills[v],"InputEnded")
		elseif self[v] and type(self[v]) == "function" then
			self[v](self,"InputEnded")
		end
	end
	for i,v in pairs(self.SpawnedAssets) do
		if v["Destroy"] then
			print("It has a destroy function")
			v:Destroy()
		end
	end
	wait(5)
	self:LoadCharacter()
end
function Class:OnEnemyDeath(echar,enemyobject)
	if not echar then print("no echar provided") return end
local IsPlayer = (enemyobject and true) or false

	local enemy_level = echar:GetAttribute("Level")
	-- Testing calculation --

	local expgain = math.min((enemy_level * 2) + 50)
	local moneygain = math.min((enemy_level * 1.4) + 20 )
	
	self.Character:SetAttribute("Exp",self.Character:GetAttribute("Exp") + expgain)
	self.Character:SetAttribute("Money",self.Character:GetAttribute("Money") + moneygain)
	
	local sound = script.bless7:Clone()
	
	sound.Parent = self.HumanoidRootPart
	sound:Play()
	game.Debris:AddItem(sound,sound.TimeLength)
end

function Class:Release()
	self.Profile:Release()
end



return Class