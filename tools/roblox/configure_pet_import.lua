-- Safe post-import configuration for Auralit v3 mesh candidates other than FrostBunny.
-- Paste into the Roblox Studio Command Bar with exactly one imported Workspace Model selected.
-- This helper never deletes, moves, or replaces anything in ServerStorage.

local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")

local specs = {
	ChibiCat = {
		petName = "Chibi Cat", rarity = "Common", baseRate = 10, meshCount = 31,
		boundsMin = Vector3.new(2.4, 3.5, 1.7), boundsMax = Vector3.new(2.8, 3.9, 2.1),
		meshNames = {
			"Body", "Head", "LeftOuterEar", "RightOuterEar", "LeftInnerEar", "RightInnerEar",
			"LeftMuzzle", "RightMuzzle", "ForeheadBlaze", "LeftEye", "RightEye", "LeftEyeRing", "RightEyeRing",
			"LeftEyeHighlight", "RightEyeHighlight", "Nose", "Mouth", "Chest", "LeftFrontLeg", "RightFrontLeg",
			"LeftFrontPaw", "RightFrontPaw", "LeftHaunch", "RightHaunch", "LeftToe1", "LeftToe2", "LeftToe3",
			"RightToe1", "RightToe2", "RightToe3", "Tail",
		},
		effects = {{name = "SilverDust", className = "ParticleEmitter", position = Vector3.new(0, 0.2, 0)}},
	},
	FluffDog = {
		petName = "Fluff Dog", rarity = "Common", baseRate = 10, meshCount = 31,
		boundsMin = Vector3.new(3.0, 3.15, 1.7), boundsMax = Vector3.new(3.3, 3.55, 2.1),
		meshNames = {
			"Body", "Head", "LeftEar", "RightEar", "FaceBlaze", "LeftMuzzle", "RightMuzzle",
			"LeftEye", "RightEye", "LeftIris", "RightIris", "LeftEyeHighlight", "RightEyeHighlight",
			"LeftBrow", "RightBrow", "LeftCheek", "RightCheek", "Nose", "Mouth", "Tongue", "Chest",
			"LeftFrontLeg", "RightFrontLeg", "LeftFrontPaw", "RightFrontPaw", "LeftRearLeg", "RightRearLeg",
			"LeftRearPaw", "RightRearPaw", "Tail", "TailTip",
		},
		effects = {{name = "SilverDust", className = "ParticleEmitter", position = Vector3.new(0, 0.2, 0)}},
	},
	FrostFox = {
		petName = "Frost Fox", rarity = "Epic", baseRate = 50, meshCount = 31,
		boundsMin = Vector3.new(3.0, 3.45, 2.5), boundsMax = Vector3.new(3.4, 3.9, 2.9),
		meshNames = {
			"Body", "Head", "LeftOuterEar", "RightOuterEar", "LeftInnerEar", "RightInnerEar", "LeftEye", "RightEye",
			"LeftEyeHighlight", "RightEyeHighlight", "Nose", "LeftCheekFur", "RightCheekFur", "ForeheadTuftCenter",
			"ForeheadTuftLeft", "ForeheadTuftRight", "ChestRuffUpper", "ChestRuffLeft", "ChestRuffRight", "ChestRuffLower",
			"LeftFrontLeg", "RightFrontLeg", "LeftRearLeg", "RightRearLeg", "LeftFrontPaw", "RightFrontPaw",
			"LeftRearPaw", "RightRearPaw", "TailRoot", "TailPlume", "TailTip",
		},
		effects = {
			{name = "VioletSparkles", className = "ParticleEmitter", position = Vector3.new(0, 0.25, 0)},
			{name = "FrostSpecks", className = "ParticleEmitter", position = Vector3.new(0, 0.45, 0)},
			{name = "EpicAuraLight", className = "PointLight", position = Vector3.new(0, 0.15, 0)},
		},
	},
	StormOwl = {
		petName = "Storm Owl", rarity = "Epic", baseRate = 50, meshCount = 36,
		boundsMin = Vector3.new(4.0, 3.5, 1.8), boundsMax = Vector3.new(4.4, 4.0, 2.2),
		meshNames = {
			"Body", "Head", "LeftEyeDisc", "RightEyeDisc", "LeftEye", "RightEye", "LeftEyeHighlight", "RightEyeHighlight",
			"Beak", "ChestUpper", "ChestLeft", "ChestRight", "ChestLower", "LeftWingBase", "LeftWingUpper",
			"LeftWingMiddle", "LeftWingLower", "LeftWingTip", "RightWingBase", "RightWingUpper", "RightWingMiddle",
			"RightWingLower", "RightWingTip", "LeftLeg", "RightLeg", "LeftFoot", "RightFoot", "LeftTalon1",
			"LeftTalon2", "LeftTalon3", "RightTalon1", "RightTalon2", "RightTalon3", "TailLeft", "TailCenter", "TailRight",
		},
		effects = {
			{name = "VioletSparkles", className = "ParticleEmitter", position = Vector3.new(0, 0.25, 0)},
			{name = "EpicAuraLight", className = "PointLight", position = Vector3.new(0, 0.15, 0)},
		},
	},
	AuraDragon = {
		petName = "Aura Dragon", rarity = "Legendary", baseRate = 100, meshCount = 46,
		boundsMin = Vector3.new(3.2, 5.0, 1.1), boundsMax = Vector3.new(3.6, 5.5, 1.4),
		meshNames = {
			"Body", "TorsoArmor", "Collar", "Head", "FaceMask", "LeftEye", "RightEye", "HelmetDome", "HelmetBand",
			"HelmetCrest", "LeftHelmetPillar", "RightHelmetPillar", "LeftHelmetRune", "RightHelmetRune", "LeftShoulder",
			"RightShoulder", "LeftArm", "RightArm", "LeftCuff", "RightCuff", "LeftHand", "RightHand", "LeftLeg", "RightLeg",
			"LeftBoot", "RightBoot", "LeftCoatPanel", "RightCoatPanel", "Belt", "ChestRune", "LeftSleeveRune", "RightSleeveRune",
			"LeftLegRune", "RightLegRune", "StaffShaft", "StaffLowerGrip", "StaffUpperGrip", "StaffCrown", "StaffLeftProng",
			"StaffRightProng", "StaffLeftClaw", "StaffRightClaw", "StaffFlameCore", "StaffFlameLeft", "StaffFlameRight", "StaffTip",
		},
		effects = {
			{name = "GoldShimmer", className = "ParticleEmitter", position = Vector3.new(0, 0.25, 0)},
			{name = "CyanSoulfire", className = "ParticleEmitter", position = Vector3.new(0, 0.55, 0)},
			{name = "LegendaryAuraLight", className = "PointLight", position = Vector3.new(0, 0.3, 0)},
		},
	},
}

local selected = Selection:Get()
assert(#selected == 1, "Select exactly one imported v3 pet Model in Workspace.")

local candidate = selected[1]
assert(candidate:IsA("Model"), "The selected import must be a Model.")
assert(candidate:IsDescendantOf(workspace), "The candidate must be in Workspace during configuration.")
assert(not candidate:IsDescendantOf(ServerStorage), "Refusing to modify a ServerStorage model.")

local runtimeRoot = workspace:FindFirstChild("AuralitPetRuntime")
assert(not runtimeRoot or not candidate:IsDescendantOf(runtimeRoot), "Refusing to modify a live runtime pet.")

local petId = candidate.Name
if string.sub(petId, -13) == "_v3_Candidate" then
	petId = string.sub(petId, 1, -14)
end
local spec = specs[petId]
assert(spec, string.format("Unsupported or incorrectly named imported Model %s.", candidate.Name))

local expectedMeshNames = {}
for _, meshName in spec.meshNames do
	assert(not expectedMeshNames[meshName], string.format("Duplicate configured mesh name %s.", meshName))
	expectedMeshNames[meshName] = true
end
assert(#spec.meshNames == spec.meshCount, "Configured mesh-name count does not match the exact contract.")

local expectedVfxClasses = {}
for _, effectSpec in spec.effects do
	expectedVfxClasses[effectSpec.name .. "Attachment"] = "Attachment"
	expectedVfxClasses[effectSpec.name] = effectSpec.className
end

local meshParts = {}
local meshByName = {}
for _, descendant in candidate:GetDescendants() do
	assert(not descendant:IsA("LuaSourceContainer"), "Imported candidates may not contain scripts.")
	if descendant:IsA("BasePart") then
		assert(descendant:IsA("MeshPart"), string.format("%s must be a MeshPart.", descendant:GetFullName()))
		assert(expectedMeshNames[descendant.Name], string.format("Unexpected MeshPart %s.", descendant.Name))
		assert(not meshByName[descendant.Name], string.format("Duplicate MeshPart %s.", descendant.Name))
		meshByName[descendant.Name] = descendant
		table.insert(meshParts, descendant)
	elseif descendant:IsA("Attachment") or descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
		assert(expectedVfxClasses[descendant.Name] == descendant.ClassName,
			string.format("Unexpected VFX descendant %s (%s).", descendant.Name, descendant.ClassName))
	else
		error(string.format("Unexpected descendant %s (%s).", descendant:GetFullName(), descendant.ClassName))
	end
end

assert(#meshParts == spec.meshCount, string.format("Expected %d MeshParts; found %d.", spec.meshCount, #meshParts))
for expectedName in expectedMeshNames do
	assert(meshByName[expectedName], string.format("Missing required MeshPart %s.", expectedName))
end

local body = meshByName.Body
assert(body.Parent == candidate, "Body must be the direct root MeshPart of the imported Model.")
for _, meshPart in meshParts do
	if meshPart ~= body then
		assert(meshPart:IsDescendantOf(body), string.format("%s must be parented beneath Body.", meshPart.Name))
	end
end

local _, importedBounds = candidate:GetBoundingBox()
local boundsChecks = {
	{axis = "X", value = importedBounds.X, minimum = spec.boundsMin.X, maximum = spec.boundsMax.X},
	{axis = "Y", value = importedBounds.Y, minimum = spec.boundsMin.Y, maximum = spec.boundsMax.Y},
	{axis = "Z", value = importedBounds.Z, minimum = spec.boundsMin.Z, maximum = spec.boundsMax.Z},
}
for _, check in boundsChecks do
	assert(check.value == check.value and check.value > 0 and check.value < math.huge,
		string.format("Imported %s bound must be finite.", check.axis))
	assert(check.value >= check.minimum and check.value <= check.maximum,
		string.format("Imported %s bound %.3f is outside the approved range.", check.axis, check.value))
end

local function findUniqueDescendant(name, className)
	local found = nil
	for _, descendant in candidate:GetDescendants() do
		if descendant.Name == name then
			assert(descendant:IsA(className), string.format("%s must be a %s.", name, className))
			assert(not found, string.format("Duplicate descendant named %s.", name))
			found = descendant
		end
	end
	return found
end

local function getOrCreateAttachment(effectSpec)
	local name = effectSpec.name .. "Attachment"
	local attachment = findUniqueDescendant(name, "Attachment")
	if attachment then
		assert(attachment.Parent == body, string.format("%s must be parented to Body.", name))
	else
		attachment = Instance.new("Attachment")
		attachment.Name = name
		attachment.Parent = body
	end
	attachment.Position = effectSpec.position
	return attachment
end

local function getOrCreateEffect(effectSpec, attachment)
	local effect = findUniqueDescendant(effectSpec.name, effectSpec.className)
	if effect then
		assert(effect.Parent == attachment, string.format("%s must use %s.", effectSpec.name, attachment.Name))
	else
		effect = Instance.new(effectSpec.className)
		effect.Name = effectSpec.name
		effect.Parent = attachment
	end
	return effect
end

local function configureParticleDefaults(emitter)
	emitter.Enabled = true
	emitter.Lifetime = NumberRange.new(1.0, 1.6)
	emitter.Speed = NumberRange.new(0.08, 0.22)
	emitter.Acceleration = Vector3.new(0, 0.1, 0)
	emitter.Drag = 1.5
	emitter.SpreadAngle = Vector2.new(32, 32)
	emitter.LightInfluence = 0
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-14, 14)
	emitter.LockedToPart = false
	emitter.ZOffset = 0
end

local function configureEffect(effectSpec, effect)
	if effect:IsA("PointLight") then
		effect.Enabled = true
		effect.Brightness = if effectSpec.name == "LegendaryAuraLight" then 0.55 else 0.35
		effect.Range = if effectSpec.name == "LegendaryAuraLight" then 5.5 else 4.5
		effect.Color = if effectSpec.name == "LegendaryAuraLight"
			then Color3.fromRGB(50, 235, 225)
			else Color3.fromRGB(155, 105, 255)
		effect.Shadows = false
		return
	end

	configureParticleDefaults(effect)
	if effectSpec.name == "SilverDust" then
		effect.Rate = 8
		effect.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.022),
			NumberSequenceKeypoint.new(0.65, 0.042),
			NumberSequenceKeypoint.new(1, 0.008),
		})
		effect.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.76),
			NumberSequenceKeypoint.new(0.75, 0.88),
			NumberSequenceKeypoint.new(1, 1),
		})
		effect.Color = ColorSequence.new(Color3.fromRGB(225, 235, 240), Color3.fromRGB(255, 255, 255))
		effect.LightEmission = 0.25
	elseif effectSpec.name == "VioletSparkles" then
		effect.Rate = 4
		effect.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.025),
			NumberSequenceKeypoint.new(0.7, 0.055),
			NumberSequenceKeypoint.new(1, 0.01),
		})
		effect.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.62),
			NumberSequenceKeypoint.new(0.75, 0.78),
			NumberSequenceKeypoint.new(1, 1),
		})
		effect.Color = ColorSequence.new(Color3.fromRGB(145, 95, 235), Color3.fromRGB(210, 180, 255))
		effect.LightEmission = 0.45
	elseif effectSpec.name == "FrostSpecks" then
		effect.Rate = 6
		effect.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.02), NumberSequenceKeypoint.new(1, 0.008),
		})
		effect.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.58), NumberSequenceKeypoint.new(1, 1),
		})
		effect.Color = ColorSequence.new(Color3.fromRGB(190, 245, 255), Color3.fromRGB(255, 255, 255))
		effect.LightEmission = 0.55
	elseif effectSpec.name == "GoldShimmer" then
		effect.Rate = 4
		effect.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.025), NumberSequenceKeypoint.new(1, 0.008),
		})
		effect.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.64), NumberSequenceKeypoint.new(1, 1),
		})
		effect.Color = ColorSequence.new(Color3.fromRGB(255, 205, 80), Color3.fromRGB(255, 240, 170))
		effect.LightEmission = 0.55
	elseif effectSpec.name == "CyanSoulfire" then
		effect.Rate = 5
		effect.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.045),
			NumberSequenceKeypoint.new(0.65, 0.11),
			NumberSequenceKeypoint.new(1, 0.015),
		})
		effect.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.66),
			NumberSequenceKeypoint.new(0.75, 0.82),
			NumberSequenceKeypoint.new(1, 1),
		})
		effect.Color = ColorSequence.new(Color3.fromRGB(20, 235, 225), Color3.fromRGB(145, 255, 250))
		effect.LightEmission = 0.65
	else
		error(string.format("No approved VFX configuration for %s.", effectSpec.name))
	end
end

-- Geometry CFrames, sizes, mesh IDs, and materials are intentionally untouched.
candidate.Name = petId .. "_v3_Candidate"
candidate.PrimaryPart = body
candidate:SetAttribute("PetId", petId)
candidate:SetAttribute("PetName", spec.petName)
candidate:SetAttribute("Rarity", spec.rarity)
candidate:SetAttribute("BaseRate", spec.baseRate)
candidate:SetAttribute("ModelVersion", "3.0.0")
candidate:SetAttribute("ForwardAxis", "-Z")
candidate:SetAttribute("Placeholder", false)

for _, meshPart in meshParts do
	meshPart.Anchored = true
	meshPart.CanCollide = false
	meshPart.CanTouch = false
	meshPart.CanQuery = false
	meshPart.Massless = true
end
body.RootPriority = 127

local particleRate = 0
for _, effectSpec in spec.effects do
	local attachment = getOrCreateAttachment(effectSpec)
	local effect = getOrCreateEffect(effectSpec, attachment)
	configureEffect(effectSpec, effect)
	if effect:IsA("ParticleEmitter") then
		particleRate += effect.Rate
	end
end

local maxParticleRate = if spec.rarity == "Common" then 8 elseif spec.rarity == "Epic" then 10 else 9
assert(particleRate <= maxParticleRate, "Configured particle rate is not restrained.")
assert(candidate.PrimaryPart == body, "PrimaryPart configuration failed.")
assert(candidate:GetAttribute("PetId") == petId, "PetId metadata configuration failed.")
assert(candidate:GetAttribute("PetName") == spec.petName, "PetName metadata configuration failed.")
assert(candidate:GetAttribute("Rarity") == spec.rarity, "Rarity metadata configuration failed.")
assert(candidate:GetAttribute("BaseRate") == spec.baseRate, "BaseRate metadata configuration failed.")
assert(candidate:GetAttribute("ModelVersion") == "3.0.0", "ModelVersion metadata configuration failed.")
assert(candidate:GetAttribute("ForwardAxis") == "-Z", "ForwardAxis metadata configuration failed.")
assert(candidate:GetAttribute("Placeholder") == false, "Placeholder metadata configuration failed.")

for _, meshPart in meshParts do
	assert(meshPart.Anchored, string.format("%s must be anchored.", meshPart.Name))
	assert(not meshPart.CanCollide, string.format("%s must not collide.", meshPart.Name))
	assert(not meshPart.CanTouch, string.format("%s must not generate touch events.", meshPart.Name))
	assert(not meshPart.CanQuery, string.format("%s must not participate in spatial queries.", meshPart.Name))
	assert(meshPart.Massless, string.format("%s must be massless.", meshPart.Name))
end

for expectedName, className in expectedVfxClasses do
	local descendant = findUniqueDescendant(expectedName, className)
	assert(descendant, string.format("Missing configured VFX descendant %s.", expectedName))
	if descendant:IsA("Attachment") then
		assert(descendant.Parent == body, string.format("%s must be parented to Body.", expectedName))
	end
end

local _, finalBounds = candidate:GetBoundingBox()
assert((finalBounds - importedBounds).Magnitude < 0.001, "Configuration unexpectedly changed model bounds.")

Selection:Set({candidate})
print(string.format(
	"[%s] Configured %s: %d MeshParts, bounds %.3f x %.3f x %.3f, PrimaryPart Body.",
	petId,
	candidate:GetFullName(),
	#meshParts,
	finalBounds.X,
	finalBounds.Y,
	finalBounds.Z
))
print(string.format("[%s] Added restrained Roblox-side VFX. No ServerStorage model was replaced.", petId))
