shared.Server = script  -- Server
shared.Classes = shared.Server.Classes
shared.Modules = shared.Server.Modules
shared.Utility = shared.Server.Utility

shared.Shared = game:GetService("ReplicatedStorage").Shared -- Shared
shared.SharedClasses = shared.Shared.Classes
shared.SharedModules = shared.Shared.Modules
shared.SharedAssets = shared.Shared.Assets
shared.Remotes = shared.Shared.Remotes
shared.SharedUtility = shared.Shared.Utility
shared.CommunicationRemote = shared.Remotes.ClientToServerPlayer


-- Shared Mdoules --
shared.TagHumanoid = require(shared.Modules.TagHumanoid)
shared.HitBoxManager = require(shared.Modules.HitBoxManager)
--- Init ---
shared.ClassGenerator = require(shared.SharedModules.Object)


shared.ServerClass = require(shared.Classes.Server)()


