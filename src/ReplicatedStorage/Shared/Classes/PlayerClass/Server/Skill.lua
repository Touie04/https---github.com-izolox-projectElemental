local module = {}

local MagicDictionary = require(shared.Utility.MagicDictionary);

local newRandom = Random.new();

function module:randomMagic()
	local sumWeight = 0;
	for _, rarity in ipairs(MagicDictionary.Rarities) do
		sumWeight += rarity[2];
	end

	local randomProb = newRandom:NextIntewger(0, sumWeight);
	local runningTotal = 0;

	local selectedMagic;
	local selectedRarity;

	for _, rarity in ipairs(MagicDictionary.Rarities) do
		runningTotal += rarity[2];
		if (randomProb <= runningTotal) then
			selectedRarity = rarity[1];
			break;
		end
	end

	selectedMagic = MagicDictionary.Magics[selectedRarity];

	return selectedMagic[newRandom:NextInteger(1, #selectedMagic)], selectedRarity;
end

return module