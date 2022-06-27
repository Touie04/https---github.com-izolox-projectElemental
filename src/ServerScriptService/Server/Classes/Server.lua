-- Services
local players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local ts = game:GetService("TweenService")

-- Modules

-- Classes

-- Functions

-- Variables

-- Module

local Class = shared.ClassGenerator:extend()

function Class:new()
	shared.DataManager = require(shared.Modules.DataManager)("k34")
	self.PlayerObjects = {}
	
	for i,v in pairs(workspace.Live:GetChildren()) do
		if not v:FindFirstChild("ActionFolder") then
			local af = Instance.new("Folder")
			af.Name = "ActionFolder"
			af.Parent = v
		end
		for a,b in pairs(require(shared.Modules.DataManager.DefaultPlayerData))do
			if type(b) ~= "table" then
				v:SetAttribute(a,b)
			end
		end
	end
	
	for _,v in pairs(players:GetChildren()) do
		self.PlayerObjects[v] = require(shared.SharedClasses.PlayerClass)(v)
	end
	players.PlayerAdded:Connect(function(plr)
		if not self.PlayerObjects[plr] then
			self.PlayerObjects[plr] = require(shared.SharedClasses.PlayerClass)(plr)
		end
	end)
	players.PlayerRemoving:Connect(function(plr)
		if self.PlayerObjects[plr] then
			self.PlayerObjects[plr]:Release()
			self.PlayerObjects[plr] = nil
		end
	end)
	print(self.PlayerObjects)
	

	
	-- Communications--
	shared.CommunicationRemote.OnServerEvent:Connect(function(plr,Type,Info,MiscDataType)
		if self.PlayerObjects[plr] and self.PlayerObjects[plr][Type] then
			self.PlayerObjects[plr][Type](self.PlayerObjects[plr],Info,MiscDataType)
		end
	end)
	shared.Shared.Remotes.RequestInfo.OnServerInvoke = function(plr,Type,Info,MiscDataType)
		local toret: any = false
		if self.PlayerObjects[plr] and self.PlayerObjects[plr][Type] then
			 toret = self.PlayerObjects[plr][Type](self.PlayerObjects[plr],Info,MiscDataType)
			 
		end
		print(toret)
		return toret
	end
	
end
return Class