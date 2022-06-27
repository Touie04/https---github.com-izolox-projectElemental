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
function module:InputBegan()
	if  not self.PlayerObject  or self.CD or not self.PlayerObject:CheckForAction("CanAttack") or self.SkillCasted then return end
	local HasEnoughMana =  self.PlayerObject.Character:GetAttribute("Mana") >= self.Info.ManaDrain.Value + self.Info.HoldDrain.Value
	if not HasEnoughMana then return end
    --// Resets all variables \\--
    self.CD = true
    self.Reset = false
    self.SkillCasted = false
    self.Input = false
    self.CastFrameHit = false
    self.Charged = false
    self.HoldTime = 0
    self.ReachedConnection = self.ReachedConnection and self.ReachedConnection:Disconnect() and nil
    self.Connection = self.Connection and self.Connection:Disconnect() and nil
    
    
    --// Stun - othher vals ]]--
    self.Action = Instance.new("IntValue")
	self.Action.Name = "UsingSkill"
	self.Action.Parent = self.PlayerObject.ActionFolder
	
	self.Anchored = Instance.new("StringValue")
	self.Anchored.Name = "Anchor"
	self.Anchored.Parent = self.PlayerObject.ActionFolder


    if self.Animations:FindFirstChild("CastAnimation") then
		self.Animation =  self.PlayerObject.Animator:LoadAnimation(self.Animations:FindFirstChild("CastAnimation"))
		self.Animation:Play()
        local Sound = self.Sounds.MagicCast:Clone()
        Sound.Parent = self.PlayerObject.HumanoidRootPart
        Sound:Play()

        game.Debris:AddItem(Sound,Sound.TimeLength)

        --// Do animation/Effects //--
       self.ReachedConnection =  self.Animation.KeyframeReached:Connect(function(frame)
			if frame == "Hit" then --// Hit is the cast frame / when you want the spell to be casted in the animation
				if not self.Input and not self.SkillCasted then
                self.Animation:AdjustSpeed(0)
					self.CastFrameHit = true
			
					
					local sucess,err = pcall(function()
						self:SkillStart()
					end)
					print(sucess,err)
					if err then
						self:Destroy()
					else
						self.ManaDrain = Instance.new("IntValue")
						self.ManaDrain.Name = "ManaDrain"
						self.ManaDrain.Value = self.Info.HoldDrain.Value * -1
						self.ManaDrain.Parent = self.PlayerObject.ActionFolder
						self.ManaDrain.AncestryChanged:Connect(function()
							if not self.ManaDrain.Parent and self.SkillCasted then
								
								print("Manadrain is the issue homie")
								self:SkillEnd()
							end
						end)
					end
				end
				
				--self.ReachedConnection = self.ReachedConnection and self.ReachedConnection:Disconnect()
            end
        end)
        self.Animation.Stopped:Connect(function() --// if there is no keyframe names hit when just cast when it stops
			
			if not self.CastFrameHit and not self.Input and not self.SkillCasted then
				self.CastFrameHit = true
				
				local sucess,err = pcall(function()
					self:SkillStart()
				end)
				
				if err then
					print(err)
					self:Destroy()
				else
					self.ManaDrain = Instance.new("IntValue")
					self.ManaDrain.Name = "ManaDrain"
					self.ManaDrain.Value = self.Info.HoldDrain.Value * -1
					self.ManaDrain.Parent = self.PlayerObject.ActionFolder
					self.ManaDrain.AncestryChanged:Connect(function()
						if not self.ManaDrain.Parent and self.SkillCasted then
							print("Manadrain is the issue homie from stopped func")
							self:SkillEnd()
						end
					end)
				end
			end    
		end)   
    end
end
function module:InputEnded()
	--if self.SkillCasted or self.Input then print("Skill Already casted homes") return end
	self.Input = true
		if self.Animation then
			self.Animation:AdjustSpeed(1)

		end

		local sucess,err = pcall(function()
			self:SkillEnd()
		end)

		if err then
			print(err)
			self:Destroy()
		end	

end
return module
