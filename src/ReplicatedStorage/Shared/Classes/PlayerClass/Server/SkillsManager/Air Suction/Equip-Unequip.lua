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
function module:Equip()
	
end
function module:UnEquip()
	task.spawn(function()
		self:SkillEnd()
	end)
end
return module
