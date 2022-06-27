local module = shared.ClassGenerator:extend()


function module:new(playerobject)
	print(playerobject.Player,self.Player)
	local data = playerobject.Data
	self.ToolBarInfo = {
		["1"] = "nil",
		["2"] = "nil",
		["3"] = "nil",
		["4"] = "nil",
		["5"] = "nil",
		["6"] = "nil",
		["7"] = "nil",
		["8"] = "nil",
		["9"] = "nil",
	}
	self.EquippedTool = nil
	if not data.ToolBar  then
		data["ToolBar"] = self.ToolBarInfo
	else
		self.ToolBarInfo = data["ToolBar"]
	end



end
function module:AddToToolbar(key,Info)

end
function module:RemoveFromToolbar(key,Info)

end
function module:ToolEquipped(key,Info)
	if self.ToolBarInfo[key] then
		self.EquippedTool = self.ToolBarInfo[key]
	end
end
function module:ToolUnequipped(key,Info)

end
function module:MouseButton1Down(key,Info)


end
function module:MouseButton1Up(key,Info)


end
function module:MouseButton2Down(key,Info)


end
function module:MouseButton2Up(key,Info)


end
return module
