-- FrostBunny v3 safe post-import helper.
-- Run from the Roblox Studio Command Bar with exactly one imported Workspace
-- Model selected. This script never deletes, moves, or replaces ServerStorage
-- content; the configured result remains a clearly named review candidate.

local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")

local PET_ID = "FrostBunny"
local CANDIDATE_NAME = "FrostBunny_v3_Candidate"

local expectedMeshNames = {
	Body = true,
	Head = true,
	LeftEar = true,
	RightEar = true,
	LeftInnerEar = true,
	RightInnerEar = true,
	LeftEye = true,
	RightEye = true,
	LeftEyeHighlight = true,
	RightEyeHighlight = true,
	Nose = true,
	LeftMuzzle = true,
	RightMuzzle = true,
	LeftCheek = true,
	RightCheek = true,
	Mouth = true,
	LeftArm = true,
	RightArm = true,
	LeftLeg = true,
	RightLeg = true,
	LeftFoot = true,
	RightFoot = true,
	LeftPawPad = true,
	RightPawPad = true,
	LeftToePad1 = true,
	LeftToePad2 = true,
	LeftToePad3 = true,
	RightToePad1 = true,
	RightToePad2 = true,
	RightToePad3 = true,
	Tail = true,
}

local studioNameAliases = {
	LeftEyeShine = "LeftEyeHighlight",
	RightEyeShine = "RightEyeHighlight",
	LeftFootPad = "LeftPawPad",
	RightFootPad = "RightPawPad",
}

for studioName, canonicalName in studioNameAliases do
	assert(not expectedMeshNames[studioName], string.format("Studio alias %s conflicts with a canonical name.", studioName))
	assert(expectedMeshNames[canonicalName], string.format("Studio alias %s has an unknown canonical target.", studioName))
end

local selected = Selection:Get()
assert(#selected == 1, "Select exactly one imported FrostBunny Model in Workspace.")

local candidate = selected[1]
assert(candidate:IsA("Model"), "The selected FrostBunny import must be a Model.")
assert(candidate:IsDescendantOf(workspace), "The candidate must be in Workspace during configuration.")
assert(not candidate:IsDescendantOf(ServerStorage), "Refusing to modify a ServerStorage model.")

local runtimeRoot = workspace:FindFirstChild("AuralitPetRuntime")
assert(not runtimeRoot or not candidate:IsDescendantOf(runtimeRoot), "Refusing to modify a live runtime pet.")

local meshParts = {}
local meshByName = {}
for _, descendant in candidate:GetDescendants() do
	assert(not descendant:IsA("LuaSourceContainer"), "Imported candidates may not contain scripts.")
	if descendant:IsA("BasePart") then
		assert(descendant:IsA("MeshPart"), string.format("%s must be a MeshPart.", descendant:GetFullName()))
		local canonicalName = studioNameAliases[descendant.Name] or descendant.Name
		assert(expectedMeshNames[canonicalName], string.format("Unexpected MeshPart %s.", descendant.Name))
		assert(not meshByName[canonicalName], string.format("Duplicate canonical MeshPart %s.", canonicalName))
		meshByName[canonicalName] = descendant
		table.insert(meshParts, descendant)
	end
end

assert(#meshParts == 31, string.format("Expected 31 FrostBunny MeshParts; found %d.", #meshParts))
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

local _, importedBoundsSize = candidate:GetBoundingBox()
assert(importedBoundsSize.X >= 2.3 and importedBoundsSize.X <= 2.9, "Imported width does not match the approved FrostBunny candidate.")
assert(importedBoundsSize.Y >= 4.0 and importedBoundsSize.Y <= 4.6, "Imported height does not match the approved FrostBunny candidate.")
assert(importedBoundsSize.Z >= 1.8 and importedBoundsSize.Z <= 2.25, "Imported depth does not match the approved FrostBunny candidate.")

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

local function getOrCreateAttachment(name, position)
	local attachment = findUniqueDescendant(name, "Attachment")
	if attachment then
		assert(attachment.Parent == body, string.format("%s must be parented to Body.", name))
	else
		attachment = Instance.new("Attachment")
		attachment.Name = name
		attachment.Parent = body
	end
	attachment.Position = position
	return attachment
end

local function getOrCreateEmitter(name, attachment)
	local emitter = findUniqueDescendant(name, "ParticleEmitter")
	if emitter then
		assert(emitter.Parent == attachment, string.format("%s must use %s.", name, attachment.Name))
	else
		emitter = Instance.new("ParticleEmitter")
		emitter.Name = name
		emitter.Parent = attachment
	end
	return emitter
end

local function configureCyanMist(attachment)
	local emitter = getOrCreateEmitter("CyanMist", attachment)
	emitter.Enabled = true
	emitter.Rate = 4
	emitter.Lifetime = NumberRange.new(1.2, 1.8)
	emitter.Speed = NumberRange.new(0.08, 0.2)
	emitter.Acceleration = Vector3.new(0, 0.1, 0)
	emitter.Drag = 1.5
	emitter.SpreadAngle = Vector2.new(32, 32)
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.08),
		NumberSequenceKeypoint.new(0.65, 0.18),
		NumberSequenceKeypoint.new(1, 0.04),
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.82),
		NumberSequenceKeypoint.new(0.75, 0.9),
		NumberSequenceKeypoint.new(1, 1),
	})
	emitter.Color = ColorSequence.new(
		Color3.fromRGB(160, 232, 255),
		Color3.fromRGB(225, 250, 255)
	)
	emitter.LightEmission = 0.45
	emitter.LightInfluence = 0
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-12, 12)
	emitter.LockedToPart = false
	emitter.ZOffset = 0
	return emitter
end

local function configureSnowSpecks(attachment)
	local emitter = getOrCreateEmitter("SnowSpecks", attachment)
	emitter.Enabled = true
	emitter.Rate = 6
	emitter.Lifetime = NumberRange.new(0.9, 1.4)
	emitter.Speed = NumberRange.new(0.18, 0.4)
	emitter.Acceleration = Vector3.new(0, 0.12, 0)
	emitter.Drag = 1
	emitter.SpreadAngle = Vector2.new(38, 38)
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.025),
		NumberSequenceKeypoint.new(0.7, 0.045),
		NumberSequenceKeypoint.new(1, 0.01),
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.42),
		NumberSequenceKeypoint.new(0.75, 0.68),
		NumberSequenceKeypoint.new(1, 1),
	})
	emitter.Color = ColorSequence.new(
		Color3.fromRGB(215, 245, 255),
		Color3.fromRGB(255, 255, 255)
	)
	emitter.LightEmission = 0.8
	emitter.LightInfluence = 0
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-20, 20)
	emitter.LockedToPart = false
	emitter.ZOffset = 0.02
	return emitter
end

-- Geometry transforms and sizes are intentionally left untouched so the
-- Director-approved silhouette remains identical to the imported GLB.
candidate.Name = CANDIDATE_NAME
candidate.PrimaryPart = body
candidate:SetAttribute("PetId", PET_ID)
candidate:SetAttribute("PetName", "Frost Bunny")
candidate:SetAttribute("Rarity", "Rare")
candidate:SetAttribute("BaseRate", 25)
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

local cyanMistAttachment = getOrCreateAttachment("CyanMistAttachment", Vector3.new(0, 0, 0))
local snowHeight = math.clamp(body.Size.Y * 0.2, 0.15, 0.45)
local snowSpecksAttachment = getOrCreateAttachment(
	"SnowSpecksAttachment",
	Vector3.new(0, snowHeight, 0)
)
local cyanMist = configureCyanMist(cyanMistAttachment)
local snowSpecks = configureSnowSpecks(snowSpecksAttachment)

assert(candidate.PrimaryPart == body, "PrimaryPart configuration failed.")
assert(candidate:GetAttribute("PetId") == PET_ID, "PetId metadata configuration failed.")
assert(candidate:GetAttribute("PetName") == "Frost Bunny", "PetName metadata configuration failed.")
assert(candidate:GetAttribute("Rarity") == "Rare", "Rarity metadata configuration failed.")
assert(candidate:GetAttribute("BaseRate") == 25, "BaseRate metadata configuration failed.")
assert(candidate:GetAttribute("ModelVersion") == "3.0.0", "ModelVersion metadata configuration failed.")
assert(candidate:GetAttribute("ForwardAxis") == "-Z", "ForwardAxis metadata configuration failed.")
assert(candidate:GetAttribute("Placeholder") == false, "Placeholder metadata configuration failed.")
assert(cyanMist.Rate + snowSpecks.Rate <= 12, "FrostBunny particle rate is not restrained.")

for _, meshPart in meshParts do
	assert(meshPart.Anchored, string.format("%s must be anchored for runtime following.", meshPart.Name))
	assert(not meshPart.CanCollide, string.format("%s must not collide.", meshPart.Name))
	assert(not meshPart.CanTouch, string.format("%s must not generate touch events.", meshPart.Name))
	assert(not meshPart.CanQuery, string.format("%s must not participate in spatial queries.", meshPart.Name))
	assert(meshPart.Massless, string.format("%s must be massless.", meshPart.Name))
end

local _, boundsSize = candidate:GetBoundingBox()
for _, value in {boundsSize.X, boundsSize.Y, boundsSize.Z} do
	assert(value == value and value > 0 and value < math.huge, "Candidate bounds must be positive and finite.")
end

Selection:Set({candidate})
print(string.format(
	"[FrostBunny] Configured %s: %d MeshParts, bounds %.3f x %.3f x %.3f, PrimaryPart Body.",
	candidate:GetFullName(),
	#meshParts,
	boundsSize.X,
	boundsSize.Y,
	boundsSize.Z
))
print("[FrostBunny] Added restrained CyanMist and SnowSpecks. No ServerStorage model was replaced.")
