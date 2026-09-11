-- Universal safe post-import configuration for all six Auralit v3 mesh candidates.
-- Paste into the Roblox Studio Command Bar with exactly one imported Workspace Model selected.
-- This helper never deletes, moves, or replaces anything in ServerStorage.
-- Raw MeshPart names must be canonical (or an explicit alias) with only an optional _Mesh, _Node, or _Node_Mesh suffix.

local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")

local PET_CONTRACTS = {
	FrostBunny = {
		petId = "FrostBunny", petName = "Frost Bunny", rarity = "Rare", baseRate = 25,
		modelVersion = "3.0.0", forwardAxis = "-Z", meshCount = 31,
		boundsMin = Vector3.new(2.3, 4.0, 1.8), boundsMax = Vector3.new(2.9, 4.6, 2.25),
		meshNames = {
			"Body", "Head", "LeftEar", "RightEar", "LeftInnerEar", "RightInnerEar", "LeftEye", "RightEye",
			"LeftEyeHighlight", "RightEyeHighlight", "Nose", "LeftMuzzle", "RightMuzzle", "LeftCheek", "RightCheek",
			"Mouth", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "LeftFoot", "RightFoot", "LeftPawPad", "RightPawPad",
			"LeftToePad1", "LeftToePad2", "LeftToePad3", "RightToePad1", "RightToePad2", "RightToePad3", "Tail",
		},
		aliases = {
			LeftEyeShine = "LeftEyeHighlight", RightEyeShine = "RightEyeHighlight",
			LeftFootPad = "LeftPawPad", RightFootPad = "RightPawPad",
		},
		effects = {
			{name = "CyanMist", className = "ParticleEmitter", position = Vector3.new(0, 0, 0)},
			{name = "SnowSpecks", className = "ParticleEmitter", position = Vector3.new(0, 0.35, 0)},
		},
	},
	ChibiCat = {
		petId = "ChibiCat", petName = "Chibi Cat", rarity = "Common", baseRate = 10,
		modelVersion = "3.0.0", forwardAxis = "-Z", meshCount = 31,
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
		petId = "FluffDog", petName = "Fluff Dog", rarity = "Common", baseRate = 10,
		modelVersion = "3.0.0", forwardAxis = "-Z", meshCount = 31,
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
		petId = "FrostFox", petName = "Frost Fox", rarity = "Epic", baseRate = 50,
		modelVersion = "3.0.0", forwardAxis = "-Z", meshCount = 31,
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
		petId = "StormOwl", petName = "Storm Owl", rarity = "Epic", baseRate = 50,
		modelVersion = "3.0.0", forwardAxis = "-Z", meshCount = 36,
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
		petId = "AuraDragon", petName = "Aura Dragon", rarity = "Legendary", baseRate = 100,
		modelVersion = "3.0.0", forwardAxis = "-Z", meshCount = 46,
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

local IMPORT_SUFFIXES = {"_Node_Mesh", "_Mesh", "_Node", ""}
local DIAGNOSTIC_ORDER = {
	{"General", "general"},
	{"Unknown MeshParts", "unknownMeshParts"},
	{"Missing canonical components", "missingComponents"},
	{"Duplicate canonical components", "duplicateComponents"},
	{"Wrong classes", "wrongClasses"},
	{"Hierarchy problems", "hierarchy"},
	{"Transform problems", "transforms"},
	{"Unexpected objects", "unexpectedObjects"},
}

local function addProblem(problems, category, message)
	table.insert(problems[category], message)
end

local function problemCount(problems)
	local count = 0
	for _, entry in DIAGNOSTIC_ORDER do
		count += #problems[entry[2]]
	end
	return count
end

local function reportFailure(petId, problems, boundsStatus, rootStatus)
	local lines = {
		"[Auralit Pet Import Validation FAILED]",
		"Pet: " .. (petId or "UNIDENTIFIED"),
	}
	for _, entry in DIAGNOSTIC_ORDER do
		local heading, key = entry[1], entry[2]
		if #problems[key] > 0 then
			table.sort(problems[key])
			table.insert(lines, "")
			table.insert(lines, heading .. ":")
			for _, message in problems[key] do
				table.insert(lines, "- " .. message)
			end
		end
	end
	table.insert(lines, "")
	table.insert(lines, "Bounds: " .. boundsStatus)
	table.insert(lines, "Root: " .. rootStatus)
	table.insert(lines, "No changes were made.")
	warn(table.concat(lines, "\n"))
end

local function newProblems()
	local problems = {}
	for _, entry in DIAGNOSTIC_ORDER do
		problems[entry[2]] = {}
	end
	return problems
end

local function identifyPetId(name)
	if PET_CONTRACTS[name] then
		return name
	end
	for configuredPetId in PET_CONTRACTS do
		if name == configuredPetId .. "_v3_Candidate" then
			return configuredPetId
		end
	end
	return nil
end

local problems = newProblems()
local boundsStatus = "NOT CHECKED"
local rootStatus = "NOT CHECKED"
local selected = Selection:Get()
if #selected ~= 1 then
	addProblem(problems, "general", string.format("Select exactly one imported Model in Workspace; found %d selections.", #selected))
	reportFailure(nil, problems, boundsStatus, rootStatus)
	return
end

local candidate = selected[1]
if not candidate:IsA("Model") then
	addProblem(problems, "wrongClasses", string.format("Selected %s is %s; expected Model.", candidate.Name, candidate.ClassName))
	reportFailure(nil, problems, boundsStatus, rootStatus)
	return
end
if not candidate:IsDescendantOf(workspace) then
	addProblem(problems, "general", "Selected Model must be inside Workspace during configuration.")
end
if candidate:IsDescendantOf(ServerStorage) then
	addProblem(problems, "general", "Selected Model is inside ServerStorage; production models are read-only to this helper.")
end

local runtimeRoot = workspace:FindFirstChild("AuralitPetRuntime")
if runtimeRoot and candidate:IsDescendantOf(runtimeRoot) then
	addProblem(problems, "general", "Selected Model is a live AuralitPetRuntime clone.")
end

local petId = identifyPetId(candidate.Name)
local spec = if petId then PET_CONTRACTS[petId] else nil
if not spec then
	addProblem(problems, "general", string.format("Model name %s does not exactly identify one of the six v3 pets.", candidate.Name))
	reportFailure(nil, problems, boundsStatus, rootStatus)
	return
end
if spec.petId ~= petId or spec.modelVersion ~= "3.0.0" or spec.forwardAxis ~= "-Z" then
	addProblem(problems, "general", "Selected pet contract has invalid identity, version, or forward-axis metadata.")
end

local expectedMeshNames = {}
for _, meshName in spec.meshNames do
	if expectedMeshNames[meshName] then
		addProblem(problems, "general", string.format("Contract repeats canonical MeshPart %s.", meshName))
	end
	expectedMeshNames[meshName] = true
end
if #spec.meshNames ~= spec.meshCount then
	addProblem(problems, "general", "Contract mesh-name count does not match its exact MeshPart count.")
end

for alias, canonicalName in spec.aliases or {} do
	if expectedMeshNames[alias] then
		addProblem(problems, "general", string.format("Alias %s conflicts with a canonical MeshPart name.", alias))
	end
	if not expectedMeshNames[canonicalName] then
		addProblem(problems, "general", string.format("Alias %s targets unknown canonical name %s.", alias, canonicalName))
	end
end

local function normalizeMeshName(rawName)
	for _, suffix in IMPORT_SUFFIXES do
		local suffixMatches = suffix == "" or (#rawName > #suffix and string.sub(rawName, -#suffix) == suffix)
		if suffixMatches then
			local baseName = if suffix == "" then rawName else string.sub(rawName, 1, #rawName - #suffix)
			local canonicalName = (spec.aliases and spec.aliases[baseName]) or baseName
			if expectedMeshNames[canonicalName] then
				return canonicalName
			end
		end
	end
	return nil
end

local expectedVfxClasses = {}
for _, effectSpec in spec.effects do
	expectedVfxClasses[effectSpec.name .. "Attachment"] = "Attachment"
	expectedVfxClasses[effectSpec.name] = effectSpec.className
end

local function isFiniteNumber(value)
	return value == value and math.abs(value) < math.huge
end

local function hasFiniteCFrame(instance)
	for _, value in {instance.CFrame:GetComponents()} do
		if not isFiniteNumber(value) then
			return false
		end
	end
	return true
end

local function hasFinitePositiveSize(part)
	return isFiniteNumber(part.Size.X) and part.Size.X > 0
		and isFiniteNumber(part.Size.Y) and part.Size.Y > 0
		and isFiniteNumber(part.Size.Z) and part.Size.Z > 0
end

local meshParts = {}
local meshByName = {}
local canonicalByMeshPart = {}
local rawNamesByCanonical = {}
local existingVfxByName = {}
for _, descendant in candidate:GetDescendants() do
	if descendant:IsA("LuaSourceContainer") then
		addProblem(problems, "wrongClasses", string.format("Script %s is forbidden.", descendant:GetFullName()))
	elseif descendant:IsA("BasePart") then
		if not hasFiniteCFrame(descendant) or not hasFinitePositiveSize(descendant) then
			addProblem(problems, "transforms", string.format("%s has a non-finite transform or invalid size.", descendant:GetFullName()))
		end
		if not descendant:IsA("MeshPart") then
			addProblem(problems, "wrongClasses", string.format("%s is %s; character geometry must be MeshPart.", descendant:GetFullName(), descendant.ClassName))
		else
			table.insert(meshParts, descendant)
			if descendant.MeshId == "" then
				addProblem(problems, "general", string.format("MeshPart %s has an empty MeshId.", descendant.Name))
			end
			local canonicalName = normalizeMeshName(descendant.Name)
			if not canonicalName then
				addProblem(problems, "unknownMeshParts", descendant.Name)
			else
				canonicalByMeshPart[descendant] = canonicalName
				rawNamesByCanonical[canonicalName] = rawNamesByCanonical[canonicalName] or {}
				table.insert(rawNamesByCanonical[canonicalName], descendant.Name)
				meshByName[canonicalName] = meshByName[canonicalName] or descendant
			end
		end
	elseif descendant:IsA("Attachment") or descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
		local expectedClass = expectedVfxClasses[descendant.Name]
		if not expectedClass then
			addProblem(problems, "unexpectedObjects", string.format("%s (%s)", descendant:GetFullName(), descendant.ClassName))
		elseif expectedClass ~= descendant.ClassName then
			addProblem(problems, "wrongClasses", string.format("%s is %s; expected %s.", descendant:GetFullName(), descendant.ClassName, expectedClass))
		elseif existingVfxByName[descendant.Name] then
			addProblem(problems, "duplicateComponents", string.format("VFX %s appears more than once.", descendant.Name))
		else
			existingVfxByName[descendant.Name] = descendant
			if descendant:IsA("Attachment") and not hasFiniteCFrame(descendant) then
				addProblem(problems, "transforms", string.format("Attachment %s has a non-finite transform.", descendant.Name))
			end
		end
	else
		local expectedClass = expectedVfxClasses[descendant.Name]
		if expectedClass then
			addProblem(problems, "wrongClasses", string.format("%s is %s; expected %s.", descendant:GetFullName(), descendant.ClassName, expectedClass))
		else
			addProblem(problems, "unexpectedObjects", string.format("%s (%s)", descendant:GetFullName(), descendant.ClassName))
		end
	end
end

if #meshParts ~= spec.meshCount then
	addProblem(problems, "general", string.format("Expected exactly %d MeshParts; found %d.", spec.meshCount, #meshParts))
end
for expectedName in expectedMeshNames do
	local rawNames = rawNamesByCanonical[expectedName] or {}
	if #rawNames == 0 then
		addProblem(problems, "missingComponents", expectedName)
	elseif #rawNames > 1 then
		table.sort(rawNames)
		addProblem(problems, "duplicateComponents", string.format("%s <= %s", expectedName, table.concat(rawNames, ", ")))
	end
end

local body = meshByName.Body
local rootIsValid = body ~= nil
if not body then
	addProblem(problems, "hierarchy", "Canonical Body MeshPart is missing.")
elseif body.Parent ~= candidate then
	rootIsValid = false
	addProblem(problems, "hierarchy", string.format("Body must be a direct child of %s; parent is %s.", candidate.Name, body.Parent:GetFullName()))
end
for _, meshPart in meshParts do
	local canonicalName = canonicalByMeshPart[meshPart]
	if body and canonicalName and canonicalName ~= "Body" and meshPart.Parent ~= body then
		rootIsValid = false
		addProblem(problems, "hierarchy", string.format("%s must be a direct child of Body; parent is %s.", meshPart.Name, meshPart.Parent:GetFullName()))
	end
end
rootStatus = if rootIsValid then "PASS" else "FAIL"

for _, effectSpec in spec.effects do
	local attachmentName = effectSpec.name .. "Attachment"
	local attachment = existingVfxByName[attachmentName]
	local effect = existingVfxByName[effectSpec.name]
	if attachment and body and attachment.Parent ~= body then
		addProblem(problems, "hierarchy", string.format("%s must be parented to Body.", attachmentName))
		rootStatus = "FAIL"
	end
	if effect and attachment and effect.Parent ~= attachment then
		addProblem(problems, "hierarchy", string.format("%s must be parented to %s.", effectSpec.name, attachmentName))
		rootStatus = "FAIL"
	elseif effect and not attachment then
		addProblem(problems, "hierarchy", string.format("%s exists without %s.", effectSpec.name, attachmentName))
		rootStatus = "FAIL"
	end
end

local importedBounds = Vector3.zero
local boundsOk, _, measuredBounds = pcall(candidate.GetBoundingBox, candidate)
if not boundsOk then
	boundsStatus = "FAIL"
	addProblem(problems, "general", "Model bounds could not be measured.")
else
	importedBounds = measuredBounds
	local boundsChecks = {
		{axis = "X", value = importedBounds.X, minimum = spec.boundsMin.X, maximum = spec.boundsMax.X},
		{axis = "Y", value = importedBounds.Y, minimum = spec.boundsMin.Y, maximum = spec.boundsMax.Y},
		{axis = "Z", value = importedBounds.Z, minimum = spec.boundsMin.Z, maximum = spec.boundsMax.Z},
	}
	local validBounds = true
	for _, check in boundsChecks do
		if not isFiniteNumber(check.value) or check.value <= 0 then
			validBounds = false
			addProblem(problems, "transforms", string.format("Imported %s bound is not positive and finite.", check.axis))
		elseif check.value < check.minimum or check.value > check.maximum then
			validBounds = false
			addProblem(problems, "general", string.format(
				"Imported %s bound %.3f is outside approved %.3f-%.3f.",
				check.axis, check.value, check.minimum, check.maximum
			))
		end
	end
	boundsStatus = if validBounds then string.format(
		"PASS (%.3f x %.3f x %.3f)", importedBounds.X, importedBounds.Y, importedBounds.Z
	) else "FAIL"
end

if problemCount(problems) > 0 then
	reportFailure(petId, problems, boundsStatus, rootStatus)
	return
end

-- Stage B starts here. No candidate property has been changed before this point.
local renamedMeshPartCount = 0
for _, meshPart in meshParts do
	local canonicalName = canonicalByMeshPart[meshPart]
	if meshPart.Name ~= canonicalName then
		meshPart.Name = canonicalName
		renamedMeshPartCount += 1
	end
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
	if effectSpec.name == "CyanMist" then
		effect.Rate = 4
		effect.Lifetime = NumberRange.new(1.2, 1.8)
		effect.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.08), NumberSequenceKeypoint.new(0.65, 0.18), NumberSequenceKeypoint.new(1, 0.04),
		})
		effect.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.82), NumberSequenceKeypoint.new(0.75, 0.9), NumberSequenceKeypoint.new(1, 1),
		})
		effect.Color = ColorSequence.new(Color3.fromRGB(160, 232, 255), Color3.fromRGB(225, 250, 255))
		effect.LightEmission = 0.45
	elseif effectSpec.name == "SnowSpecks" then
		effect.Rate = 6
		effect.Lifetime = NumberRange.new(0.9, 1.4)
		effect.Speed = NumberRange.new(0.18, 0.4)
		effect.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.025), NumberSequenceKeypoint.new(0.7, 0.045), NumberSequenceKeypoint.new(1, 0.01),
		})
		effect.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.42), NumberSequenceKeypoint.new(0.75, 0.68), NumberSequenceKeypoint.new(1, 1),
		})
		effect.Color = ColorSequence.new(Color3.fromRGB(215, 245, 255), Color3.fromRGB(255, 255, 255))
		effect.LightEmission = 0.8
	elseif effectSpec.name == "SilverDust" then
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
candidate:SetAttribute("PetId", spec.petId)
candidate:SetAttribute("PetName", spec.petName)
candidate:SetAttribute("Rarity", spec.rarity)
candidate:SetAttribute("BaseRate", spec.baseRate)
candidate:SetAttribute("ModelVersion", spec.modelVersion)
candidate:SetAttribute("ForwardAxis", spec.forwardAxis)
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

local maxParticleRate = if spec.rarity == "Common" then 8 elseif spec.rarity == "Rare" then 12 elseif spec.rarity == "Epic" then 10 else 9
assert(particleRate <= maxParticleRate, "Configured particle rate is not restrained.")
assert(candidate.PrimaryPart == body, "PrimaryPart configuration failed.")
assert(candidate:GetAttribute("PetId") == spec.petId, "PetId metadata configuration failed.")
assert(candidate:GetAttribute("PetName") == spec.petName, "PetName metadata configuration failed.")
assert(candidate:GetAttribute("Rarity") == spec.rarity, "Rarity metadata configuration failed.")
assert(candidate:GetAttribute("BaseRate") == spec.baseRate, "BaseRate metadata configuration failed.")
assert(candidate:GetAttribute("ModelVersion") == spec.modelVersion, "ModelVersion metadata configuration failed.")
assert(candidate:GetAttribute("ForwardAxis") == spec.forwardAxis, "ForwardAxis metadata configuration failed.")
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
print(table.concat({
	"[Auralit Pet Import Validation PASSED]",
	"Pet: " .. petId,
	string.format("MeshParts: %d/%d", #meshParts, spec.meshCount),
	string.format("Canonical names: PASS (%d deterministic importer names normalized)", renamedMeshPartCount),
	"Bounds: " .. boundsStatus,
	"Root: " .. rootStatus,
	"Metadata/physics/VFX: PASS",
	"Candidate: " .. candidate:GetFullName(),
	"No ServerStorage model was deleted, moved, or replaced.",
}, "\n"))
