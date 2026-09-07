--!strict

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local PetConfig = require(Shared:WaitForChild("PetConfig"))
local DataService = require(script.Parent:WaitForChild("DataService"))

local PetService = {}
local authoritativeStateChanged = Instance.new("BindableEvent")

PetService.StateChanged = authoritativeStateChanged.Event

local MAX_IDENTIFIER_LENGTH = 64
local started = false
local incomeCarry: {[number]: number} = {}
local requestWindows: {[number]: any} = {}
local stateChangedRemote: RemoteEvent? = nil
local incomeAwardedRemote: RemoteEvent? = nil

local function isIdentifier(value: any): boolean
	return type(value) == "string" and value ~= "" and #value <= MAX_IDENTIFIER_LENGTH
end

local function countEntries(source: {[string]: any}): number
	local count = 0
	for _ in pairs(source) do
		count += 1
	end
	return count
end

local function findEquipped(equipped: {string}, uid: string): number?
	for index, equippedUid in ipairs(equipped) do
		if equippedUid == uid then
			return index
		end
	end
	return nil
end

local function calculatePassiveIncome(data: {[string]: any}): number
	local total = 0
	local included: {[string]: boolean} = {}
	for _, uid in ipairs(data.Pets.Equipped) do
		local ownedPet = data.Pets.Owned[uid]
		if ownedPet and not included[uid] then
			total += PetConfig.GetPassiveIncome(ownedPet.PetId)
			included[uid] = true
		end
	end
	return total
end

local function buildState(data: {[string]: any}): {[string]: any}
	local owned = {}
	for uid, ownedPet in pairs(data.Pets.Owned) do
		table.insert(owned, {
			Uid = uid,
			PetId = ownedPet.PetId,
			AcquiredAt = ownedPet.AcquiredAt,
		})
	end

	table.sort(owned, function(left, right)
		local leftDefinition = PetConfig.Get(left.PetId)
		local rightDefinition = PetConfig.Get(right.PetId)
		local leftOrder = if leftDefinition then leftDefinition.SortOrder else math.huge
		local rightOrder = if rightDefinition then rightDefinition.SortOrder else math.huge
		if leftOrder ~= rightOrder then
			return leftOrder < rightOrder
		end
		if left.AcquiredAt ~= right.AcquiredAt then
			return left.AcquiredAt < right.AcquiredAt
		end
		return left.Uid < right.Uid
	end)

	local equipped = {}
	for _, uid in ipairs(data.Pets.Equipped) do
		table.insert(equipped, uid)
	end

	return {
		Coins = data.Coins,
		Owned = owned,
		Equipped = equipped,
		MaxEquipped = GameConfig.Pets.MaxEquipped,
		PassiveIncome = calculatePassiveIncome(data),
	}
end

local function syncPlayerState(player: Player): {[string]: any}?
	local snapshot = DataService.GetSnapshot(player)
	if not snapshot then
		return nil
	end

	local state = buildState(snapshot)
	player:SetAttribute("EquippedPetCount", #state.Equipped)
	player:SetAttribute("PassiveIncomePerSecond", state.PassiveIncome)

	local remote = stateChangedRemote
	if remote then
		remote:FireClient(player, state)
	end
	authoritativeStateChanged:Fire(player, state)
	return state
end

function PetService.GetState(player: Player): {[string]: any}?
	local snapshot = DataService.GetSnapshot(player)
	return if snapshot then buildState(snapshot) else nil
end

function PetService.GetPassiveIncome(player: Player): number
	local snapshot = DataService.GetSnapshot(player)
	return if snapshot then calculatePassiveIncome(snapshot) else 0
end

local function addOwnedPet(data: {[string]: any}, petId: string, autoEquip: boolean): string
	if countEntries(data.Pets.Owned) >= GameConfig.Pets.MaxOwned then
		error("INVENTORY_FULL", 0)
	end

	local uid = HttpService:GenerateGUID(false)
	data.Pets.Owned[uid] = {
		Uid = uid,
		PetId = petId,
		AcquiredAt = os.time(),
	}

	if autoEquip and #data.Pets.Equipped < GameConfig.Pets.MaxEquipped then
		table.insert(data.Pets.Equipped, uid)
	end
	return uid
end

local knownErrors: {[string]: boolean} = table.freeze({
	INVENTORY_FULL = true,
	INSUFFICIENT_COINS = true,
	NOT_EQUIPPED = true,
	PET_ALREADY_EQUIPPED = true,
	PET_NOT_OWNED = true,
	TOO_MANY_EQUIPPED = true,
})

local function mutationError(value: any): string
	local message = tostring(value)
	return if knownErrors[message] then message else "DATA_UNAVAILABLE"
end

function PetService.GrantPet(player: Player, petId: any, autoEquip: boolean?): (boolean, string)
	if not isIdentifier(petId) or not PetConfig.Get(petId) then
		return false, "UNKNOWN_PET"
	end

	local success, result = DataService.Update(player, function(data)
		return addOwnedPet(data, petId, autoEquip ~= false)
	end)
	if not success then
		return false, mutationError(result)
	end

	syncPlayerState(player)
	return true, result
end

function PetService.Purchase(player: Player, petId: any): (boolean, string)
	if not isIdentifier(petId) then
		return false, "INVALID_PET_ID"
	end

	local definition = PetConfig.Get(petId)
	if not definition then
		return false, "UNKNOWN_PET"
	end
	if not definition.Purchasable then
		return false, "NOT_PURCHASABLE"
	end

	local success, result = DataService.Update(player, function(data)
		if data.Coins < definition.Cost then
			error("INSUFFICIENT_COINS", 0)
		end
		local uid = addOwnedPet(data, petId, GameConfig.Pets.PurchaseAutoEquip)
		data.Coins -= definition.Cost
		return uid
	end)
	if not success then
		return false, mutationError(result)
	end

	syncPlayerState(player)
	return true, result
end

function PetService.Equip(player: Player, uid: any): (boolean, string)
	if not isIdentifier(uid) then
		return false, "INVALID_PET_UID"
	end

	local success, result = DataService.Update(player, function(data)
		local ownedPet = data.Pets.Owned[uid]
		if not ownedPet or not PetConfig.Get(ownedPet.PetId) then
			error("PET_NOT_OWNED", 0)
		end
		if findEquipped(data.Pets.Equipped, uid) then
			error("PET_ALREADY_EQUIPPED", 0)
		end
		if #data.Pets.Equipped >= GameConfig.Pets.MaxEquipped then
			error("TOO_MANY_EQUIPPED", 0)
		end

		table.insert(data.Pets.Equipped, uid)
		return uid
	end)
	if not success then
		return false, mutationError(result)
	end

	syncPlayerState(player)
	return true, result
end

function PetService.Unequip(player: Player, uid: any): (boolean, string)
	if not isIdentifier(uid) then
		return false, "INVALID_PET_UID"
	end

	local success, result = DataService.Update(player, function(data)
		local equippedIndex = findEquipped(data.Pets.Equipped, uid)
		if not equippedIndex then
			error("NOT_EQUIPPED", 0)
		end

		table.remove(data.Pets.Equipped, equippedIndex)
		return uid
	end)
	if not success then
		return false, mutationError(result)
	end

	syncPlayerState(player)
	return true, result
end

local function getRemotesFolder(): Folder
	local existing = ReplicatedStorage:FindFirstChild("Remotes")
	if existing then
		if not existing:IsA("Folder") then
			error("ReplicatedStorage.Remotes must be a Folder")
		end
		return existing
	end

	local folder = Instance.new("Folder")
	folder.Name = "Remotes"
	folder.Parent = ReplicatedStorage
	return folder
end

local function getRemoteFunction(parent: Folder, name: string): RemoteFunction
	local existing = parent:FindFirstChild(name)
	if existing then
		if not existing:IsA("RemoteFunction") then
			error(string.format("ReplicatedStorage.Remotes.%s must be a RemoteFunction", name))
		end
		return existing
	end

	local remote = Instance.new("RemoteFunction")
	remote.Name = name
	remote.Parent = parent
	return remote
end

local function getRemoteEvent(parent: Folder, name: string): RemoteEvent
	local existing = parent:FindFirstChild(name)
	if existing then
		if not existing:IsA("RemoteEvent") then
			error(string.format("ReplicatedStorage.Remotes.%s must be a RemoteEvent", name))
		end
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = parent
	return remote
end

local function allowRequest(player: Player): boolean
	local now = os.clock()
	local window = requestWindows[player.UserId]
	if not window or now - window.StartedAt >= GameConfig.Pets.RemoteWindowSeconds then
		requestWindows[player.UserId] = {
			StartedAt = now,
			Count = 1,
		}
		return true
	end

	if window.Count >= GameConfig.Pets.MaxRemoteRequestsPerWindow then
		return false
	end
	window.Count += 1
	return true
end

local function handleRequest(player: Player, action: any, value: any): {[string]: any}
	if type(action) ~= "string" or #action > 32 then
		return { Success = false, Code = "INVALID_ACTION" }
	end
	if action == "GetState" then
		local state = PetService.GetState(player)
		return if state
			then { Success = true, Code = "OK", State = state }
			else { Success = false, Code = "DATA_NOT_LOADED" }
	end

	local success = false
	local result = "INVALID_ACTION"
	if action == "Purchase" then
		success, result = PetService.Purchase(player, value)
	elseif action == "Equip" then
		success, result = PetService.Equip(player, value)
	elseif action == "Unequip" then
		success, result = PetService.Unequip(player, value)
	else
		return { Success = false, Code = "INVALID_ACTION" }
	end

	return {
		Success = success,
		Code = if success then "OK" else result,
		Result = if success then result else nil,
		State = if success then PetService.GetState(player) else nil,
	}
end

local function awardPassiveIncome(player: Player, elapsed: number)
	local carry = incomeCarry[player.UserId] or 0
	local success, result = DataService.Update(player, function(data)
		local rate = calculatePassiveIncome(data)
		if rate <= 0 then
			error("NO_PASSIVE_INCOME", 0)
		end

		local accrued = carry + rate * elapsed
		local requested = math.floor(accrued)
		if requested <= 0 then
			return { Awarded = 0, Carry = accrued, Rate = rate }
		end

		local available = GameConfig.Economy.MaxCoins - data.Coins
		if available <= 0 then
			error("COIN_CAP", 0)
		end

		local awarded = math.min(requested, available)
		data.Coins += awarded
		data.Progress.TotalCoinsEarned = math.min(
			GameConfig.Economy.MaxCoins,
			data.Progress.TotalCoinsEarned + awarded
		)

		return {
			Awarded = awarded,
			Carry = if awarded < requested then 0 else accrued - requested,
			Rate = rate,
		}
	end)

	if not success then
		if result == "COIN_CAP" or result == "NO_PASSIVE_INCOME" then
			incomeCarry[player.UserId] = 0
		elseif result ~= "player data is not loaded" then
			warn(string.format(
				"[Auralit PetService] Passive income failed for player %d: %s",
				player.UserId,
				tostring(result)
			))
		end
		return
	end

	incomeCarry[player.UserId] = result.Carry
	player:SetAttribute("PassiveIncomePerSecond", result.Rate)
	local remote = incomeAwardedRemote
	if remote and result.Awarded > 0 then
		remote:FireClient(player, result.Awarded, result.Rate)
	end
end

local function runPassiveIncomeLoop()
	local lastTick = os.clock()
	while true do
		task.wait(GameConfig.Pets.PassiveIncomeIntervalSeconds)
		local now = os.clock()
		local elapsed = math.clamp(now - lastTick, 0, GameConfig.Pets.MaxPassiveCatchupSeconds)
		lastTick = now

		for _, player in Players:GetPlayers() do
			if DataService.IsLoaded(player) then
				awardPassiveIncome(player, elapsed)
			end
		end
	end
end

function PetService.Start()
	if started then
		return
	end

	local remotes = getRemotesFolder()
	local requestRemote = getRemoteFunction(remotes, "PetRequest")
	stateChangedRemote = getRemoteEvent(remotes, "PetStateChanged")
	incomeAwardedRemote = getRemoteEvent(remotes, "PassiveIncomeAwarded")
	started = true

	requestRemote.OnServerInvoke = function(player, action, value)
		if not allowRequest(player) then
			return { Success = false, Code = "RATE_LIMITED" }
		end

		local success, result = pcall(handleRequest, player, action, value)
		if not success then
			warn(string.format(
				"[Auralit PetService] Request failed for player %d: %s",
				player.UserId,
				tostring(result)
			))
			return { Success = false, Code = "INTERNAL_ERROR" }
		end
		return result
	end

	DataService.Loaded:Connect(function(player)
		incomeCarry[player.UserId] = 0
		syncPlayerState(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		incomeCarry[player.UserId] = nil
		requestWindows[player.UserId] = nil
	end)

	for _, player in Players:GetPlayers() do
		if DataService.IsLoaded(player) then
			syncPlayerState(player)
		end
	end

	task.spawn(runPassiveIncomeLoop)
end

return table.freeze(PetService)
