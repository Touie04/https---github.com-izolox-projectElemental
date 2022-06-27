local TagHumanoid = {}

local thingstocheckfor = {
	"HumanoidRootPart",
	"Humanoid",
	"ActionFolder"
}

function TagHumanoid.CalculateDamage()

end
function TagHumanoid.TagHumanoid(char,echar,properties,charobject,echarobject)
	properties = properties or {}
	-- Sanity checks
	if not char or not echar  or not properties then warn("what",char,echar) return end
	for i,v in pairs(thingstocheckfor) do
		if not echar:FindFirstChild(v) or not char:FindFirstChild(v) then
			print("cant find this",v)
			return
		end
	end
	
	charobject = shared.ServerClass.PlayerObjects[game.Players:GetPlayerFromCharacter(char)]
	echarobject = shared.ServerClass.PlayerObjects[game.Players:GetPlayerFromCharacter(echar)]
	
	if (charobject and charobject.IsDead)  or (echarobject and echarobject.IsDead)  then return end
	
	
	----- Functions -----


	----- [Variables] ---
	local Damage = properties["Damage"] or 10
	local StunTime = properties["Stun"] or 0.2
	local IframeTable = {
		"Iframe",
	}
	-- CharVariables
	local humanoid = char:FindFirstChild("Humanoid")
	 --if humanoid.Died then print("hum is dead") return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local action_folder = char:FindFirstChild("ActionFolder")
	-- EnemyVariables
	local  enemy_humanoid = echar:FindFirstChild("Humanoid")

	--if enemy_humanoid.Died then print("already dead") return end
	local  enemy_root = echar:FindFirstChild("HumanoidRootPart")
	local  enemy_action_folder = echar:FindFirstChild("ActionFolder")
	-- Getting Stats
	local attributes = char:GetAttributes()
	local damage_boost = attributes["Damage"]
	local mana_pool = attributes["ManaPool"]
	local endurance = attributes["Endurance"]
	local mana_control = attributes["ManaControl"]
	local durability = attributes["Durability"]
	local focus = attributes["Focus"]
	local mana = attributes["Mana"]
	local stamina = attributes["Stamina"]
	-- Enemy Stats
	local enemy_attributes = echar:GetAttributes()
	local enemy_damage_boost = enemy_attributes["Damage"]
	local enemy_mana_pool = enemy_attributes["ManaPool"]
	local enemy_endurance = enemy_attributes["Endurance"]
	local enemy_mana_control = enemy_attributes["ManaControl"]
	local enemy_durability = enemy_attributes["Durability"]
	local enemy_focus = enemy_attributes["Focus"]
	local enemy_mana = enemy_attributes["Mana"]
	local enemy_stamina = enemy_attributes["Stamina"]
	-- Iframes --
	for i,v in pairs(IframeTable) do
		if enemy_action_folder:FindFirstChild(v) then
			return 
		end
	end
	--[Damage calculations]--
	Damage = Damage + (damage_boost/10)
	Damage = Damage - (enemy_durability/100)

	-- Manashield calculations -- 
	if enemy_action_folder:FindFirstChild("ManaShield") then
		if mana <= Damage/2 and echarobject then
			echarobject:Block("BreakShield")
			echar:SetAttribute("Mana",0)
			local leftovermana = mana - Damage/2
			Damage = Damage - (math.abs(leftovermana) * 2)
		else
			echar:SetAttribute("Mana",math.clamp(enemy_mana-Damage/2,0,echar:GetAttribute("MaxMana")))
			return
		end
	end
	-- Stun --
	local stun = Instance.new("Folder")
	stun.Name = "Stun"
	stun.Parent = enemy_action_folder
	game.Debris:AddItem(stun,StunTime)
	
	-- Damage--
	if enemy_humanoid.Health <= Damage then
		if charobject and charobject["OnEnemyDeath"]  then
			charobject:OnEnemyDeath(echar)
		end
	end
	enemy_humanoid:TakeDamage(Damage)
	
	-- BodyMovers--
	if properties["BodyVelocity"] and properties["BodyVelocity"]["Velocity"]  then
		if enemy_root:FindFirstChildOfClass("BodyVelocity") then
			enemy_root:FindFirstChildOfClass("BodyVelocity"):Destroy()
		end
		if enemy_root:FindFirstChildOfClass("BodyPosition") then
			enemy_root:FindFirstChildOfClass("BodyPosition"):Destroy()
		end
		enemy_root.Velocity = Vector3.new(0,0,0)
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1,1,1) * 10^20
		bv.Velocity = properties["BodyVelocity"]["Velocity"] 
		bv.P = properties["BodyVelocity"]["P"] or bv.P
		bv.Name = properties["BodyVelocity"]["Name"] or "BodyVelocity"
		bv.Parent = enemy_root
		game.Debris:AddItem(bv,(properties["BodyVelocity"]["LifeTime"]) or 0.25)
	end
	if properties["BodyPosition"] and properties["BodyPosition"]["Position"] then
		if enemy_root:FindFirstChildOfClass("BodyVelocity") then
			enemy_root:FindFirstChildOfClass("BodyVelocity"):Destroy()
		end
		if enemy_root:FindFirstChildOfClass("BodyPosition") then
			enemy_root:FindFirstChildOfClass("BodyPosition"):Destroy()
		end

		enemy_root.Velocity = Vector3.new(0,0,0)
		
		local bp = Instance.new("BodyPosition")
		bp.P =  properties["BodyPosition"]["P"] or bp.P
		bp.D = properties["BodyPosition"]["D"] or bp.D
		bp.Position =  properties["BodyPosition"]["Position"]
		bp.Name =  properties["BodyPosition"]["Name"] or "BodyPosition"
		game.Debris:AddItem(bp, properties["BodyPosition"]["LifeTime"] or 0.25)
		
	end
end

return TagHumanoid
