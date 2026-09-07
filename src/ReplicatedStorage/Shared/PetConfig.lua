--!strict

local rarityIncome = table.freeze({
	Common = 10,
	Rare = 25,
	Epic = 50,
	Legendary = 100,
})

local definitions: {[string]: any} = {}

definitions.FluffDog = table.freeze({
	Id = "FluffDog",
	DisplayName = "Fluff Dog",
	Rarity = "Common",
	Cost = 0,
	PassiveIncome = rarityIncome.Common,
	ModelName = "FluffDog",
	SortOrder = 1,
	Purchasable = false,
})

definitions.ChibiCat = table.freeze({
	Id = "ChibiCat",
	DisplayName = "Chibi Cat",
	Rarity = "Common",
	Cost = 500,
	PassiveIncome = rarityIncome.Common,
	ModelName = "ChibiCat",
	SortOrder = 2,
	Purchasable = true,
})

definitions.FrostBunny = table.freeze({
	Id = "FrostBunny",
	DisplayName = "Frost Bunny",
	Rarity = "Rare",
	Cost = 2_500,
	PassiveIncome = rarityIncome.Rare,
	ModelName = "FrostBunny",
	SortOrder = 3,
	Purchasable = true,
})

definitions.StormOwl = table.freeze({
	Id = "StormOwl",
	DisplayName = "Storm Owl",
	Rarity = "Epic",
	Cost = 12_500,
	PassiveIncome = rarityIncome.Epic,
	ModelName = "StormOwl",
	SortOrder = 4,
	Purchasable = true,
})

definitions.FrostFox = table.freeze({
	Id = "FrostFox",
	DisplayName = "Frost Fox",
	Rarity = "Epic",
	Cost = 20_000,
	PassiveIncome = rarityIncome.Epic,
	ModelName = "FrostFox",
	SortOrder = 5,
	Purchasable = true,
})

definitions.AuraDragon = table.freeze({
	Id = "AuraDragon",
	DisplayName = "Aura Dragon",
	Rarity = "Legendary",
	Cost = 100_000,
	PassiveIncome = rarityIncome.Legendary,
	ModelName = "AuraDragon",
	SortOrder = 6,
	Purchasable = true,
})

table.freeze(definitions)

local orderedIds = table.freeze({
	"FluffDog",
	"ChibiCat",
	"FrostBunny",
	"StormOwl",
	"FrostFox",
	"AuraDragon",
})

local orderedDefinitions = {}
for _, petId in orderedIds do
	table.insert(orderedDefinitions, definitions[petId])
end
table.freeze(orderedDefinitions)

local PetConfig = {
	Definitions = definitions,
	RarityIncome = rarityIncome,
}

function PetConfig.Get(petId: any): any?
	if type(petId) ~= "string" then
		return nil
	end
	return definitions[petId]
end

function PetConfig.GetAll(): {any}
	return orderedDefinitions
end

function PetConfig.GetPassiveIncome(petId: any): number
	local definition = PetConfig.Get(petId)
	return if definition then definition.PassiveIncome else 0
end

return table.freeze(PetConfig)
