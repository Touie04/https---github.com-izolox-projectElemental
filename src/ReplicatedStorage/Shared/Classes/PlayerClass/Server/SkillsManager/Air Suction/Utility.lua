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
function module:Destroy(info)
    print("Destroyed func called")
    for i,v in pairs(self.SpawnedAssets) do
        if v["Destroy"] then
            v:Destroy()
        end
    end
	self:ResetVariables(info)
end

function  module:ResetVariables(info)
    self.HoldTime = 0
	self.SkillAssets = {}
	self.cachedhumanoids = {}
	if not info then
		self.CastedSkill = false
		self.CD = false
		self.Input = false
		self.SkillCasted = false
		self.CastFrameHit = false
		self.Charged = false
		self.Reset = true	
	end
	
	for i,v in pairs(self.Connections) do
		if v["Disconnect"] then
			v:Disconnect()
		end
	end
	
	self.Connections = {}
	self.ManaDrain = self.ManaDrain and self.ManaDrain:Destroy() and nil
    self.ReachedConnection = self.ReachedConnection and self.ReachedConnection:Disconnect() and nil
    self.Connection = self.Connection and self.Connection:Disconnect() and nil
    self.Action = self.Action and self.Action:Destroy() and nil 
    self.Anchored = self.Anchored and self.Anchored:Destroy() and nil 
    self.DisableAutoRotate = self.DisableAutoRotate and self.DisableAutoRotate:Destroy() and nil 
    self.Animation = self.Animation and self.Animation:Stop() and nil 

end
return module
