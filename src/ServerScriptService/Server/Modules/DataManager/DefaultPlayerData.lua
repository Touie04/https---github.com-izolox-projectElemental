local module = {
	Element1 = "FireMagic",
	Element2 = "WaterMagic",
	Skills = {"Fireball Manipulation","Fireball Creation","Enkai","Wind Tornado","Heavenly Wind","Air Bomb","WindBreath","Air Suction"},
	Talents = "",
	Kills = 0,
	StatPoints = 0,
	SkillPoints = 0,
	Spins = 10,
	Money = 0,
	Level = 0,
	Exp = 0,
	ElementStorage = {
		DefaultElement = {
			Variation = "Default",
			SkillsUnlocked = "DefaultSmash",
			ElementTalents = "",
			Level = 0,
			exp = 0,
		},
	},
	GamePasses = {"DefaultGamepass"},
	EquippedSkills = {
		Skill1 = "TestEarthMagic",
		Skill2 = nil,
		Skill3 = nil,
		Skill4 = nil,
		Skill5 = nil,
		Skill6 = nil,
		Skill7 = nil,
		Skill8 = nil,
		Skill9 = nil,
	},
	-- Player Stats
	Damage = 0,	 
	ManaControl = 100,-- ManaCost reduction/mana regen speed
	Focus = 0,-- Casting speed, Stamina regen
	ManaPool = 100,-- Mana Amount
	Endurance = 0,-- Stamina amount
	Durability = 0,--  Health
	Agility = 0, -- Walkspeed/all that
	Settings = {
		KeyBinds = {
			One = "Skill1",
			Two = "Skill2",
			Three = "Skill3",
			Four = "Skill4",
			Five = "Skill5",
			Six = "Skill6",
			Seven = "Skill7",
			Eight = "Skill8",
			Nine = "Skill9",
			Q = "Dash",
			F = "Block",
			LeftControl = "Sprint",
		},
		DoubleTapToSprint = false,
		SprintToggle = true,
	},
	ToolBar = {
		Skill1 = "Fireball Manipulation",
		Skill2 = "Fireball Creation",
		Skill3 = "Enkai",
		Skill4 = "Wind Tornado",
		Skill5 = "Heavenly Wind",
		Skill6 = "Air Bomb",
		Skill7 = "WindBreath",
		Skill8 = "Air Suction",
		Skill9 = "",
	},

	-- Debug
	DataVersion = 0,
	FirstTime = true
}

return module