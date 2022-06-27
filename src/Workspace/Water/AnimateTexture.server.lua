--Written by Xan_TheDragon
--Based on CloneTrooper1019's "Animated Lava", which uses the water normal texture. It has an orange tint to it.
--The decals I used are the same textures, but desaturated. This allows you to easily set color.

local TextureIDs = {"http://www.roblox.com/asset/?id=1813833700", "http://www.roblox.com/asset/?id=1813834024", "http://www.roblox.com/asset/?id=1813834215", "http://www.roblox.com/asset/?id=1813834382", "http://www.roblox.com/asset/?id=1813834575", "http://www.roblox.com/asset/?id=1813834756", "http://www.roblox.com/asset/?id=1813834924", "http://www.roblox.com/asset/?id=1813835086", "http://www.roblox.com/asset/?id=1813835278", "http://www.roblox.com/asset/?id=1813835465", "http://www.roblox.com/asset/?id=1813835649", "http://www.roblox.com/asset/?id=1813835859", "http://www.roblox.com/asset/?id=1813836065", "http://www.roblox.com/asset/?id=1813836286", "http://www.roblox.com/asset/?id=1813836522", "http://www.roblox.com/asset/?id=1813836685", "http://www.roblox.com/asset/?id=1813836897", "http://www.roblox.com/asset/?id=1813837074", "http://www.roblox.com/asset/?id=1813837245", "http://www.roblox.com/asset/?id=1813837424", "http://www.roblox.com/asset/?id=1813837586", "http://www.roblox.com/asset/?id=1813837752", "http://www.roblox.com/asset/?id=1813839524", "http://www.roblox.com/asset/?id=1813839704", "http://www.roblox.com/asset/?id=1813839853"}
local CurrentTextureIndex = 1

function StepTextures()
	if CurrentTextureIndex > #TextureIDs then
		CurrentTextureIndex = 1
	end
	for Index, Item in ipairs(script.Parent:GetChildren()) do
		if Item:IsA("Texture") then
			Item.Texture = TextureIDs[CurrentTextureIndex]
		end
	end
	CurrentTextureIndex = CurrentTextureIndex + 1
end

while true do
	StepTextures()
	wait(0.035)
end