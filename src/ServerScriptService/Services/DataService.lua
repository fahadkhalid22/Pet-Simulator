--!strict

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local DataSchema = require(script.Parent:WaitForChild("DataSchema"))

local changedEvent = Instance.new("BindableEvent")
local loadedEvent = Instance.new("BindableEvent")
local DataService = {
	Changed = changedEvent.Event,
	Loaded = loadedEvent.Event,
}

local dataStore = DataStoreService:GetDataStore(GameConfig.DataStore.Name, GameConfig.DataStore.Scope)
local sessionId = if game.JobId ~= "" then game.JobId else HttpService:GenerateGUID(false)

local profiles: {[number]: any} = {}
local loading: {[number]: boolean} = {}
local started = false
local shuttingDown = false

local function playerKey(userId: number): string
	return string.format("Player_%d", userId)
end

local function retryDelay(attempt: number): number
	local exponentialDelay = GameConfig.DataStore.InitialRetryDelaySeconds * (2 ^ (attempt - 1))
	return math.min(exponentialDelay, GameConfig.DataStore.MaxRetryDelaySeconds) + math.random() * 0.25
end

-- DataStore operations use bounded exponential backoff with jitter.
local function runDataStoreOperation(label: string, operation: () -> any): (boolean, any)
	local lastError = 'unknown DataStore error'
	for attempt = 1, GameConfig.DataStore.MaxOperationAttempts do
		local success, result = pcall(operation)
		if success then
			return true, result
		end
		lastError = tostring(result)
		warn('[Auralit DataService] ' .. label .. ' failed: ' .. lastError)
		if attempt < GameConfig.DataStore.MaxOperationAttempts then
			task.wait(retryDelay(attempt))
		end
	end
	return false, lastError
end

-- Locks prevent two live servers from saving the same player profile.
local function getForeignActiveLock(rawData: any): string?
	if type(rawData) ~= 'table' or type(rawData.Meta) ~= 'table' then
		return nil
	end

	local lock = rawData.Meta.SessionLock
	if type(lock) ~= 'table' or type(lock.SessionId) ~= 'string' or type(lock.ExpiresAt) ~= 'number' then
		return nil
	end

	if lock.SessionId ~= sessionId and lock.ExpiresAt > os.time() then
		return lock.SessionId
	end
	return nil
end

local function applySessionLock(data: {[string]: any}, shouldRelease: boolean)
	if shouldRelease then
		data.Meta.SessionLock = nil
	else
		data.Meta.SessionLock = {
			SessionId = sessionId,
			ExpiresAt = os.time() + GameConfig.DataStore.SessionLockSeconds,
		}
	end
end

-- Only non-sensitive display state is mirrored onto the Player.
local function syncPublicState(player: Player, data: {[string]: any})
	if player.Parent ~= Players then
		return
	end

	player:SetAttribute('DataLoaded', true)
	player:SetAttribute('Coins', data.Coins)

	local leaderstats = player:FindFirstChild('leaderstats')
	if not leaderstats then
		leaderstats = Instance.new('Folder')
		leaderstats.Name = 'leaderstats'
		leaderstats.Parent = player
	end

	local coins = leaderstats:FindFirstChild('Coins')
	if not coins or not coins:IsA('IntValue') then
		if coins then
			coins:Destroy()
		end
		coins = Instance.new('IntValue')
		coins.Name = 'Coins'
		coins.Parent = leaderstats
	end

	(coins :: IntValue).Value = data.Coins
end

-- UpdateAsync preserves session and revision checks on every write.
local function saveEntry(entry: any, shouldReleaseLock: boolean): (boolean, string?)
	while entry.saving or entry.updating do
		task.wait()
	end

	entry.saving = true
	local snapshot = DataSchema.Clone(entry.data)
	local snapshotRevision = entry.revision
	local lockConflict = false
	local savedAt = os.time()

	snapshot.SchemaVersion = GameConfig.DataStore.SchemaVersion
	snapshot.Meta.UpdatedAt = savedAt
	snapshot.Meta.LastSaveAt = savedAt
	snapshot.Meta.Revision = snapshotRevision
	applySessionLock(snapshot, shouldReleaseLock)

	local success, result = runDataStoreOperation('save', function()
		return dataStore:UpdateAsync(playerKey(entry.userId), function(storedData)
			if getForeignActiveLock(storedData) then
				lockConflict = true
				return nil
			end

			local storedRevision = 0
			if type(storedData) == 'table' and type(storedData.Meta) == 'table'
				and type(storedData.Meta.Revision) == 'number' then
				storedRevision = storedData.Meta.Revision
			end

			if storedRevision > snapshotRevision then
				lockConflict = true
				return nil
			end
			return snapshot
		end)
	end)

	entry.saving = false
	if not success then
		return false, tostring(result)
	end
	if lockConflict or result == nil then
		return false, 'profile session/revision conflict'
	end

	entry.data.Meta.LastSaveAt = savedAt
	entry.data.Meta.UpdatedAt = math.max(entry.data.Meta.UpdatedAt, savedAt)
	if not shouldReleaseLock then
		applySessionLock(entry.data, false)
	end
	if entry.revision == snapshotRevision then
		entry.dirty = false
	end
	return true, nil
end

local function loadProfile(player: Player)
	local userId = player.UserId
	if loading[userId] or profiles[userId] then
		return
	end

	loading[userId] = true
	player:SetAttribute("DataLoaded", false)
	player:SetAttribute("DataLoadFailed", false)

	local loadedData = nil
	local lastError = "profile lock could not be acquired"

	for lockAttempt = 1, GameConfig.DataStore.LoadLockAttempts do
		local lockConflict = false
		local incompatibleVersion = nil
		local success, result = runDataStoreOperation("load", function()
			return dataStore:UpdateAsync(playerKey(userId), function(storedData)
				if getForeignActiveLock(storedData) then
					lockConflict = true
					return nil
				end
				local storedVersion = DataSchema.GetVersion(storedData)
				if storedVersion > GameConfig.DataStore.SchemaVersion then
					incompatibleVersion = storedVersion
					return nil
				end

				local data = DataSchema.Sanitize(storedData, userId)
				data.Meta.UpdatedAt = os.time()
				applySessionLock(data, false)
				return data
			end)
		end)

		if success and not lockConflict and type(result) == "table" then
			loadedData = result
			break
		end
		if incompatibleVersion then
			lastError = string.format("stored schema version %d is newer than this server", incompatibleVersion)
			break
		end
		if not success then
			lastError = tostring(result)
			break
		end
		if not lockConflict then
			lastError = "DataStore returned no profile data"
			break
		end

		lastError = "profile is active on another server"
		if lockAttempt < GameConfig.DataStore.LoadLockAttempts then
			task.wait(GameConfig.DataStore.LoadLockRetrySeconds)
		end
	end

	loading[userId] = nil
	if not loadedData then
		player:SetAttribute("DataLoadFailed", true)
		warn(string.format("[Auralit DataService] Player %d load failed: %s", userId, lastError))
		if player.Parent == Players then
			player:Kick("Your data could not be loaded safely. Please rejoin in a moment.")
		end
		return
	end

	local entry = {
		userId = userId,
		data = loadedData,
		revision = loadedData.Meta.Revision,
		dirty = false,
		saving = false,
		updating = false,
		releasing = false,
	}
	profiles[userId] = entry

	if shuttingDown or player.Parent ~= Players then
		saveEntry(entry, true)
		profiles[userId] = nil
		return
	end

	syncPublicState(player, loadedData)
	loadedEvent:Fire(player, DataSchema.Clone(loadedData))
end

local function releaseProfile(player: Player)
	local userId = player.UserId
	local entry = profiles[userId]
	if not entry or entry.releasing then
		return
	end

	entry.releasing = true
	local success, saveError = saveEntry(entry, true)
	if not success then
		warn(string.format(
			"[Auralit DataService] Player %d release save failed: %s",
			userId,
			tostring(saveError)
		))
	end

	if profiles[userId] == entry then
		profiles[userId] = nil
	end
	if player.Parent == Players then
		player:SetAttribute("DataLoaded", false)
	end
end

function DataService.IsLoaded(player: Player): boolean
	return profiles[player.UserId] ~= nil
end

function DataService.GetSnapshot(player: Player): {[string]: any}?
	local entry = profiles[player.UserId]
	if not entry then
		return nil
	end

	return DataSchema.Clone(entry.data)
end

function DataService.Update(player: Player, mutator: ({[string]: any}) -> any): (boolean, any)
	local entry = profiles[player.UserId]
	if not entry or entry.releasing then
		return false, "player data is not loaded"
	end
	while entry.updating do
		task.wait()
	end
	if profiles[player.UserId] ~= entry or entry.releasing then
		return false, "player data is not loaded"
	end

	entry.updating = true
	local success, result, sanitized = pcall(function()
		local draft = DataSchema.Clone(entry.data)
		local mutationResult = mutator(draft)
		return mutationResult, DataSchema.Sanitize(draft, player.UserId)
	end)
	if not success then
		entry.updating = false
		return false, tostring(result)
	end

	entry.revision += 1
	sanitized.Meta.Revision = entry.revision
	sanitized.Meta.UpdatedAt = os.time()
	applySessionLock(sanitized, false)

	entry.data = sanitized
	entry.dirty = true
	entry.updating = false
	syncPublicState(player, sanitized)
	changedEvent:Fire(player, DataSchema.Clone(sanitized))

	return true, result
end

function DataService.SavePlayer(player: Player): (boolean, string?)
	local entry = profiles[player.UserId]
	if not entry or entry.releasing then
		return false, "player data is not loaded"
	end

	return saveEntry(entry, false)
end

local function autosaveProfiles()
	for userId, entry in pairs(profiles) do
		if not entry.releasing and not entry.saving then
			task.spawn(function()
				local success, saveError = saveEntry(entry, false)
				if not success then
					warn(string.format(
						"[Auralit DataService] Player %d autosave failed: %s",
						userId,
						tostring(saveError)
					))
				end
			end)
		end
	end
end

function DataService.Start()
	if started then
		return
	end
	started = true

	Players.PlayerAdded:Connect(function(player)
		task.spawn(loadProfile, player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		task.spawn(releaseProfile, player)
	end)

	for _, player in Players:GetPlayers() do
		task.spawn(loadProfile, player)
	end

	task.spawn(function()
		while not shuttingDown do
			task.wait(GameConfig.DataStore.AutosaveIntervalSeconds)
			if not shuttingDown then
				autosaveProfiles()
			end
		end
	end)

	game:BindToClose(function()
		shuttingDown = true
		for _, player in Players:GetPlayers() do
			task.spawn(releaseProfile, player)
		end

		local deadline = os.clock() + 25
		while (next(profiles) ~= nil or next(loading) ~= nil) and os.clock() < deadline do
			task.wait(0.1)
		end

		if next(profiles) ~= nil or next(loading) ~= nil then
			warn("[Auralit DataService] Shutdown deadline reached before all profiles closed")
		end
	end)
end

return table.freeze(DataService)
