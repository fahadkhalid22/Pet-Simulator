--!strict
-- BuildPetModels.server.lua
-- Automatically builds the 6 placeholder pet models in ServerStorage/PetModels
-- Tagged as Placeholders until final meshes are imported.

local ServerStorage = game:GetService('ServerStorage')

local petModelsFolder = ServerStorage:FindFirstChild('PetModels')
if not petModelsFolder then
	petModelsFolder = Instance.new('Folder')
	petModelsFolder.Name = 'PetModels'
	petModelsFolder.Parent = ServerStorage
end

local PET_DEFINITIONS = {
	{
		Id = 'FluffDog',
		Name = 'Fluff Dog',
		Rarity = 'Common',
		BaseRate = 10,
		PrimaryColor = Color3.fromRGB(60, 60, 65),     -- Charcoal slate
		SecondaryColor = Color3.fromRGB(245, 245, 245), -- White chest/face
		AccentColor = Color3.fromRGB(210, 150, 75),     -- Caramel tan
		EyeColor = Color3.fromRGB(30, 20, 15),
		AuraColor = Color3.fromRGB(230, 230, 230),      -- Soft white glow
		HeadSize = Vector3.new(1.8, 1.6, 1.8),
		BodySize = Vector3.new(1.4, 1.4, 1.6),
		EarType = 'Floppy',
	},
	{
		Id = 'ChibiCat',
		Name = 'Chibi Cat',
		Rarity = 'Common',
		BaseRate = 10,
		PrimaryColor = Color3.fromRGB(45, 45, 48),      -- Dark espresso
		SecondaryColor = Color3.fromRGB(250, 250, 250), -- White blaze
		AccentColor = Color3.fromRGB(255, 180, 190),    -- Pink inner ears
		EyeColor = Color3.fromRGB(120, 210, 60),        -- Lime green
		AuraColor = Color3.fromRGB(230, 230, 230),      -- Soft white glow
		HeadSize = Vector3.new(1.8, 1.5, 1.7),
		BodySize = Vector3.new(1.3, 1.3, 1.5),
		EarType = 'Pointy',
	},
	{
		Id = 'FrostBunny',
		Name = 'Frost Bunny',
		Rarity = 'Rare',
		BaseRate = 25,
		PrimaryColor = Color3.fromRGB(250, 250, 255),   -- Pure soft white
		SecondaryColor = Color3.fromRGB(255, 190, 200), -- Pink inner ear & nose
		AccentColor = Color3.fromRGB(200, 230, 255),    -- Ice tint
		EyeColor = Color3.fromRGB(20, 20, 25),
		AuraColor = Color3.fromRGB(58, 134, 255),       -- Cyan frost glow
		HeadSize = Vector3.new(1.6, 1.5, 1.6),
		BodySize = Vector3.new(1.2, 1.6, 1.2),
		EarType = 'BunnyEars',
	},
	{
		Id = 'StormOwl',
		Name = 'Storm Owl',
		Rarity = 'Epic',
		BaseRate = 50,
		PrimaryColor = Color3.fromRGB(240, 240, 245),   -- White plumage
		SecondaryColor = Color3.fromRGB(110, 115, 125), -- Grey wings
		AccentColor = Color3.fromRGB(245, 160, 30),     -- Amber beak
		EyeColor = Color3.fromRGB(20, 20, 30),
		AuraColor = Color3.fromRGB(131, 56, 236),       -- Royal purple sparkle
		HeadSize = Vector3.new(1.7, 1.6, 1.7),
		BodySize = Vector3.new(1.4, 1.5, 1.4),
		EarType = 'OwlWings',
	},
	{
		Id = 'FrostFox',
		Name = 'Frost Fox',
		Rarity = 'Epic',
		BaseRate = 50,
		PrimaryColor = Color3.fromRGB(100, 215, 245),   -- Vibrant cyan
		SecondaryColor = Color3.fromRGB(255, 255, 255), -- White chest ruff & tail tip
		AccentColor = Color3.fromRGB(40, 140, 210),     -- Deep blue inner ear
		EyeColor = Color3.fromRGB(15, 25, 45),
		AuraColor = Color3.fromRGB(131, 56, 236),       -- Royal purple sparkle
		HeadSize = Vector3.new(1.7, 1.5, 1.7),
		BodySize = Vector3.new(1.3, 1.3, 1.6),
		EarType = 'FoxEars',
	},
	{
		Id = 'AuraDragon',
		Name = 'Aura Dragon',
		Rarity = 'Legendary',
		BaseRate = 100,
		PrimaryColor = Color3.fromRGB(30, 32, 38),      -- Midnight charcoal
		SecondaryColor = Color3.fromRGB(0, 235, 240),   -- Glowing cyan runes (Neon)
		AccentColor = Color3.fromRGB(255, 190, 11),     -- Radiant gold horns
		EyeColor = Color3.fromRGB(0, 255, 240),         -- Neon cyan eyes
		AuraColor = Color3.fromRGB(255, 190, 11),       -- Radiant gold & prismatic aura
		HeadSize = Vector3.new(1.9, 1.7, 1.9),
		BodySize = Vector3.new(1.5, 1.5, 1.8),
		EarType = 'DragonHorns',
	},
}

local function createPart(name: string, size: Vector3, color: Color3, material: Enum.Material?, shape: Enum.PartType?): Part
	local part = Instance.new('Part')
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	if shape then
		part.Shape = shape
	end
	part.CanCollide = false
	part.Anchored = false
	part.CastShadow = true
	return part
end

local function weldParts(part0: BasePart, part1: BasePart)
	local weld = Instance.new('WeldConstraint')
	weld.Part0 = part0
	weld.Part1 = part1
	weld.Parent = part0
end

local function buildPet(def)
	local existing = petModelsFolder:FindFirstChild(def.Id)
	if existing then
		existing:Destroy()
	end

	local model = Instance.new('Model')
	model.Name = def.Id
	model:SetAttribute('PetName', def.Name)
	model:SetAttribute('Rarity', def.Rarity)
	model:SetAttribute('BaseRate', def.BaseRate)
	model:SetAttribute('Placeholder', true)

	-- Root / Body
	local body = createPart('Body', def.BodySize, def.PrimaryColor, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	body.CFrame = CFrame.new(0, 1.5, 0)
	body.Parent = model
	model.PrimaryPart = body

	-- Head
	local head = createPart('Head', def.HeadSize, def.PrimaryColor, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	head.CFrame = body.CFrame * CFrame.new(0, def.BodySize.Y * 0.55, -def.BodySize.Z * 0.35)
	head.Parent = model
	weldParts(body, head)

	-- Eyes
	local eyeMat = (def.Id == 'AuraDragon') and Enum.Material.Neon or Enum.Material.SmoothPlastic
	local eyeSize = Vector3.new(0.3, 0.3, 0.1)
	local leftEye = createPart('LeftEye', eyeSize, def.EyeColor, eyeMat, Enum.PartType.Ball)
	leftEye.CFrame = head.CFrame * CFrame.new(-0.45, 0.1, -def.HeadSize.Z * 0.45)
	leftEye.Parent = model
	weldParts(head, leftEye)

	local rightEye = createPart('RightEye', eyeSize, def.EyeColor, eyeMat, Enum.PartType.Ball)
	rightEye.CFrame = head.CFrame * CFrame.new(0.45, 0.1, -def.HeadSize.Z * 0.45)
	rightEye.Parent = model
	weldParts(head, rightEye)

	-- Snout / Feature
	if def.Id == 'FluffDog' or def.Id == 'ChibiCat' or def.Id == 'FrostFox' then
		local snout = createPart('Snout', Vector3.new(0.6, 0.4, 0.4), def.SecondaryColor, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		snout.CFrame = head.CFrame * CFrame.new(0, -0.2, -def.HeadSize.Z * 0.45)
		snout.Parent = model
		weldParts(head, snout)
	elseif def.Id == 'StormOwl' then
		local beak = createPart('Beak', Vector3.new(0.3, 0.3, 0.4), def.AccentColor, Enum.Material.SmoothPlastic, Enum.PartType.Wedge)
		beak.CFrame = head.CFrame * CFrame.new(0, -0.15, -def.HeadSize.Z * 0.45) * CFrame.Angles(math.rad(180), 0, 0)
		beak.Parent = model
		weldParts(head, beak)
	elseif def.Id == 'FrostBunny' then
		local nose = createPart('Nose', Vector3.new(0.25, 0.2, 0.2), def.SecondaryColor, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		nose.CFrame = head.CFrame * CFrame.new(0, -0.1, -def.HeadSize.Z * 0.45)
		nose.Parent = model
		weldParts(head, nose)
	end

	-- Ears / Horns / Wings
	if def.EarType == 'Floppy' then
		local leftEar = createPart('LeftEar', Vector3.new(0.35, 0.8, 0.4), def.AccentColor, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		leftEar.CFrame = head.CFrame * CFrame.new(-def.HeadSize.X * 0.5, 0.1, 0) * CFrame.Angles(0, 0, math.rad(25))
		leftEar.Parent = model
		weldParts(head, leftEar)

		local rightEar = createPart('RightEar', Vector3.new(0.35, 0.8, 0.4), def.AccentColor, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		rightEar.CFrame = head.CFrame * CFrame.new(def.HeadSize.X * 0.5, 0.1, 0) * CFrame.Angles(0, 0, math.rad(-25))
		rightEar.Parent = model
		weldParts(head, rightEar)
	elseif def.EarType == 'Pointy' or def.EarType == 'FoxEars' then
		local earSize = (def.EarType == 'FoxEars') and Vector3.new(0.5, 1.1, 0.3) or Vector3.new(0.4, 0.7, 0.3)
		local leftEar = createPart('LeftEar', earSize, def.PrimaryColor, Enum.Material.SmoothPlastic, Enum.PartType.Wedge)
		leftEar.CFrame = head.CFrame * CFrame.new(-def.HeadSize.X * 0.4, def.HeadSize.Y * 0.5, 0) * CFrame.Angles(0, math.rad(90), 0)
		leftEar.Parent = model
		weldParts(head, leftEar)

		local rightEar = createPart('RightEar', earSize, def.PrimaryColor, Enum.Material.SmoothPlastic, Enum.PartType.Wedge)
		rightEar.CFrame = head.CFrame * CFrame.new(def.HeadSize.X * 0.4, def.HeadSize.Y * 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
		rightEar.Parent = model
		weldParts(head, rightEar)
	elseif def.EarType == 'BunnyEars' then
		local leftEar = createPart('LeftEar', Vector3.new(0.3, 1.4, 0.3), def.PrimaryColor, Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
		leftEar.CFrame = head.CFrame * CFrame.new(-0.4, def.HeadSize.Y * 0.7, 0) * CFrame.Angles(0, 0, math.rad(-10))
		leftEar.Parent = model
		weldParts(head, leftEar)

		local rightEar = createPart('RightEar', Vector3.new(0.3, 1.4, 0.3), def.PrimaryColor, Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
		rightEar.CFrame = head.CFrame * CFrame.new(0.4, def.HeadSize.Y * 0.7, 0) * CFrame.Angles(0, 0, math.rad(10))
		rightEar.Parent = model
		weldParts(head, rightEar)
	elseif def.EarType == 'OwlWings' then
		local leftWing = createPart('LeftWing', Vector3.new(0.3, 1.2, 0.9), def.SecondaryColor, Enum.Material.SmoothPlastic, Enum.PartType.Block)
		leftWing.CFrame = body.CFrame * CFrame.new(-def.BodySize.X * 0.6, 0.1, 0) * CFrame.Angles(0, 0, math.rad(15))
		leftWing.Parent = model
		weldParts(body, leftWing)

		local rightWing = createPart('RightWing', Vector3.new(0.3, 1.2, 0.9), def.SecondaryColor, Enum.Material.SmoothPlastic, Enum.PartType.Block)
		rightWing.CFrame = body.CFrame * CFrame.new(def.BodySize.X * 0.6, 0.1, 0) * CFrame.Angles(0, 0, math.rad(-15))
		rightWing.Parent = model
		weldParts(body, rightWing)
	elseif def.EarType == 'DragonHorns' then
		local leftHorn = createPart('LeftHorn', Vector3.new(0.3, 0.9, 0.3), def.SecondaryColor, Enum.Material.Neon, Enum.PartType.Cylinder)
		leftHorn.CFrame = head.CFrame * CFrame.new(-def.HeadSize.X * 0.45, def.HeadSize.Y * 0.55, 0.2) * CFrame.Angles(math.rad(-25), 0, math.rad(-20))
		leftHorn.Parent = model
		weldParts(head, leftHorn)

		local rightHorn = createPart('RightHorn', Vector3.new(0.3, 0.9, 0.3), def.SecondaryColor, Enum.Material.Neon, Enum.PartType.Cylinder)
		rightHorn.CFrame = head.CFrame * CFrame.new(def.HeadSize.X * 0.45, def.HeadSize.Y * 0.55, 0.2) * CFrame.Angles(math.rad(-25), 0, math.rad(20))
		rightHorn.Parent = model
		weldParts(head, rightHorn)

		-- Dragon mini wings
		local leftWing = createPart('LeftWing', Vector3.new(0.2, 0.8, 1.1), def.SecondaryColor, Enum.Material.Neon, Enum.PartType.Block)
		leftWing.CFrame = body.CFrame * CFrame.new(-def.BodySize.X * 0.6, 0.3, 0.4) * CFrame.Angles(0, math.rad(30), math.rad(20))
		leftWing.Parent = model
		weldParts(body, leftWing)

		local rightWing = createPart('RightWing', Vector3.new(0.2, 0.8, 1.1), def.SecondaryColor, Enum.Material.Neon, Enum.PartType.Block)
		rightWing.CFrame = body.CFrame * CFrame.new(def.BodySize.X * 0.6, 0.3, 0.4) * CFrame.Angles(0, math.rad(-30), math.rad(-20))
		rightWing.Parent = model
		weldParts(body, rightWing)
	end

	-- Aura Particle Emitter
	local aura = Instance.new('ParticleEmitter')
	aura.Name = 'AuraEmitter'
	aura.Color = ColorSequence.new(def.AuraColor)
	aura.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0)})
	aura.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
	aura.Lifetime = NumberRange.new(0.8, 1.4)
	aura.Rate = (def.Rarity == 'Legendary') and 35 or (def.Rarity == 'Epic' and 25 or (def.Rarity == 'Rare' and 18 or 10))
	aura.Speed = NumberRange.new(0.8, 1.8)
	aura.SpreadAngle = Vector2.new(45, 45)
	aura.LightEmission = (def.Rarity == 'Common') and 0.4 or 0.9
	aura.Parent = body

	model.Parent = petModelsFolder
	print('[Auralit Builder] Created pet placeholder: ' .. def.Id .. ' (' .. def.Rarity .. ')')
	return model
end

for _, def in ipairs(PET_DEFINITIONS) do
	buildPet(def)
end

print('[Auralit Builder] All 6 placeholder pets generated in ServerStorage.PetModels!')
