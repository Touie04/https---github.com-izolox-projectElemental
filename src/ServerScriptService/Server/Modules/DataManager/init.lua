local ProfileService = require(shared.Utility.ProfileService)


local DataManager = shared.ClassGenerator:extend()


function DataManager:new(key)
	self.DataProfiles = {}
	self.DataKey = key or "Bozo"
	self.DataStore = ProfileService.GetProfileStore(self.DataKey,require(script.DefaultPlayerData))
end

function DataManager:LoadProfile(Key,Player)
	if not Key then return end
	local Profile = self.DataStore.Mock:LoadProfileAsync(tostring(Key),"ForceLoad")
	if Profile then
		Profile:Reconcile()
		Profile:ListenToRelease(function()
			self.DataProfiles[Key] = nil
			if Player and Player:IsDescendantOf(game.Players) then
				Player:Kick()
			end
		end)
		if Player and Player:IsDescendantOf(game:GetService("Players")) then
			self.DataProfiles[Key] = Profile
			return self.DataProfiles[Key]
		else
			self.DataStore.Mock:WipeProfileAsync(tostring(Key),"ForceLoad")   --- Remove this
			Profile:Release()
		end
	else
		return 
	end	
end
function DataManager:UnloadProfile(key)	
	local Profile = self.DataProfiles[key]
	if Profile then
		self.DataStore.Mock:WipeProfileAsync(key,"ForceLoad")   --- Remove this
		Profile:Release()
	end
end
function DataManager:GetProfile(key)
	return self.DataProfiles[key]
end

return DataManager
