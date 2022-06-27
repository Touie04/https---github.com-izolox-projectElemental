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
local module = shared.ClassGenerator:extend()
function module:new(PlayerObject)
	self.PlayerObject = PlayerObject
	self.Player = self.PlayerObject.Player

	--// Info \\--
	self.SkillName = script.Name	
	self.Sounds = script.Sounds
	self.Animations = script.Animations
	self.Info = script.Info
	self.Assets = script.Assets
	self.Element = script.Element.Value
	--//Vars\\--
	self.SpawnedAssets = {}
	self.HoldTime = 0
	self.CastedSkill = false
	self.CD = false
	self.Input = false
	self.SkillCasted = false
	self.CastFrameHit = false
	self.Charged = false
	--//Inheritance\\ --
	for i,v in pairs(script:GetChildren()) do
		if v:IsA("ModuleScript") then
			self:inherit(require(v))
		end
	end
	-- self:inherit(require(shared.SharedClasses.SkillClass))
end


return module


