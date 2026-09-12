--!strict

-- Cosmetic-only client animation. The server remains authoritative for which
-- equipped pet models exist, their identity, owner, and formation slot.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PetRuntimeConfig = require(Shared:WaitForChild("PetRuntimeConfig"))
local profiles = PetRuntimeConfig.Profiles :: {[string]: any}

type PartPose = {
	Part: BasePart,
	LocalCFrame: CFrame,
	Group: string,
}

type RuntimeState = {
	Model: Model,
	OwnerUserId: number,
	PetId: string,
	Profile: any,
	GroundOffset: number,
	Parts: {PartPose},
	GroupPivots: {[string]: Vector3},
	CurrentCFrame: CFrame?,
	GroundY: number?,
	NextRaycast: number,
	Phase: number,
	AnimationState: string,
	Activity: number,
	Hidden: boolean,
}

local states: {[Model]: RuntimeState} = {}
local warned: {[string]: boolean} = {}

local function warnOnce(key: string, message: string)
	if warned[key] then
		return
	end
	warned[key] = true
	warn("[Auralit PetAnimator] " .. message)
end

local function classifyPart(name: string): string
	if string.find(name, "Staff", 1, true) then
		return "Staff"
	elseif string.find(name, "Wing", 1, true) then
		return if string.sub(name, 1, 4) == "Left" then "LeftWing" else "RightWing"
	elseif string.find(name, "Tail", 1, true) then
		return "Tail"
	elseif string.find(name, "Ear", 1, true) then
		return if string.sub(name, 1, 4) == "Left" then "LeftEar" else "RightEar"
	end

	local isHead = string.find(name, "Head", 1, true)
		or string.find(name, "Face", 1, true)
		or string.find(name, "Eye", 1, true)
		or string.find(name, "Brow", 1, true)
		or string.find(name, "Muzzle", 1, true)
		or string.find(name, "Nose", 1, true)
		or string.find(name, "Mouth", 1, true)
		or string.find(name, "Tongue", 1, true)
		or string.find(name, "Cheek", 1, true)
		or string.find(name, "Beak", 1, true)
		or string.find(name, "Helmet", 1, true)
		or string.find(name, "Forehead", 1, true)
	if isHead then
		return "Head"
	end

	local isLimb = string.find(name, "Arm", 1, true)
		or string.find(name, "Hand", 1, true)
		or string.find(name, "Leg", 1, true)
		or string.find(name, "Foot", 1, true)
		or string.find(name, "Paw", 1, true)
		or string.find(name, "Talon", 1, true)
		or string.find(name, "Toe", 1, true)
		or string.find(name, "Haunch", 1, true)
		or string.find(name, "Boot", 1, true)
		or string.find(name, "Shoulder", 1, true)
		or string.find(name, "Cuff", 1, true)
	if isLimb then
		local side = if string.sub(name, 1, 4) == "Left" then "Left" else "Right"
		local isFront = string.find(name, "Front", 1, true)
			or string.find(name, "Arm", 1, true)
			or string.find(name, "Hand", 1, true)
			or string.find(name, "Shoulder", 1, true)
			or string.find(name, "Cuff", 1, true)
		return side .. (if isFront then "FrontLimb" else "RearLimb")
	end
	return "Body"
end

local function phaseFromUid(uid: string): number
	local hash = 0
	for index = 1, #uid do
		hash = (hash * 31 + string.byte(uid, index)) % 10_000
	end
	return hash / 10_000 * math.pi * 2
end

local function averageGroupPivots(parts: {PartPose}): {[string]: Vector3}
	local sums: {[string]: Vector3} = {}
	local counts: {[string]: number} = {}
	for _, pose in parts do
		sums[pose.Group] = (sums[pose.Group] or Vector3.zero) + pose.LocalCFrame.Position
		counts[pose.Group] = (counts[pose.Group] or 0) + 1
	end
	local pivots: {[string]: Vector3} = {}
	for group, sum in sums do
		pivots[group] = sum / counts[group]
	end
	return pivots
end

local function registerModel(model: Model)
	if states[model] then
		return
	end
	local ownerUserId = model:GetAttribute("OwnerUserId")
	local petId = model:GetAttribute("PetId")
	local uid = model:GetAttribute("PetUid")
	local groundOffset = model:GetAttribute("GroundOffset")
	local locomotionMode = model:GetAttribute("LocomotionMode")
	local locomotionStyle = model:GetAttribute("LocomotionStyle")
	local profile = if type(petId) == "string" then profiles[petId] else nil
	local body = model:FindFirstChild("Body")
	if type(ownerUserId) ~= "number" or type(uid) ~= "string" or type(groundOffset) ~= "number"
		or not profile or locomotionMode ~= profile.Mode or locomotionStyle ~= profile.Style
		or not body or not body:IsA("BasePart") then
		warnOnce(model:GetFullName(), "Ignored malformed runtime model " .. model:GetFullName() .. ".")
		return
	end
	if groundOffset ~= groundOffset or groundOffset < 0 or groundOffset > 6 then
		warnOnce(model:GetFullName(), "Ignored runtime model with invalid ground offset " .. model:GetFullName() .. ".")
		return
	end

	local pivot = model:GetPivot()
	local parts: {PartPose} = {}
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			table.insert(parts, {
				Part = descendant,
				LocalCFrame = pivot:ToObjectSpace(descendant.CFrame),
				Group = classifyPart(descendant.Name),
			})
		end
	end
	if #parts == 0 then
		warnOnce(model:GetFullName(), "Ignored runtime model without BaseParts " .. model:GetFullName() .. ".")
		return
	end

	states[model] = {
		Model = model,
		OwnerUserId = ownerUserId,
		PetId = petId :: string,
		Profile = profile,
		GroundOffset = groundOffset,
		Parts = parts,
		GroupPivots = averageGroupPivots(parts),
		CurrentCFrame = nil,
		GroundY = nil,
		NextRaycast = os.clock() + phaseFromUid(uid) * PetRuntimeConfig.RaycastInterval / (math.pi * 2),
		Phase = phaseFromUid(uid),
		AnimationState = if profile.Mode == "Hover" then "Hover" else "Idle",
		Activity = 0,
		Hidden = false,
	}
end

local function getLivingRoot(userId: number): BasePart?
	local player = Players:GetPlayerByUserId(userId)
	local character = if player then player.Character else nil
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return nil
	end
	return root
end

local function buildRaycastFilter(runtimeRoot: Instance): {Instance}
	local filter = {runtimeRoot}
	for _, folderName in {"Effects", "VFX", "TransientEffects"} do
		local transient = workspace:FindFirstChild(folderName)
		if transient then
			table.insert(filter, transient)
		end
	end
	for _, player in Players:GetPlayers() do
		if player.Character then
			table.insert(filter, player.Character)
		end
	end
	return filter
end

local function sampleGround(state: RuntimeState, runtimeRoot: Instance, position: Vector3, now: number): number
	if now < state.NextRaycast and state.GroundY then
		return state.GroundY
	end
	state.NextRaycast = now + PetRuntimeConfig.RaycastInterval
	local parameters = RaycastParams.new()
	parameters.FilterType = Enum.RaycastFilterType.Exclude
	parameters.FilterDescendantsInstances = buildRaycastFilter(runtimeRoot)
	parameters.IgnoreWater = false
	local origin = position + Vector3.yAxis * PetRuntimeConfig.RaycastHeight
	local distance = PetRuntimeConfig.RaycastHeight + PetRuntimeConfig.RaycastDepth
	local result = workspace:Raycast(origin, -Vector3.yAxis * distance, parameters)
	if result then
		state.GroundY = result.Position.Y
	elseif not state.GroundY then
		state.GroundY = position.Y - 3
	end
	return state.GroundY :: number
end

local function animationForGroup(state: RuntimeState, group: string, now: number): CFrame
	local profile = state.Profile
	local cycle = now * profile.Pace + state.Phase
	local wave = math.sin(cycle)
	local activity = 0.22 + state.Activity * 0.78
	local body = profile.BodyMotion * math.sin(cycle * 0.5) * activity
	local accent = profile.AccentMotion * activity
	local style = profile.Style

	if group == "Body" then
		local lean = math.rad(-2.5) * wave * state.Activity
		return CFrame.new(0, body, 0) * CFrame.Angles(lean, 0, 0)
	elseif group == "Head" then
		return CFrame.Angles(math.rad(2) * wave * activity, 0, math.rad(1.25) * math.sin(cycle * 0.5))
	elseif group == "LeftEar" then
		return CFrame.Angles(accent * 0.28 * wave, 0, -accent * 0.08)
	elseif group == "RightEar" then
		return CFrame.Angles(accent * 0.28 * wave, 0, accent * 0.08)
	elseif group == "Tail" then
		local tailWave = math.sin(cycle * (if style == "Bounce" then 1.7 else 0.85))
		return CFrame.Angles(accent * 0.18, accent * tailWave, 0)
	elseif profile.Mode == "Hover" and string.find(group, "Limb", 1, true) then
		return CFrame.identity
	elseif group == "LeftFrontLimb" or group == "RightRearLimb" then
		return CFrame.Angles(accent * wave, 0, 0)
	elseif group == "RightFrontLimb" or group == "LeftRearLimb" then
		return CFrame.Angles(-accent * wave, 0, 0)
	elseif group == "LeftWing" then
		local flap = math.sin(cycle * (if state.AnimationState == "Move" then 1.2 else 0.55))
		return CFrame.Angles(0, 0, accent * (0.45 + flap * 0.55))
	elseif group == "RightWing" then
		local flap = math.sin(cycle * (if state.AnimationState == "Move" then 1.2 else 0.55))
		return CFrame.Angles(0, 0, -accent * (0.45 + flap * 0.55))
	elseif group == "Staff" then
		return CFrame.Angles(0, 0, -accent * wave * 0.35)
	end
	return CFrame.identity
end

local function applyPose(state: RuntimeState, rootCFrame: CFrame, now: number)
	for _, pose in state.Parts do
		if pose.Part.Parent then
			local pivot = state.GroupPivots[pose.Group] or Vector3.zero
			local animation = animationForGroup(state, pose.Group, now)
			pose.Part.CFrame = rootCFrame
				* CFrame.new(pivot)
				* animation
				* CFrame.new(-pivot)
				* pose.LocalCFrame
		end
	end
end

local function rootMotion(state: RuntimeState, now: number): number
	local profile = state.Profile
	if profile.Mode == "Hover" then
		return profile.HoverHeight + math.sin(now * profile.Pace + state.Phase) * profile.RootMotion
	elseif profile.Style == "Hop" or profile.Style == "Bound" then
		return math.abs(math.sin(now * profile.Pace + state.Phase)) * profile.RootMotion * state.Activity
	end
	return (math.sin(now * profile.Pace + state.Phase) + 1) * 0.5 * profile.RootMotion * state.Activity
end

local configuredRoot = workspace:WaitForChild(PetRuntimeConfig.ContainerName)
local runtimeRoot = if configuredRoot:IsA("Folder")
	then configuredRoot
	else workspace:WaitForChild(PetRuntimeConfig.ContainerName .. "Managed")

for _, descendant in runtimeRoot:GetDescendants() do
	if descendant:IsA("Model") then
		registerModel(descendant)
	end
end

runtimeRoot.DescendantAdded:Connect(function(descendant: Instance)
	local model: Model? = nil
	if descendant:IsA("Model") then
		model = descendant
	else
		local ancestor = descendant:FindFirstAncestorWhichIsA("Model")
		if ancestor and ancestor:IsA("Model") then
			model = ancestor
		end
	end
	if model and model:IsDescendantOf(runtimeRoot) then
		task.defer(registerModel, model)
	end
end)

runtimeRoot.DescendantRemoving:Connect(function(descendant: Instance)
	if descendant:IsA("Model") then
		states[descendant] = nil
	end
end)

RunService.RenderStepped:Connect(function(deltaTime: number)
	local now = os.clock()
	local alpha = 1 - math.exp(-PetRuntimeConfig.FollowResponsiveness * math.min(deltaTime, 0.25))
	for model, state in states do
		if not model.Parent then
			states[model] = nil
			continue
		end

		local root = getLivingRoot(state.OwnerUserId)
		if not root then
			if not state.Hidden then
				applyPose(state, PetRuntimeConfig.ParkCFrame, now)
				state.Hidden = true
				state.CurrentCFrame = nil
				state.GroundY = nil
			end
			continue
		end

		local slot = model:GetAttribute("FormationSlot")
		if type(slot) ~= "number" or slot % 1 ~= 0 or not PetRuntimeConfig.FormationOffsets[slot] then
			warnOnce(model:GetFullName() .. ":slot", "Ignored invalid formation slot on " .. model:GetFullName() .. ".")
			continue
		end

		local look = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
		if look.Magnitude < 0.001 then
			look = Vector3.new(0, 0, -1)
		else
			look = look.Unit
		end
		local ownerFacing = CFrame.lookAt(root.Position, root.Position + look)
		local formationPosition = ownerFacing:PointToWorldSpace(PetRuntimeConfig.FormationOffsets[slot])
		local groundY = sampleGround(state, runtimeRoot, formationPosition, now)
		local velocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
		local moving = velocity.Magnitude >= PetRuntimeConfig.MoveThreshold
		state.AnimationState = if state.Profile.Mode == "Hover" then "Hover" elseif moving then "Move" else "Idle"
		local activityTarget = if moving then 1 else 0
		local activityAlpha = 1 - math.exp(-6 * math.min(deltaTime, 0.25))
		state.Activity += (activityTarget - state.Activity) * activityAlpha
		local lift = state.GroundOffset + rootMotion(state, now)
		local targetPosition = Vector3.new(formationPosition.X, groundY + lift, formationPosition.Z)
		local travelLook = if moving then velocity.Unit else look
		local target = CFrame.lookAt(targetPosition, targetPosition + travelLook)
		local current = state.CurrentCFrame
		if not current or (current.Position - target.Position).Magnitude > PetRuntimeConfig.TeleportDistance then
			current = target
		else
			current = current:Lerp(target, alpha)
		end
		state.CurrentCFrame = current
		state.Hidden = false
		applyPose(state, current, now)
	end
end)
