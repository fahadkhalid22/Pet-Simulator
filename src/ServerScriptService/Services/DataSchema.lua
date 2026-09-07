--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

local DataSchema = {}

local MAX_IDENTIFIER_LENGTH = 64
local MAX_CATEGORY_LENGTH = 32
local MAX_TIMESTAMP = 9_000_000_000_000_000

local function cloneValue(value: any, seen: {[any]: any}?): any
	if type(value) ~= "table" then
		return value
	end

	local visited = seen or {}
	if visited[value] then
		return visited[value]
	end

	local copy = {}
	visited[value] = copy
	for key, child in pairs(value) do
		copy[cloneValue(key, visited)] = cloneValue(child, visited)
	end

	return copy
end

local function isFiniteNumber(value: any): boolean
	return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function boundedInteger(value: any, fallback: number, minimum: number, maximum: number): number
	if not isFiniteNumber(value) then
		return fallback
	end

	return math.clamp(math.floor(value), minimum, maximum)
end

local function safeString(value: any, maximumLength: number): string?
	if type(value) ~= "string" or value == "" or #value > maximumLength then
		return nil
	end

	return value
end

local function starterPetUid(userId: number): string
	return string.format("starter:%d", userId)
end

local function newOwnedPets(userId: number, createdAt: number): {[string]: any}
	local uid = starterPetUid(userId)
	return {
		[uid] = {
			Uid = uid,
			PetId = GameConfig.Pets.StarterPetId,
			AcquiredAt = createdAt,
		},
	}
end

function DataSchema.New(userId: number): {[string]: any}
	local now = os.time()
	local uid = starterPetUid(userId)

	return {
		SchemaVersion = GameConfig.DataStore.SchemaVersion,
		Coins = GameConfig.Economy.StartingCoins,
		Pets = {
			Owned = newOwnedPets(userId, now),
			Equipped = { uid },
		},
		Cosmetics = {
			Owned = {},
			Equipped = {},
		},
		DailyRewards = {
			CycleDay = 1,
			Streak = 0,
			LastClaimAt = 0,
		},
		BattlePass = {
			SeasonId = "",
			Xp = 0,
			PremiumOwned = false,
			ClaimedFree = {},
			ClaimedPremium = {},
		},
		Progress = {
			TotalCoinsEarned = 0,
		},
		Meta = {
			CreatedAt = now,
			UpdatedAt = now,
			LastSaveAt = 0,
			Revision = 0,
			SessionLock = nil,
		},
	}
end

function DataSchema.GetVersion(rawData: any): number
	if type(rawData) ~= "table" then
		return 0
	end

	return boundedInteger(rawData.SchemaVersion, 0, 0, MAX_TIMESTAMP)
end

local function sanitizeOwnedPets(source: any): {[string]: any}
	local owned = {}
	if type(source) ~= "table" then
		return owned
	end

	local count = 0
	for rawUid, rawPet in pairs(source) do
		if count >= GameConfig.Pets.MaxOwned then
			break
		end

		local uid = safeString(rawUid, MAX_IDENTIFIER_LENGTH)
		if uid and type(rawPet) == "table" then
			local petId = safeString(rawPet.PetId, MAX_IDENTIFIER_LENGTH)
			if petId then
				owned[uid] = {
					Uid = uid,
					PetId = petId,
					AcquiredAt = boundedInteger(rawPet.AcquiredAt, 0, 0, MAX_TIMESTAMP),
				}
				count += 1
			end
		end
	end

	return owned
end

local function sanitizeEquippedPets(source: any, owned: {[string]: any}): {string}
	local equipped = {}
	local included = {}
	if type(source) ~= "table" then
		return equipped
	end

	for _, rawUid in ipairs(source) do
		if #equipped >= GameConfig.Pets.MaxEquipped then
			break
		end

		local uid = safeString(rawUid, MAX_IDENTIFIER_LENGTH)
		if uid and owned[uid] and not included[uid] then
			table.insert(equipped, uid)
			included[uid] = true
		end
	end

	return equipped
end

local function sanitizeOwnedCosmetics(source: any): {[string]: boolean}
	local owned = {}
	if type(source) ~= "table" then
		return owned
	end

	local count = 0
	for rawCosmeticId, isOwned in pairs(source) do
		if count >= GameConfig.Cosmetics.MaxOwned then
			break
		end

		local cosmeticId = safeString(rawCosmeticId, MAX_IDENTIFIER_LENGTH)
		if cosmeticId and isOwned == true then
			owned[cosmeticId] = true
			count += 1
		end
	end

	return owned
end

local function sanitizeEquippedCosmetics(source: any, owned: {[string]: boolean}): {[string]: string}
	local equipped = {}
	if type(source) ~= "table" then
		return equipped
	end

	for rawCategory, rawCosmeticId in pairs(source) do
		local category = safeString(rawCategory, MAX_CATEGORY_LENGTH)
		local cosmeticId = safeString(rawCosmeticId, MAX_IDENTIFIER_LENGTH)
		if category and cosmeticId and owned[cosmeticId] then
			equipped[category] = cosmeticId
		end
	end

	return equipped
end

local function sanitizeClaimedTiers(source: any): {[string]: boolean}
	local claimed = {}
	if type(source) ~= "table" then
		return claimed
	end

	for rawTier, isClaimed in pairs(source) do
		local tier = safeString(rawTier, MAX_IDENTIFIER_LENGTH)
		if tier and isClaimed == true then
			claimed[tier] = true
		end
	end

	return claimed
end

function DataSchema.Sanitize(rawData: any, userId: number): {[string]: any}
	local data = DataSchema.New(userId)
	if type(rawData) ~= "table" then
		return data
	end

	data.Coins = boundedInteger(
		rawData.Coins or rawData.coins,
		GameConfig.Economy.StartingCoins,
		0,
		GameConfig.Economy.MaxCoins
	)

	local rawPets = if type(rawData.Pets) == "table" then rawData.Pets else {}
	local rawOwnedPets = rawPets.Owned or rawData.OwnedPets
	local rawEquippedPets = rawPets.Equipped or rawData.EquippedPets
	local ownedPets = sanitizeOwnedPets(rawOwnedPets)
	local equippedPets = sanitizeEquippedPets(rawEquippedPets, ownedPets)

	if next(ownedPets) == nil then
		ownedPets = newOwnedPets(userId, os.time())
		equippedPets = { starterPetUid(userId) }
	end

	data.Pets.Owned = ownedPets
	data.Pets.Equipped = equippedPets

	local rawCosmetics = if type(rawData.Cosmetics) == "table" then rawData.Cosmetics else {}
	local ownedCosmetics = sanitizeOwnedCosmetics(rawCosmetics.Owned)
	data.Cosmetics.Owned = ownedCosmetics
	data.Cosmetics.Equipped = sanitizeEquippedCosmetics(rawCosmetics.Equipped, ownedCosmetics)

	local rawDailyRewards = if type(rawData.DailyRewards) == "table" then rawData.DailyRewards else {}
	data.DailyRewards.CycleDay = boundedInteger(rawDailyRewards.CycleDay, 1, 1, 7)
	data.DailyRewards.Streak = boundedInteger(rawDailyRewards.Streak, 0, 0, 9_999)
	data.DailyRewards.LastClaimAt = boundedInteger(rawDailyRewards.LastClaimAt, 0, 0, MAX_TIMESTAMP)

	local rawBattlePass = if type(rawData.BattlePass) == "table" then rawData.BattlePass else {}
	data.BattlePass.SeasonId = safeString(rawBattlePass.SeasonId, MAX_IDENTIFIER_LENGTH) or ""
	data.BattlePass.Xp = boundedInteger(rawBattlePass.Xp, 0, 0, GameConfig.Economy.MaxCoins)
	data.BattlePass.PremiumOwned = rawBattlePass.PremiumOwned == true
	data.BattlePass.ClaimedFree = sanitizeClaimedTiers(rawBattlePass.ClaimedFree)
	data.BattlePass.ClaimedPremium = sanitizeClaimedTiers(rawBattlePass.ClaimedPremium)

	local rawProgress = if type(rawData.Progress) == "table" then rawData.Progress else {}
	data.Progress.TotalCoinsEarned = boundedInteger(
		rawProgress.TotalCoinsEarned,
		0,
		0,
		GameConfig.Economy.MaxCoins
	)

	local rawMeta = if type(rawData.Meta) == "table" then rawData.Meta else {}
	data.Meta.CreatedAt = boundedInteger(rawMeta.CreatedAt, os.time(), 0, MAX_TIMESTAMP)
	data.Meta.UpdatedAt = boundedInteger(rawMeta.UpdatedAt, data.Meta.CreatedAt, 0, MAX_TIMESTAMP)
	data.Meta.LastSaveAt = boundedInteger(rawMeta.LastSaveAt, 0, 0, MAX_TIMESTAMP)
	data.Meta.Revision = boundedInteger(rawMeta.Revision, 0, 0, GameConfig.Economy.MaxCoins)
	data.Meta.SessionLock = nil
	data.SchemaVersion = GameConfig.DataStore.SchemaVersion

	return data
end

function DataSchema.Clone(data: any): any
	return cloneValue(data)
end

return table.freeze(DataSchema)
