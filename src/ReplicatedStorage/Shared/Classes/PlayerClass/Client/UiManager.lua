local ts = game:GetService("TweenService")
local OldMoney
local uitweentime =TweenInfo.new(0.6)
local EquippedImage  ="rbxassetid://9946680077"
local UnEquippedImage = "rbxassetid://9946695336"
local elementinfo = require(shared.SharedUtility.ElementInfo)
local module = {}

function module:Init_Hud()
	repeat task.wait()
	until self.Hud and self.ToolBar
	


	self.UIObjects = {
		ToolBar = {},
	}
 
	for i,v in pairs(self.ToolBar:GetChildren()) do
		local toolbarClass = shared.SharedClasses.	ToolbarClass_Client
		self.UIObjects["ToolBar"][v.Name] = require(toolbarClass)(v,self)
	end
end


module.AttributeChangedFunctions = {
	Money = function(self)
		local val = self.Character:GetAttribute("Money")
		if OldMoney then
			local Difference = val -  OldMoney 
			-- Do something with the difference later
		end
		self.Money.Text = val
		OldMoney = val
	end,
	Level = function(self)
		local val = self.Character:GetAttribute("Level")
		self.Level.Text =  val
	end,
	Exp = function(self)
		local val = self.Character:GetAttribute("Exp")
		local val2 = self.Character:GetAttribute("ExpToLevel")
		local bar = self.ExpBar:WaitForChild("Bar")
		local tween = ts:Create(bar,uitweentime,{Size =  UDim2.fromScale(math.clamp(val/val2,0,1), bar.Size.Y.Scale)}):Play()
	end,
	ExpToLevel = function(self)
		local val = self.Character:GetAttribute("Exp")
		local val2 = self.Character:GetAttribute("ExpToLevel")

		local bar = self.ExpBar:WaitForChild("Bar")
		local tween = ts:Create(bar,uitweentime,{Size =  UDim2.fromScale(math.clamp(val/val2,0,1), bar.Size.Y.Scale)}):Play()
	end,
	Mana = function(self)
		local val = self.Character:GetAttribute("Mana")
		local val2 = self.Character:GetAttribute("MaxMana")
		local bar = self.ManaBar:WaitForChild("Bar")
		local tween = ts:Create(bar,uitweentime,{Size =  UDim2.fromScale(math.clamp(val/val2,0,1), bar.Size.Y.Scale)}):Play()
	end,
	MaxMana = function(self)
		local val = self.Character:GetAttribute("Mana")
		local val2 = self.Character:GetAttribute("MaxMana")
		local bar = self.ManaBar:WaitForChild("Bar")
		local tween = ts:Create(bar,uitweentime,{Size =  UDim2.fromScale(math.clamp(val/val2,0,1), bar.Size.Y.Scale)}):Play()
	end,
	Stamina = function(self)
		local val = self.Character:GetAttribute("Stamina")
		local val2 = self.Character:GetAttribute("MaxStamina")
		local bar = self.StaminaBar:WaitForChild("Bar")
		local tween = ts:Create(bar,uitweentime,{Size =  UDim2.fromScale(math.clamp(val/val2,0,1), bar.Size.Y.Scale)}):Play()

	end,
	MaxStamina = function(self)
		local val = self.Character:GetAttribute("Stamina")
		local val2 = self.Character:GetAttribute("MaxStamina")
		local bar = self.StaminaBar:WaitForChild("Bar")
		local tween = ts:Create(bar,uitweentime,{Size =  UDim2.fromScale(math.clamp(val/val2,0,1), bar.Size.Y.Scale)}):Play()
	end,
	Health = function(self)
		local val = self.Humanoid.Health
		local val2 = self.Humanoid.MaxHealth

		local bar = self.HealthBar:WaitForChild("Bar")
		local tween = ts:Create(bar,uitweentime,{Size =  UDim2.fromScale(math.clamp(val/val2,0,1), bar.Size.Y.Scale)}):Play()
	end,
	Element1 = function(self)
		self.OnElementChanged(self,{ElementType = "Primary",Element = self.Character:GetAttribute("Element1")})
	end,
	Element2 = function(self)
		self.OnElementChanged(self,{ElementType = "Secondary",Element = self.Character:GetAttribute("Element2")})
	end,
}
module.OnToolEquiped = function(self,Number)
	print(Number)
	if self.ToolBar[Number] then
		local Bar = self.ToolBar[Number]
		Bar.Image = EquippedImage
	end
end
module.OnToolUnequiped = function(self,Number)
	print(Number)
	if self.ToolBar[Number] then
		local Bar = self.ToolBar[Number]
		Bar.Image = UnEquippedImage
	end
end

module.OnToolChanged = function(self,Info)
	local Number = Info["Number"]
	if not Number or not self.ToolBar[Number] then return end
	local Value = Info["Value"]
	local Bar = self.ToolBar[Number]
	
	Value = Value or ""
	
	Bar:WaitForChild("SkillName").Text = Value
end
module.OnElementChanged = function(self,Info)
	local ElementType = Info["ElementType"]
	if not ElementType or not ElementType == "Primary" or not ElementType == "Secondary" then return end
	
	local Element = (Info["Element"] and elementinfo[Info["Element"]]) or nil
	ElementType = (ElementType == "Primary" and self.Elements:WaitForChild("PrimaryElement"))  or  ElementType == "Secondary" and self.Elements:WaitForChild("SecondaryElement")
	
	ElementType.Image = (Element and Element.Icon) or ""
end

return module
