local ServerScriptService = game:GetService("ServerScriptService")
local module = {}
function module:SkillManager_Setup()
	
	self.ToolBar = {}
	self.Skills = {}
	self.EquippedSkill = nil
	for i,v in pairs(self.Data.Skills) do
		if not script:FindFirstChild(v) then
			print("Skill not found")		
		else
			self.Skills[v] = require(script:FindFirstChild(v))(self)
		end 
	end
	for i,v in pairs(self.Data.ToolBar) do
		if (v ~= "" and not script:FindFirstChild(v) or not self.Skills[v]) or v == "" then
			print("Skill Not Found " .. i)
			self.ToolBar[i] = {}
			self.Data.ToolBar[i] = ""
			shared.Remotes.ClientToServerPlayer:FireClient(self.Player,"OnToolChanged",{Number = i,Value = nil})
			continue	
		end
		self.ToolBar[i] = {
			Name = v,
			Object = self.Skills[v],
		}	
		shared.Remotes.ClientToServerPlayer:FireClient(self.Player,"OnToolChanged",{Number = i,Value = v})
	end
	print(self.ToolBar)
end
function module:UseSkill(Input: string,Info,SkillName: string)
	if self.IsDead or(Input == "InputBegan" and  not self:CheckForAction("CanAttack")) then return end

	if self.EquippedSkill and self.ToolBar[self.EquippedSkill] and self.ToolBar[self.EquippedSkill]["Object"]    then
		self.ToolBar[self.EquippedSkill]["Object"][Input](self.ToolBar[self.EquippedSkill]["Object"],Info)
	
	end
end
function module:EquipSkill(ToolNumber,Info)
	print("EquippedSkill called",ToolNumber,Info)
	if not self.ToolBar or not self.ToolBar[ToolNumber] or self.Busy then print("SetupNotCalled") return end
	self.Busy = true
	if ToolNumber == self.EquippedSkill then
		self:UnEquipSkill(ToolNumber)
	else
		if self.EquippedSkill  then
			self:UnEquipSkill(self.EquippedSkill)
		end
		self.EquippedSkill = ToolNumber
		if self.ToolBar[ToolNumber]["Object"] then
			self.ToolBar[ToolNumber]["Object"]:Equip()	
		end	
		shared.Remotes.ClientToServerPlayer:FireClient(self.Player,"OnToolEquiped",ToolNumber)
	end
	self.Busy = false
end
function module:UnEquipSkill(SkillName,Info)
	if not self.ToolBar or not self.EquippedSkill or not self.ToolBar[self.EquippedSkill] then self.EquippedSkill = nil  or self.Busy return end
	self.Busy = true
	print("Un Equipping",self.EquippedSkill,self.ToolBar[self.EquippedSkill])
	shared.Remotes.ClientToServerPlayer:FireClient(self.Player,"OnToolUnequiped",SkillName)
	
	if self.ToolBar[self.EquippedSkill]["Object"] then
		self.ToolBar[self.EquippedSkill]["Object"]:UnEquip()
	end

	self.EquippedSkill = nil
	self.Busy = false
end
function module:AddSkillToToolbar(SkillNumber: string,SkillName: string,Info)
if not SkillName and not self.Skills[SkillName] then return end
local skillobject = self.Skills[SkillName]
if self.EquippedSkill == SkillNumber then
	self:UnEquipSkill(self.EquippedSkill)
end
self.ToolBar[SkillNumber] = {
	Object = self.Skills[SkillName],
	Name = self.Skills[SkillName].SkillName
}
shared.Remotes.ClientToServerPlayer:FireClient(self.Player,"OnToolChanged",{Number = SkillNumber,Value = self.ToolBar[SkillNumber].Name})
end
function module:RemoveSkillFromToolBar(SkillNumber: string,Info)
	if not self.ToolBar[SkillNumber] then return end
	if self.EquipSkill == SkillNumber then
		self:UnEquipSkill(SkillNumber)
	end
	self.ToolBar[SkillNumber] =  {}
	shared.Remotes.ClientToServerPlayer:FireClient(self.Player,"OnToolChanged",{Number = SkillNumber,Value = self.ToolBar[SkillNumber].Name})
end
function module:SwapTools(Tool1: string,Tool2: string)
	if not Tool1 or not self.ToolBar[Tool1] or not Tool2 or not self.ToolBar[Tool2] then return end
	local  Var_Tool1 = self.EquippedSkills == Tool1 and self:UnEquipSkill(Tool1) and self.ToolBar[Tool1]:Destroy() and Tool1  or Tool1
	 local  Var_Tool2 =    self.EquippedSkills == Tool2 and self:UnEquipSkill(Tool2) and self.ToolBar[Tool2]:Destroy() and Tool2 or Tool2
	print("Swapping",Tool1,Tool2,Var_Tool1,Var_Tool2)

	local var_1Table = {
		Object = self.ToolBar[Var_Tool1]["Object"],
		Name = self.ToolBar[Var_Tool1]["Name"]
	}
	local var_2Table = {
		Object = self.ToolBar[Var_Tool2]["Object"],
		Name = self.ToolBar[Var_Tool2]["Name"]
	}
	self.ToolBar[Var_Tool1]["Object"] = self.ToolBar[Var_Tool2]["Object"]
	self.ToolBar[Var_Tool1]["Name"] = self.ToolBar[Var_Tool2]["Name"]

	self.ToolBar[Var_Tool2]["Object"] = var_1Table["Object"]
	self.ToolBar[Var_Tool2]["Name"] = var_1Table["Name"]
	shared.Remotes.ClientToServerPlayer:FireClient(self.Player,"OnToolChanged",{Number = Tool1,Value = self.ToolBar[Var_Tool1].Name})
	shared.Remotes.ClientToServerPlayer:FireClient(self.Player,"OnToolChanged",{Number = Tool2,Value = self.ToolBar[Var_Tool2].Name})
end
function module:OnSkillAdded(SkillName)
if not script:FindFirstChild(SkillName) then return end
	if not self.Skill[SkillName] then
		self.Skills[SkillName] = require(script:FindFirstChild(SkillName))(self)
	end
	if not table.find(self.Data.Skills,SkillName) then	
		table.insert(self.Data.Skills,SkillName)
	end
	-- Fire client that the player has lost a skill to update all uis
end
function module:OnSkillRemoved(SkillName)
	if self.Skills[SkillName] then
		self.Skills[SkillName]:Destroy()
		self.Skills[SkillName] = nil
	end
	if table.find(self.Data.Skills,SkillName) then	
		table.remove(self.Data.Skills,table.find(self.Data.Skills,SkillName))
	end
	-- Fire client that the player has lost a skill to update all uis
end
return module

