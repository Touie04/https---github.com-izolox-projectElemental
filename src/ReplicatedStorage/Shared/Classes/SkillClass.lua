
-- Architecture


-- Create the object then run either the input began or input ended method.
-- Each skill module will have a skillobject and implementit
local SkillClass = shared.ClassGenerator:extend()

function SkillClass:new(PlayerObject,SkillName)
	self.PlayerObject = PlayerObject

end
function SkillClass:PlayCastingSound(Type)

	if Type == "MagicCast" then
		local sound = script.MagicCast:Clone()
		sound.Parent = self.PlayerObject.Character.HumanoidRootPart

		game.Debris:AddItem(sound,sound.TimeLength)

		sound:Play()	
	elseif Type == "Charged" then

		local sound = script.Charged:Clone()
		sound.Parent = self.PlayerObject.Character.HumanoidRootPart

		game.Debris:AddItem(sound,sound.TimeLength)

		sound:Play()
	end

end

function SkillClass:EndCast()
	if self.Animation  then
		self.Animation:AdjustSpeed(1)
	end	
	if self.CastingCircleObj  then
		self.CastingCircleObj:Pause()
		if 	self.CastingCircleObj.Attachment:FindFirstChild("ChargeLayer") then
			self.CastingCircleObj.Attachment:FindFirstChild("ChargeLayer").Parent = self.CastingCircleObj.Attachment.PointLight
		end 
	end
	if self.PlayerObject  then
		self.PlayerObject.Character:SetAttribute("AutoRotate",false)
		self.PlayerObject.Character.HumanoidRootPart.Anchored = false
	end
	if self.Action then self.Action:Destroy() end

	if self.Anchored then
		self.Anchored:Destroy()
	end
end
function SkillClass:Destroy()
	
	self:EndCast()
	if self.Animation  then
		self.Animation:AdjustSpeed(1)

	end
	self.HoldTime = 0
	self.AnimationHitEnd =false
	if self.CastingCircleObj  then
		self.CastingCircleObj:Pause()
		if 	self.CastingCircleObj.Attachment:FindFirstChild("ChargeLayer") then
			self.CastingCircleObj.Attachment:FindFirstChild("ChargeLayer").Parent = self.CastingCircleObj.Attachment.PointLight
		end 
	end
	if self.SkillAssets  then
		for i,v in pairs(self.SkillAssets) do
			if v["Destroy"] then
				v:Destroy()
			end
		end
		self.SkillAssets = {}
	end


	if self.PlayerObject  then
		self.PlayerObject.Character:SetAttribute("AutoRotate",false)
		self.PlayerObject.Character.HumanoidRootPart.Anchored = false
	end
	if self.Animation  then
		self.Animation:Stop()
	end
	self.PlayerObject:RemoveAction("UsingSkill")

end
function SkillClass:CleanUp(Type)
	
	self.CleaningUp = true
	self:EndCast()
	if self.Animation  then
		self.Animation:AdjustSpeed(1)
	end
	self.HoldTime = 0
	self.AnimationHitEnd =false
	if self.CastingCircleObj  then
		self.CastingCircleObj:Destroy()
		self.CastingCircleObj = nil
	end
	if self.SkillAssets  then
		for i,v in pairs(self.SkillAssets) do
			if v["Destroy"] then
				v:Destroy()
			end
		end
		self.SkillAssets = {}
	end

	if self.PlayerObject  then
		self.PlayerObject.Character:SetAttribute("AutoRotate",false)
		self.PlayerObject.Character.HumanoidRootPart.Anchored = false
	end

	if self.Animation  then
		self.Animation:Stop()
	end
	if self.Action then self.Action:Destroy() end
	
	if Type == "Cancel" then
		self.CD = false
	end

	self.CleaningUp = false


end
function SkillClass:CancelCast()

end
function SkillClass:Unequip()

end
function SkillClass:InputBegan()
	print("Skill module does not have an input began function",self.SkillName)
end

function SkillClass:InputEnded()
	print("Skill module does not have an input ended function",self.SkillName)
end

function SkillClass:OnSkillEquipped()
	print("Skill has been equipped")
end
return SkillClass
