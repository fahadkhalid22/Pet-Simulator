--!strict

local GameConfig = {
	DataStore = table.freeze({
		Name = "AuralitPlayerData",
		Scope = "Production",
		SchemaVersion = 1,
		AutosaveIntervalSeconds = 60,
		SessionLockSeconds = 180,
		LoadLockAttempts = 5,
		LoadLockRetrySeconds = 2,
		MaxOperationAttempts = 5,
		InitialRetryDelaySeconds = 1,
		MaxRetryDelaySeconds = 8,
	}),

	Economy = table.freeze({
		StartingCoins = 100,
		MaxCoins = 9_000_000_000_000_000,
	}),

	Pets = table.freeze({
		StarterPetId = "FluffDog",
		MaxEquipped = 3,
		MaxOwned = 500,
	}),

	Cosmetics = table.freeze({
		MaxOwned = 500,
	}),
}

return table.freeze(GameConfig)
