--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local PetConfig = require(Shared:WaitForChild("PetConfig"))
local PetService = require(script.Parent:WaitForChild("PetService"))

local PetRuntimeService = {}

type RuntimePet = {
	Model: Model,
	Slot: number,
	CurrentCFrame: CFrame?,
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

local RUNTIME_FOLDER_NAME = "AuralitPetRuntime"
local FOLLOW_RESPONSIVENESS = 8
local BOB_HEIGHT = 0.35
local BOB_SPEED = 3.5
local PARK_CFRAME = CFrame.new(0, -10_000, 0)
local FORMATION_OFFSETS = table.freeze({
	Vector3.new(0, -1.15, 4.75),
	Vector3.new(-3, -1.15, 6.25),
	Vector3.new(3, -1.15, 6.25),
})

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
	local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
	if not primaryPart then
		model:Destroy()
		warnOnce("parts-" .. definition.Id, "Model " .. definition.ModelName .. " has no BasePart.")
		return nil
	end

	model.PrimaryPart = primaryPart
	model.Name = "Pet_" .. uid
	model:SetAttribute("OwnerUserId", player.UserId)
	model:SetAttribute("PetUid", uid)
	model:SetAttribute("PetId", definition.Id)
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
				model:SetAttribute("FormationSlot", wanted.Slot)
				model:PivotTo(PARK_CFRAME)
				model.Parent = runtime.Folder
				runtime.Pets[uid] = {
					Model = model,
					Slot = wanted.Slot,
					CurrentCFrame = nil,
				}
			end
		end
	end
end

local function getCharacterRoot(player: Player): BasePart?
	local character = player.Character
	if not character then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return nil
	end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	return if rootPart and rootPart:IsA("BasePart") then rootPart else nil
end

local function targetCFrame(rootPart: BasePart, runtimePet: RuntimePet, now: number): CFrame
	local offset = FORMATION_OFFSETS[runtimePet.Slot] or FORMATION_OFFSETS[1]
	local bob = math.sin(now * BOB_SPEED + runtimePet.Slot * 1.7) * BOB_HEIGHT
	return rootPart.CFrame * CFrame.new(offset.X, offset.Y + bob, offset.Z)
end

local function updatePets(deltaTime: number)
	local alpha = 1 - math.exp(-FOLLOW_RESPONSIVENESS * math.min(deltaTime, 0.25))
	local now = os.clock()
	for _, runtime in pairs(runtimes) do
		local rootPart = getCharacterRoot(runtime.Player)
		if rootPart then
			for _, runtimePet in pairs(runtime.Pets) do
				local target = targetCFrame(rootPart, runtimePet, now)
				local current = runtimePet.CurrentCFrame
				local nextCFrame = if current then current:Lerp(target, alpha) else target
				runtimePet.CurrentCFrame = nextCFrame
				runtimePet.Model:PivotTo(nextCFrame)
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
	RunService.Heartbeat:Connect(updatePets)
end

return table.freeze(PetRuntimeService)
