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

function module:Skill()
    print("skill called")
	self.SkillCasted = true

    --// Getting-Validating mouseinfo \\--

    local b = {
		Type = "MousePosition",
		MaxMagnitude = 200,
		Value = shared.Remotes.RequestInfo:InvokeClient(self.PlayerObject.Player,"RequestMousePosition"),
	}
    local MouseInfo = self.PlayerObject:ValidateClientInfo(b)  and b.Value
    if not  MouseInfo then
		return error("sum wrong with mouseinfo")
    end 
    local WindTornado = self.Assets.WindTornado:Clone()
    self[WindTornado] = WindTornado
    WindTornado.Position = MouseInfo
	WindTornado.Parent = workspace.Projectiles
	
	local mana = self.PlayerObject.Character:GetAttribute("Mana")
	self.PlayerObject.Character:SetAttribute("Mana",mana-self.Info.ManaDrain.Value)
        --// Effects Start \\--
    for i,v in pairs(WindTornado:GetChildren()) do
		if v:IsA("ParticleEmitter") or v:IsA("Light") then
			v.Enabled = true
		end
	end
    local rotation = TweenInfo.new(
		0.5,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.InOut,
		-1,
		false,
		0
	)
	local tween = ts:Create(WindTornado,rotation,{Rotation = WindTornado.Rotation + Vector3.new(0,360,0)})
	tween:Play()
    --// Hit Registration \\--
    local tab = {
		Origin = WindTornado,
		Range = 25,
	}
    local tc = 0
	local hittargs = {}
	while true do
		tc += 1
		if tc >= 5 or not WindTornado or not WindTornado.Parent then break end
		local targs = shared.HitBoxManager.GetMagHitbox(self.PlayerObject.Character,tab)

		if targs then
			for i,v in pairs(targs) do
				local TagTab = {
					Damage = 60,
					Stun = 1,
					BodyVelocity = {
						Velocity = ((v.HumanoidRootPart.CFrame.UpVector * 110 ) + ((v.HumanoidRootPart.Position - WindTornado.Position ) * 4)),
						Lifetime = 0.25
					},
				}
				shared.TagHumanoid.TagHumanoid(self.PlayerObject.Character,v,TagTab,self.PlayerObject)
			end
		end
		task.wait(1)
	end
      --// Effects End \\--
	local waittime = 0
	for i,v in pairs(WindTornado:GetChildren()) do
		if v:IsA("ParticleEmitter") or v:IsA("Light") then
			if v:IsA("ParticleEmitter")  then
				if waittime < v.Lifetime.Max then waittime = v.Lifetime.Max end
			end
			v.Enabled = false
		end
	end
	task.wait(waittime)
    self:Destroy()
    task.spawn(function()  -- CoolDown
        task.wait(self.Info.CD.Value)
        self.CD = false
    end)
end
-- function module:ChargedSkill()
-- 	self.SkillCasted = true
--     print(" charged skill called")

--     local mousepos = shared.Remotes.RequestInfo:InvokeClient(self.PlayerObject.Player,"RequestMousePosition")
--     local MouseInfo = self.PlayerObject:ValidateClientInfo(mousepos)  and mousepos
--     if not  MouseInfo then
--         print("sum wrong with mouseinfo")
--         return 
--     end     


-- 	local Mana = self.PlayerObject.Character:GetAttribute("Mana")	
-- 	self.PlayerObject.Character:SetAttribute("Mana", Mana - self.Info.ManaDrain.Value)




--     task.spawn(function() -- CoolDown
--         task.wait(self.Info.CD.Value)
--         self.CD = false 
--     end)
-- end
return module
