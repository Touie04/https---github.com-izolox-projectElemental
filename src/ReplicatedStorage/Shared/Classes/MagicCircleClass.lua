local module = shared.ClassGenerator:extend()

function module:new(Attachment,Parent)

	self.AttachmentIsParent = false
	if not Parent or not (Parent:IsA("BasePart") or Parent:IsA("Attachment")) then warn("No Parent found homie") return end
	self.Settings = {}
	if Parent:IsA("Attachment") then
		for i,v in pairs(Attachment:GetChildren()) do
			self.Settings[v] = v
			v.Parent = Parent
		end
		Attachment:Destroy()
		self.Attachment = Parent
		self.AttachmentIsParent = true
		
	else
		self.Attachment = Attachment or shared.SharedAssets.MagicCircle:Clone()
		self.Attachment.Parent = Parent
	end

end


function module:Emit(Rate,Step)
	Rate = Rate or 1
	Step = Step or 1

	for i,v in pairs(self.Attachment:GetChildren()) do
		if v:IsA("ParticleEmitter") and v.Name ~= "ChargeLayer" then
			v:Emit(Rate)
			v.Enabled = true
		end
	end
	--task.spawn(function()
	--	while true do

	--		if self.Attachment and self.Attachment.Parent then
	--			for i,v in pairs(self.Attachment:GetChildren()) do
	--				if v:IsA("ParticleEmitter") and v.Enabled == true then
	--					v:Emit(Rate)
	--				end
	--			end
	--			wait(Step)
	--		else
	--			break
	--		end
	--	end
	--end)
end
function module:Pause()
	for i,v in pairs(self.Attachment:GetChildren()) do
		if v:IsA("ParticleEmitter") or v:IsA("PointLight")   then
			v.Enabled = false
		end
	end
end

function module:Destroy()
	if self.Attachment and not self.AttachmentIsParent then
		self.Attachment:Destroy()
	elseif self.AttachmentIsParent and self.Settings then
		print("Attachment is a parent")
		for i,v in pairs(self.Settings) do
			v:Destroy()
		end
	end
print(self.Settings)
end

return module
