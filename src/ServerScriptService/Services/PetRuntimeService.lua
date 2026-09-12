--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local PetConfig = require(Shared:WaitForChild("PetConfig"))
local PetRuntimeConfig = require(Shared:WaitForChild("PetRuntimeConfig"))
local presentationProfiles = PetRuntimeConfig.Profiles :: {[string]: any}
local PetService = require(script.Parent:WaitForChild("PetService"))

local PetRuntimeService = {}

type RuntimePet = {
	Model: Model,
	Slot: number,
}

type DesiredPet = {
	Slot: number,
	Definition: any,
}

type PlayerRuntime = {
	Player: Player,
	Folder: Folder,
	Pets: {[string]: RuntimePet},
	CharacterAdded: RBXScriptConnection?,
	CharacterRemoving: RBXScriptConnection?,
}

local RUNTIME_FOLDER_NAME = PetRuntimeConfig.ContainerName
local PARK_CFRAME = PetRuntimeConfig.ParkCFrame
local FORMATION_OFFSETS = PetRuntimeConfig.FormationOffsets

local started = false
local runtimeRoot: Folder? = nil
local runtimes: {[number]: PlayerRuntime} = {}
local warned: {[string]: boolean} = {}

local function warnOnce(key: string, message: string)
	if warned[key] then
		return
	end
	warned[key] = true
	warn("[Auralit PetRuntime] " .. message)
end

local function createRuntimeRoot(): Folder
	local existing = workspace:FindFirstChild(RUNTIME_FOLDER_NAME)
	if existing and existing:IsA("Folder") then
		existing:ClearAllChildren()
		return existing
	end
	if existing then
		warnOnce("runtime-container", "Workspace runtime name is occupied by a non-Folder.")
	end

	local folder = Instance.new("Folder")
	folder.Name = if existing then RUNTIME_FOLDER_NAME .. "Managed" else RUNTIME_FOLDER_NAME
	folder.Parent = workspace
	return folder
end

local function getPlayerRuntime(player: Player): PlayerRuntime
	local existing = runtimes[player.UserId]
	if existing then
		return existing
	end

	local root = runtimeRoot
	assert(root, "Pet runtime root is not initialized")
	local folder = Instance.new("Folder")
	folder.Name = "Player_" .. tostring(player.UserId)
	folder:SetAttribute("OwnerUserId", player.UserId)
	folder.Parent = root

	local created: PlayerRuntime = {
		Player = player,
		Folder = folder,
		Pets = {},
		CharacterAdded = nil,
		CharacterRemoving = nil,
	}
	runtimes[player.UserId] = created
	return created
end

local function destroyRuntimePets(runtime: PlayerRuntime)
	for _, runtimePet in pairs(runtime.Pets) do
		runtimePet.Model:Destroy()
	end
	table.clear(runtime.Pets)
	runtime.Folder:ClearAllChildren()
end

local function cleanupPlayer(player: Player)
	local runtime = runtimes[player.UserId]
	if not runtime then
		return
	end
	if runtime.CharacterAdded then
		runtime.CharacterAdded:Disconnect()
	end
	if runtime.CharacterRemoving then
		runtime.CharacterRemoving:Disconnect()
	end
	destroyRuntimePets(runtime)
	runtime.Folder:Destroy()
	runtimes[player.UserId] = nil
end

local function getPetModelsFolder(): Folder?
	local folder = ServerStorage:FindFirstChild("PetModels")
	if not folder or not folder:IsA("Folder") then
		warnOnce("pet-model-folder", "ServerStorage/PetModels is missing or is not a Folder.")
		return nil
	end
	return folder
end

local function createPetModel(player: Player, uid: string, definition: any): Model?
	local petModels = getPetModelsFolder()
	if not petModels then
		return nil
	end

	local source = petModels:FindFirstChild(definition.ModelName)
	if not source or not source:IsA("Model") then
		warnOnce(
			"missing-" .. definition.Id,
			string.format("Model %s is missing or malformed.", tostring(definition.ModelName))
		)
		return nil
	end

	local cloned, result = pcall(function()
		return source:Clone()
	end)
	if not cloned or not result then
		warnOnce("clone-" .. definition.Id, "Could not clone model " .. definition.ModelName .. ".")
		return nil
	end
	local model = result :: Model
	local primaryPart = model:FindFirstChild("Body")
	if not primaryPart or not primaryPart:IsA("BasePart") then
		model:Destroy()
		warnOnce("parts-" .. definition.Id, "Model " .. definition.ModelName .. " has no Body BasePart.")
		return nil
	end

	model.PrimaryPart = primaryPart
	model.Name = "Pet_" .. uid
	model:SetAttribute("OwnerUserId", player.UserId)
	model:SetAttribute("PetUid", uid)
	model:SetAttribute("PetId", definition.Id)
	local profile = presentationProfiles[definition.Id]
	if not profile then
		model:Destroy()
		warnOnce("profile-" .. definition.Id, "No runtime presentation profile exists for " .. definition.Id .. ".")
		return nil
	end
	model:SetAttribute("LocomotionMode", profile.Mode)
	model:SetAttribute("LocomotionStyle", profile.Style)
	model:SetAttribute("RuntimeSchemaVersion", 1)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
			descendant.Massless = true
		elseif descendant:IsA("Script") then
			descendant.Enabled = false
		elseif descendant:IsA("LocalScript") then
			descendant.Enabled = false
		end
	end
	return model
end

local function getBottomLift(model: Model, petId: string): number
	local ok, boundsCFrame, boundsSize = pcall(model.GetBoundingBox, model)
	if not ok then
		warnOnce("bounds-" .. petId, "Could not measure model bounds for " .. petId .. ".")
		return 1
	end

	local lift = model:GetPivot().Position.Y - (boundsCFrame.Position.Y - boundsSize.Y * 0.5)
	if lift ~= lift or lift == math.huge or lift == -math.huge then
		warnOnce("bounds-finite-" .. petId, "Model bounds are not finite for " .. petId .. ".")
		return 1
	end
	return math.clamp(lift, 0, 6)
end

local function buildDesiredPets(state: any): {[string]: DesiredPet}
	local desired: {[string]: DesiredPet} = {}
	if type(state) ~= "table" or type(state.Owned) ~= "table" or type(state.Equipped) ~= "table" then
		return desired
	end

	local ownedByUid: {[string]: any} = {}
	for _, ownedPet in ipairs(state.Owned) do
		if type(ownedPet) == "table"
			and type(ownedPet.Uid) == "string"
			and type(ownedPet.PetId) == "string" then
			ownedByUid[ownedPet.Uid] = ownedPet
		end
	end

	local slotLimit = math.min(GameConfig.Pets.MaxEquipped, #FORMATION_OFFSETS)
	for slot, uid in ipairs(state.Equipped) do
		if slot > slotLimit then
			break
		end
		if type(uid) == "string" and not desired[uid] then
			local ownedPet = ownedByUid[uid]
			local definition = if ownedPet then PetConfig.Get(ownedPet.PetId) else nil
			if definition and type(definition.ModelName) == "string" then
				desired[uid] = {
					Slot = slot,
					Definition = definition,
				}
			end
		end
	end
	return desired
end

local function syncPlayer(player: Player, state: any)
	if player.Parent ~= Players then
		return
	end
	local runtime = getPlayerRuntime(player)
	local desired = buildDesiredPets(state)

	for uid, runtimePet in pairs(runtime.Pets) do
		local wanted = desired[uid]
		if not wanted or runtimePet.Model:GetAttribute("PetId") ~= wanted.Definition.Id then
			runtimePet.Model:Destroy()
			runtime.Pets[uid] = nil
		else
			runtimePet.Slot = wanted.Slot
			runtimePet.Model:SetAttribute("FormationSlot", wanted.Slot)
		end
	end

	for uid, wanted in pairs(desired) do
		if not runtime.Pets[uid] then
			local model = createPetModel(player, uid, wanted.Definition)
			if model then
				local bottomLift = getBottomLift(model, wanted.Definition.Id)
				model:SetAttribute("FormationSlot", wanted.Slot)
				model:SetAttribute("GroundOffset", bottomLift)
				model:PivotTo(PARK_CFRAME)
				model.Parent = runtime.Folder
				runtime.Pets[uid] = {
					Model = model,
					Slot = wanted.Slot,
				}
			end
		end
	end
end

local function resyncPlayer(player: Player)
	local state = PetService.GetState(player)
	if state then
		syncPlayer(player, state)
	end
end

local function setupPlayer(player: Player)
	local runtime = getPlayerRuntime(player)
	if runtime.CharacterAdded or runtime.CharacterRemoving then
		return
	end
	runtime.CharacterRemoving = player.CharacterRemoving:Connect(function()
		local current = runtimes[player.UserId]
		if current then
			destroyRuntimePets(current)
		end
	end)
	runtime.CharacterAdded = player.CharacterAdded:Connect(function()
		task.defer(resyncPlayer, player)
	end)
	resyncPlayer(player)
end

function PetRuntimeService.Start()
	if started then
		return
	end
	runtimeRoot = createRuntimeRoot()
	started = true

	PetService.StateChanged:Connect(function(player: Player, state: any)
		syncPlayer(player, state)
	end)
	Players.PlayerAdded:Connect(setupPlayer)
	Players.PlayerRemoving:Connect(cleanupPlayer)
	for _, player in Players:GetPlayers() do
		setupPlayer(player)
	end
end

return table.freeze(PetRuntimeService)
