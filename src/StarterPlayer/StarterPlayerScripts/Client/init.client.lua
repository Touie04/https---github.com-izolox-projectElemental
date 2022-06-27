shared.Client = script  -- Server
shared.Classes = shared.Client:WaitForChild("Classes")
shared.Modules = shared.Client:WaitForChild("Modules")
shared.Utility = shared.Client:WaitForChild("Utility")

shared.Shared = game:GetService("ReplicatedStorage").Shared -- Shared
shared.SharedClasses = shared.Shared.Classes
shared.SharedModules = shared.Shared.Modules
shared.SharedAssets = shared.Shared.Assets
shared.Remotes = shared.Shared.Remotes
shared.SharedUtility = shared.Shared.Utility
shared.CommunicationRemote = shared.Remotes.ClientToServerPlayer



-- Variables

--- Init ---
shared.ClassGenerator = require(shared.SharedModules.Object)
shared.PlayerClass = require(shared.SharedClasses.PlayerClass)(game.Players.LocalPlayer)
