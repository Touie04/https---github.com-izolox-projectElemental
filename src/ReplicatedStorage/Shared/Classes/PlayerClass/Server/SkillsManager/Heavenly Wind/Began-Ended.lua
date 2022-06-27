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
	if  not self.PlayerObject  or self.CD or not self.PlayerObject:CheckForAction("CanAttack") then return end
	print("Input began")
	local HasEnoughMana =  self.PlayerObject.Character:GetAttribute("Mana") >= self.Info.ManaDrain.Value
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
        print("animation found")
        self.Animation = self.PlayerObject.Animator:LoadAnimation(self.Animations:FindFirstChild("CastAnimation"))
        self.Animation:Play()
        local Sound = self.Sounds.MagicCast:Clone()
        Sound.Parent = self.PlayerObject.HumanoidRootPart
        Sound:Play()

        game.Debris:AddItem(Sound,Sound.TimeLength)

        --// Do animation/Effects //--
       self.ReachedConnection =  self.Animation.KeyframeReached:Connect(function(frame)
            if frame == "Hit" then --// Hit is the cast frame / when you want the spell to be casted in the animation
                self.Animation:AdjustSpeed(0)
                self.CastFrameHit = true
                self.ReachedConnection:Disconnect()
            end
        end)
        self.Animation.Stopped:Connect(function() --// if there is no keyframe names hit when just cast when it stops
            print("Stopped")
              self.CastFrameHit = true
        end)   
    end

    self.Connection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        if self.SkillCasted or self.Input then
            self.Connection:Disconnect()
        end
        self.HoldTime += deltaTime

        if self.HoldTime >= self.Info.ChargeTime.Value and not self.Charged then

            self.Charged = true

            local Sound2 = self.Sounds.Charged:Clone()
            Sound2.Parent = self.PlayerObject.HumanoidRootPart
            Sound2:Play()


            game.Debris:AddItem(Sound2,Sound2.TimeLength)

        end
    end)


end
function module:InputEnded()
if self.SkillCasted or self.Input then print("Skill Already casted homes") return end
self.Input = true
self.CD = true

print("Input ended")
 if self.HoldTime < self.Info.CastSpeed.Value then
    task.wait(self.Info.CastSpeed.Value - self.HoldTime)
 end


 if self.Animation and self.Animation.IsPlaying then
    print("animation is playing")
    if not self.CastFrameHit then
        repeat
           task.wait()
        until self.CastFrameHit or self.Reset == true
     
		end
		
    self.Animation:AdjustSpeed(1)

	end
	
	
	task.spawn(function()
		if self.Animation then
			self.Animation.Stopped:wait()
		end	
	end)

	self.Action = self.Action and self.Action:Destroy() and nil 
	self.Anchored = self.Anchored and self.Anchored:Destroy() and nil
	
	task.wait(0.05)
	local sucess,err = pcall(function()
		if not self.Charged or not self["ChargedSkill"] then -- Casts skill based on how long you held for
			self:Skill()
		else
			self:ChargedSkill()
		end
	end)
	print(sucess,err)

	if err then
		self:Destroy()
	end

end
return module
