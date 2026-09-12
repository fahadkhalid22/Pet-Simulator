-- Universal safe post-import configuration for all six Auralit v3 mesh candidates.
-- Paste into the Roblox Studio Command Bar with exactly one imported Workspace Model selected.
-- This helper never deletes, moves, or replaces anything in ServerStorage.
-- After validation, it removes only the selected candidate's recognized Studio importer support objects.
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
		visuals = {
			Body = {material = "BunnyWhite", baseColorFactor = Vector3.new(0.975000024, 0.954999983, 0.964999974), color = Color3.fromRGB(252, 250, 251)},
			Head = {material = "BunnyWhite", baseColorFactor = Vector3.new(0.975000024, 0.954999983, 0.964999974), color = Color3.fromRGB(252, 250, 251)},
			LeftArm = {material = "BunnyWhite", baseColorFactor = Vector3.new(0.975000024, 0.954999983, 0.964999974), color = Color3.fromRGB(252, 250, 251)},
			LeftCheek = {material = "CheekPink", baseColorFactor = Vector3.new(1, 0.579999983, 0.660000026), color = Color3.fromRGB(255, 200, 212)},
			LeftEar = {material = "BunnyWhite", baseColorFactor = Vector3.new(0.975000024, 0.954999983, 0.964999974), color = Color3.fromRGB(252, 250, 251)},
			LeftEye = {material = "EyeBlack", baseColorFactor = Vector3.new(0.00600000005, 0.00400000019, 0.00600000005), color = Color3.fromRGB(18, 13, 18)},
			LeftEyeHighlight = {material = "EyeHighlight", baseColorFactor = Vector3.new(1, 1, 1), color = Color3.fromRGB(255, 255, 255)},
			LeftFoot = {material = "BunnyWhite", baseColorFactor = Vector3.new(0.975000024, 0.954999983, 0.964999974), color = Color3.fromRGB(252, 250, 251)},
			LeftInnerEar = {material = "InnerEarPink", baseColorFactor = Vector3.new(1, 0.254999995, 0.360000014), color = Color3.fromRGB(255, 138, 162)},
			LeftLeg = {material = "BunnyWhite", baseColorFactor = Vector3.new(0.975000024, 0.954999983, 0.964999974), color = Color3.fromRGB(252, 250, 251)},
			LeftMuzzle = {material = "BunnyWhite", baseColorFactor = Vector3.new(0.975000024, 0.954999983, 0.964999974), color = Color3.fromRGB(252, 250, 251)},
			LeftPawPad = {material = "PawPink", baseColorFactor = Vector3.new(1, 0.310000002, 0.430000007), color = Color3.fromRGB(255, 151, 175)},
			LeftToePad1 = {material = "PawPink", baseColorFactor = Vector3.new(1, 0.310000002, 0.430000007), color = Color3.fromRGB(255, 151, 175)},
			LeftToePad2 = {material = "PawPink", baseColorFactor = Vector3.new(1, 0.310000002, 0.430000007), color = Color3.fromRGB(255, 151, 175)},
			LeftToePad3 = {material = "PawPink", baseColorFactor = Vector3.new(1, 0.310000002, 0.430000007), color = Color3.fromRGB(255, 151, 175)},
			Mouth = {material = "MouthBlack", baseColorFactor = Vector3.new(0.0250000004, 0.0120000001, 0.0179999992), color = Color3.fromRGB(44, 29, 36)},
			Nose = {material = "NosePink", baseColorFactor = Vector3.new(1, 0.200000003, 0.300000012), color = Color3.fromRGB(255, 124, 149)},
			RightArm = {material = "BunnyWhite", baseColorFactor = Vector3.new(0.975000024, 0.954999983, 0.964999974), color = Color3.fromRGB(252, 250, 251)},
			RightCheek = {material = "CheekPink", baseColorFactor = Vector3.new(1, 0.579999983, 0.660000026), color = Color3.fromRGB(255, 200, 212)},
			RightEar = {material = "BunnyWhite", baseColorFactor = Vector3.new(0.975000024, 0.954999983, 0.964999974), color = Color3.fromRGB(252, 250, 251)},
			RightEye = {material = "EyeBlack", baseColorFactor = Vector3.new(0.00600000005, 0.00400000019, 0.00600000005), color = Color3.fromRGB(18, 13, 18)},
			RightEyeHighlight = {material = "EyeHighlight", baseColorFactor = Vector3.new(1, 1, 1), color = Color3.fromRGB(255, 255, 255)},
			RightFoot = {material = "BunnyWhite", baseColorFactor = Vector3.new(0.975000024, 0.954999983, 0.964999974), color = Color3.fromRGB(252, 250, 251)},
			RightInnerEar = {material = "InnerEarPink", baseColorFactor = Vector3.new(1, 0.254999995, 0.360000014), color = Color3.fromRGB(255, 138, 162)},
			RightLeg = {material = "BunnyWhite", baseColorFactor = Vector3.new(0.975000024, 0.954999983, 0.964999974), color = Color3.fromRGB(252, 250, 251)},
			RightMuzzle = {material = "BunnyWhite", baseColorFactor = Vector3.new(0.975000024, 0.954999983, 0.964999974), color = Color3.fromRGB(252, 250, 251)},
			RightPawPad = {material = "PawPink", baseColorFactor = Vector3.new(1, 0.310000002, 0.430000007), color = Color3.fromRGB(255, 151, 175)},
			RightToePad1 = {material = "PawPink", baseColorFactor = Vector3.new(1, 0.310000002, 0.430000007), color = Color3.fromRGB(255, 151, 175)},
			RightToePad2 = {material = "PawPink", baseColorFactor = Vector3.new(1, 0.310000002, 0.430000007), color = Color3.fromRGB(255, 151, 175)},
			RightToePad3 = {material = "PawPink", baseColorFactor = Vector3.new(1, 0.310000002, 0.430000007), color = Color3.fromRGB(255, 151, 175)},
			Tail = {material = "BunnyWhite", baseColorFactor = Vector3.new(0.975000024, 0.954999983, 0.964999974), color = Color3.fromRGB(252, 250, 251)},
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
		visuals = {
			Body = {material = "CatCharcoal", baseColorFactor = Vector3.new(0.104999997, 0.0900000036, 0.100000001), color = Color3.fromRGB(91, 85, 89)},
			Chest = {material = "CatWhite", baseColorFactor = Vector3.new(0.959999979, 0.939999998, 0.899999976), color = Color3.fromRGB(250, 248, 243)},
			ForeheadBlaze = {material = "CatWhite", baseColorFactor = Vector3.new(0.959999979, 0.939999998, 0.899999976), color = Color3.fromRGB(250, 248, 243)},
			Head = {material = "CatCharcoal", baseColorFactor = Vector3.new(0.104999997, 0.0900000036, 0.100000001), color = Color3.fromRGB(91, 85, 89)},
			LeftEye = {material = "EyeBlack", baseColorFactor = Vector3.new(0.00400000019, 0.00300000003, 0.00400000019), color = Color3.fromRGB(13, 10, 13)},
			LeftEyeHighlight = {material = "EyeHighlight", baseColorFactor = Vector3.new(1, 1, 1), color = Color3.fromRGB(255, 255, 255)},
			LeftEyeRing = {material = "EyeLime", baseColorFactor = Vector3.new(0.670000017, 0.930000007, 0.0199999996), color = Color3.fromRGB(214, 247, 39)},
			LeftFrontLeg = {material = "CatCharcoal", baseColorFactor = Vector3.new(0.104999997, 0.0900000036, 0.100000001), color = Color3.fromRGB(91, 85, 89)},
			LeftFrontPaw = {material = "CatWhite", baseColorFactor = Vector3.new(0.959999979, 0.939999998, 0.899999976), color = Color3.fromRGB(250, 248, 243)},
			LeftHaunch = {material = "CatCharcoal", baseColorFactor = Vector3.new(0.104999997, 0.0900000036, 0.100000001), color = Color3.fromRGB(91, 85, 89)},
			LeftInnerEar = {material = "InnerEarPink", baseColorFactor = Vector3.new(0.920000017, 0.479999989, 0.49000001), color = Color3.fromRGB(246, 184, 186)},
			LeftMuzzle = {material = "CatWhite", baseColorFactor = Vector3.new(0.959999979, 0.939999998, 0.899999976), color = Color3.fromRGB(250, 248, 243)},
			LeftOuterEar = {material = "CatCharcoal", baseColorFactor = Vector3.new(0.104999997, 0.0900000036, 0.100000001), color = Color3.fromRGB(91, 85, 89)},
			LeftToe1 = {material = "NoseDark", baseColorFactor = Vector3.new(0.0549999997, 0.0450000018, 0.0500000007), color = Color3.fromRGB(66, 60, 63)},
			LeftToe2 = {material = "NoseDark", baseColorFactor = Vector3.new(0.0549999997, 0.0450000018, 0.0500000007), color = Color3.fromRGB(66, 60, 63)},
			LeftToe3 = {material = "NoseDark", baseColorFactor = Vector3.new(0.0549999997, 0.0450000018, 0.0500000007), color = Color3.fromRGB(66, 60, 63)},
			Mouth = {material = "NoseDark", baseColorFactor = Vector3.new(0.0549999997, 0.0450000018, 0.0500000007), color = Color3.fromRGB(66, 60, 63)},
			Nose = {material = "NoseDark", baseColorFactor = Vector3.new(0.0549999997, 0.0450000018, 0.0500000007), color = Color3.fromRGB(66, 60, 63)},
			RightEye = {material = "EyeBlack", baseColorFactor = Vector3.new(0.00400000019, 0.00300000003, 0.00400000019), color = Color3.fromRGB(13, 10, 13)},
			RightEyeHighlight = {material = "EyeHighlight", baseColorFactor = Vector3.new(1, 1, 1), color = Color3.fromRGB(255, 255, 255)},
			RightEyeRing = {material = "EyeLime", baseColorFactor = Vector3.new(0.670000017, 0.930000007, 0.0199999996), color = Color3.fromRGB(214, 247, 39)},
			RightFrontLeg = {material = "CatCharcoal", baseColorFactor = Vector3.new(0.104999997, 0.0900000036, 0.100000001), color = Color3.fromRGB(91, 85, 89)},
			RightFrontPaw = {material = "CatWhite", baseColorFactor = Vector3.new(0.959999979, 0.939999998, 0.899999976), color = Color3.fromRGB(250, 248, 243)},
			RightHaunch = {material = "CatCharcoal", baseColorFactor = Vector3.new(0.104999997, 0.0900000036, 0.100000001), color = Color3.fromRGB(91, 85, 89)},
			RightInnerEar = {material = "InnerEarPink", baseColorFactor = Vector3.new(0.920000017, 0.479999989, 0.49000001), color = Color3.fromRGB(246, 184, 186)},
			RightMuzzle = {material = "CatWhite", baseColorFactor = Vector3.new(0.959999979, 0.939999998, 0.899999976), color = Color3.fromRGB(250, 248, 243)},
			RightOuterEar = {material = "CatCharcoal", baseColorFactor = Vector3.new(0.104999997, 0.0900000036, 0.100000001), color = Color3.fromRGB(91, 85, 89)},
			RightToe1 = {material = "NoseDark", baseColorFactor = Vector3.new(0.0549999997, 0.0450000018, 0.0500000007), color = Color3.fromRGB(66, 60, 63)},
			RightToe2 = {material = "NoseDark", baseColorFactor = Vector3.new(0.0549999997, 0.0450000018, 0.0500000007), color = Color3.fromRGB(66, 60, 63)},
			RightToe3 = {material = "NoseDark", baseColorFactor = Vector3.new(0.0549999997, 0.0450000018, 0.0500000007), color = Color3.fromRGB(66, 60, 63)},
			Tail = {material = "CatCharcoal", baseColorFactor = Vector3.new(0.104999997, 0.0900000036, 0.100000001), color = Color3.fromRGB(91, 85, 89)},
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
		visuals = {
			Body = {material = "DogSlate", baseColorFactor = Vector3.new(0.180000007, 0.239999995, 0.280000001), color = Color3.fromRGB(118, 134, 144)},
			Chest = {material = "DogWhite", baseColorFactor = Vector3.new(0.910000026, 0.910000026, 0.860000014), color = Color3.fromRGB(245, 245, 239)},
			FaceBlaze = {material = "DogWhite", baseColorFactor = Vector3.new(0.910000026, 0.910000026, 0.860000014), color = Color3.fromRGB(245, 245, 239)},
			Head = {material = "DogSlate", baseColorFactor = Vector3.new(0.180000007, 0.239999995, 0.280000001), color = Color3.fromRGB(118, 134, 144)},
			LeftBrow = {material = "DogCaramel", baseColorFactor = Vector3.new(0.660000026, 0.310000002, 0.109999999), color = Color3.fromRGB(212, 151, 93)},
			LeftCheek = {material = "DogCaramel", baseColorFactor = Vector3.new(0.660000026, 0.310000002, 0.109999999), color = Color3.fromRGB(212, 151, 93)},
			LeftEar = {material = "DogSlate", baseColorFactor = Vector3.new(0.180000007, 0.239999995, 0.280000001), color = Color3.fromRGB(118, 134, 144)},
			LeftEye = {material = "EyeBlack", baseColorFactor = Vector3.new(0.00800000038, 0.00600000005, 0.00499999989), color = Color3.fromRGB(22, 18, 16)},
			LeftEyeHighlight = {material = "EyeHighlight", baseColorFactor = Vector3.new(1, 0.980000019, 0.899999976), color = Color3.fromRGB(255, 253, 243)},
			LeftFrontLeg = {material = "DogCaramel", baseColorFactor = Vector3.new(0.660000026, 0.310000002, 0.109999999), color = Color3.fromRGB(212, 151, 93)},
			LeftFrontPaw = {material = "DogWhite", baseColorFactor = Vector3.new(0.910000026, 0.910000026, 0.860000014), color = Color3.fromRGB(245, 245, 239)},
			LeftIris = {material = "EyeAmber", baseColorFactor = Vector3.new(0.889999986, 0.479999989, 0.0700000003), color = Color3.fromRGB(242, 184, 75)},
			LeftMuzzle = {material = "DogWhite", baseColorFactor = Vector3.new(0.910000026, 0.910000026, 0.860000014), color = Color3.fromRGB(245, 245, 239)},
			LeftRearLeg = {material = "DogCaramel", baseColorFactor = Vector3.new(0.660000026, 0.310000002, 0.109999999), color = Color3.fromRGB(212, 151, 93)},
			LeftRearPaw = {material = "DogWhite", baseColorFactor = Vector3.new(0.910000026, 0.910000026, 0.860000014), color = Color3.fromRGB(245, 245, 239)},
			Mouth = {material = "MouthDark", baseColorFactor = Vector3.new(0.0599999987, 0.0250000004, 0.0199999996), color = Color3.fromRGB(69, 44, 39)},
			Nose = {material = "MouthDark", baseColorFactor = Vector3.new(0.0599999987, 0.0250000004, 0.0199999996), color = Color3.fromRGB(69, 44, 39)},
			RightBrow = {material = "DogCaramel", baseColorFactor = Vector3.new(0.660000026, 0.310000002, 0.109999999), color = Color3.fromRGB(212, 151, 93)},
			RightCheek = {material = "DogCaramel", baseColorFactor = Vector3.new(0.660000026, 0.310000002, 0.109999999), color = Color3.fromRGB(212, 151, 93)},
			RightEar = {material = "DogSlate", baseColorFactor = Vector3.new(0.180000007, 0.239999995, 0.280000001), color = Color3.fromRGB(118, 134, 144)},
			RightEye = {material = "EyeBlack", baseColorFactor = Vector3.new(0.00800000038, 0.00600000005, 0.00499999989), color = Color3.fromRGB(22, 18, 16)},
			RightEyeHighlight = {material = "EyeHighlight", baseColorFactor = Vector3.new(1, 0.980000019, 0.899999976), color = Color3.fromRGB(255, 253, 243)},
			RightFrontLeg = {material = "DogCaramel", baseColorFactor = Vector3.new(0.660000026, 0.310000002, 0.109999999), color = Color3.fromRGB(212, 151, 93)},
			RightFrontPaw = {material = "DogWhite", baseColorFactor = Vector3.new(0.910000026, 0.910000026, 0.860000014), color = Color3.fromRGB(245, 245, 239)},
			RightIris = {material = "EyeAmber", baseColorFactor = Vector3.new(0.889999986, 0.479999989, 0.0700000003), color = Color3.fromRGB(242, 184, 75)},
			RightMuzzle = {material = "DogWhite", baseColorFactor = Vector3.new(0.910000026, 0.910000026, 0.860000014), color = Color3.fromRGB(245, 245, 239)},
			RightRearLeg = {material = "DogCaramel", baseColorFactor = Vector3.new(0.660000026, 0.310000002, 0.109999999), color = Color3.fromRGB(212, 151, 93)},
			RightRearPaw = {material = "DogWhite", baseColorFactor = Vector3.new(0.910000026, 0.910000026, 0.860000014), color = Color3.fromRGB(245, 245, 239)},
			Tail = {material = "DogSlate", baseColorFactor = Vector3.new(0.180000007, 0.239999995, 0.280000001), color = Color3.fromRGB(118, 134, 144)},
			TailTip = {material = "DogWhite", baseColorFactor = Vector3.new(0.910000026, 0.910000026, 0.860000014), color = Color3.fromRGB(245, 245, 239)},
			Tongue = {material = "TonguePink", baseColorFactor = Vector3.new(0.860000014, 0.239999995, 0.25999999), color = Color3.fromRGB(239, 134, 139)},
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
		visuals = {
			Body = {material = "FrostCyan", baseColorFactor = Vector3.new(0.0799999982, 0.560000002, 0.720000029), color = Color3.fromRGB(80, 197, 221)},
			ChestRuffLeft = {material = "FrostWhite", baseColorFactor = Vector3.new(0.930000007, 0.980000019, 0.980000019), color = Color3.fromRGB(247, 253, 253)},
			ChestRuffLower = {material = "FrostWhite", baseColorFactor = Vector3.new(0.930000007, 0.980000019, 0.980000019), color = Color3.fromRGB(247, 253, 253)},
			ChestRuffRight = {material = "FrostWhite", baseColorFactor = Vector3.new(0.930000007, 0.980000019, 0.980000019), color = Color3.fromRGB(247, 253, 253)},
			ChestRuffUpper = {material = "FrostWhite", baseColorFactor = Vector3.new(0.930000007, 0.980000019, 0.980000019), color = Color3.fromRGB(247, 253, 253)},
			ForeheadTuftCenter = {material = "FrostWhite", baseColorFactor = Vector3.new(0.930000007, 0.980000019, 0.980000019), color = Color3.fromRGB(247, 253, 253)},
			ForeheadTuftLeft = {material = "FrostWhite", baseColorFactor = Vector3.new(0.930000007, 0.980000019, 0.980000019), color = Color3.fromRGB(247, 253, 253)},
			ForeheadTuftRight = {material = "FrostWhite", baseColorFactor = Vector3.new(0.930000007, 0.980000019, 0.980000019), color = Color3.fromRGB(247, 253, 253)},
			Head = {material = "FrostCyanLight", baseColorFactor = Vector3.new(0.230000004, 0.800000012, 0.910000026), color = Color3.fromRGB(132, 231, 245)},
			LeftCheekFur = {material = "FrostWhite", baseColorFactor = Vector3.new(0.930000007, 0.980000019, 0.980000019), color = Color3.fromRGB(247, 253, 253)},
			LeftEye = {material = "FrostNavy", baseColorFactor = Vector3.new(0.0250000004, 0.119999997, 0.200000003), color = Color3.fromRGB(44, 97, 124)},
			LeftEyeHighlight = {material = "EyeHighlight", baseColorFactor = Vector3.new(0.920000017, 1, 1), color = Color3.fromRGB(246, 255, 255)},
			LeftFrontLeg = {material = "FrostCyan", baseColorFactor = Vector3.new(0.0799999982, 0.560000002, 0.720000029), color = Color3.fromRGB(80, 197, 221)},
			LeftFrontPaw = {material = "FrostPawBlue", baseColorFactor = Vector3.new(0.0299999993, 0.330000013, 0.550000012), color = Color3.fromRGB(48, 155, 196)},
			LeftInnerEar = {material = "FrostNavy", baseColorFactor = Vector3.new(0.0250000004, 0.119999997, 0.200000003), color = Color3.fromRGB(44, 97, 124)},
			LeftOuterEar = {material = "FrostCyan", baseColorFactor = Vector3.new(0.0799999982, 0.560000002, 0.720000029), color = Color3.fromRGB(80, 197, 221)},
			LeftRearLeg = {material = "FrostCyan", baseColorFactor = Vector3.new(0.0799999982, 0.560000002, 0.720000029), color = Color3.fromRGB(80, 197, 221)},
			LeftRearPaw = {material = "FrostPawBlue", baseColorFactor = Vector3.new(0.0299999993, 0.330000013, 0.550000012), color = Color3.fromRGB(48, 155, 196)},
			Nose = {material = "FrostNavy", baseColorFactor = Vector3.new(0.0250000004, 0.119999997, 0.200000003), color = Color3.fromRGB(44, 97, 124)},
			RightCheekFur = {material = "FrostWhite", baseColorFactor = Vector3.new(0.930000007, 0.980000019, 0.980000019), color = Color3.fromRGB(247, 253, 253)},
			RightEye = {material = "FrostNavy", baseColorFactor = Vector3.new(0.0250000004, 0.119999997, 0.200000003), color = Color3.fromRGB(44, 97, 124)},
			RightEyeHighlight = {material = "EyeHighlight", baseColorFactor = Vector3.new(0.920000017, 1, 1), color = Color3.fromRGB(246, 255, 255)},
			RightFrontLeg = {material = "FrostCyan", baseColorFactor = Vector3.new(0.0799999982, 0.560000002, 0.720000029), color = Color3.fromRGB(80, 197, 221)},
			RightFrontPaw = {material = "FrostPawBlue", baseColorFactor = Vector3.new(0.0299999993, 0.330000013, 0.550000012), color = Color3.fromRGB(48, 155, 196)},
			RightInnerEar = {material = "FrostNavy", baseColorFactor = Vector3.new(0.0250000004, 0.119999997, 0.200000003), color = Color3.fromRGB(44, 97, 124)},
			RightOuterEar = {material = "FrostCyan", baseColorFactor = Vector3.new(0.0799999982, 0.560000002, 0.720000029), color = Color3.fromRGB(80, 197, 221)},
			RightRearLeg = {material = "FrostCyan", baseColorFactor = Vector3.new(0.0799999982, 0.560000002, 0.720000029), color = Color3.fromRGB(80, 197, 221)},
			RightRearPaw = {material = "FrostPawBlue", baseColorFactor = Vector3.new(0.0299999993, 0.330000013, 0.550000012), color = Color3.fromRGB(48, 155, 196)},
			TailPlume = {material = "FrostWhite", baseColorFactor = Vector3.new(0.930000007, 0.980000019, 0.980000019), color = Color3.fromRGB(247, 253, 253)},
			TailRoot = {material = "FrostCyan", baseColorFactor = Vector3.new(0.0799999982, 0.560000002, 0.720000029), color = Color3.fromRGB(80, 197, 221)},
			TailTip = {material = "FrostWhite", baseColorFactor = Vector3.new(0.930000007, 0.980000019, 0.980000019), color = Color3.fromRGB(247, 253, 253)},
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
		visuals = {
			Beak = {material = "Amber", baseColorFactor = Vector3.new(0.939999998, 0.469999999, 0.0500000007), color = Color3.fromRGB(248, 182, 63)},
			Body = {material = "SnowPlumage", baseColorFactor = Vector3.new(0.899999976, 0.910000026, 0.889999986), color = Color3.fromRGB(243, 245, 242)},
			ChestLeft = {material = "SilverPlumage", baseColorFactor = Vector3.new(0.419999987, 0.460000008, 0.49000001), color = Color3.fromRGB(173, 181, 186)},
			ChestLower = {material = "SnowPlumage", baseColorFactor = Vector3.new(0.899999976, 0.910000026, 0.889999986), color = Color3.fromRGB(243, 245, 242)},
			ChestRight = {material = "SilverPlumage", baseColorFactor = Vector3.new(0.419999987, 0.460000008, 0.49000001), color = Color3.fromRGB(173, 181, 186)},
			ChestUpper = {material = "SilverPlumage", baseColorFactor = Vector3.new(0.419999987, 0.460000008, 0.49000001), color = Color3.fromRGB(173, 181, 186)},
			Head = {material = "SnowPlumage", baseColorFactor = Vector3.new(0.899999976, 0.910000026, 0.889999986), color = Color3.fromRGB(243, 245, 242)},
			LeftEye = {material = "EyeBlack", baseColorFactor = Vector3.new(0.00600000005, 0.00600000005, 0.00700000022), color = Color3.fromRGB(18, 18, 20)},
			LeftEyeDisc = {material = "SilverPlumage", baseColorFactor = Vector3.new(0.419999987, 0.460000008, 0.49000001), color = Color3.fromRGB(173, 181, 186)},
			LeftEyeHighlight = {material = "EyeHighlight", baseColorFactor = Vector3.new(1, 1, 0.959999979), color = Color3.fromRGB(255, 255, 250)},
			LeftFoot = {material = "Amber", baseColorFactor = Vector3.new(0.939999998, 0.469999999, 0.0500000007), color = Color3.fromRGB(248, 182, 63)},
			LeftLeg = {material = "StormCharcoal", baseColorFactor = Vector3.new(0.0799999982, 0.0900000036, 0.100000001), color = Color3.fromRGB(80, 85, 89)},
			LeftTalon1 = {material = "Amber", baseColorFactor = Vector3.new(0.939999998, 0.469999999, 0.0500000007), color = Color3.fromRGB(248, 182, 63)},
			LeftTalon2 = {material = "Amber", baseColorFactor = Vector3.new(0.939999998, 0.469999999, 0.0500000007), color = Color3.fromRGB(248, 182, 63)},
			LeftTalon3 = {material = "Amber", baseColorFactor = Vector3.new(0.939999998, 0.469999999, 0.0500000007), color = Color3.fromRGB(248, 182, 63)},
			LeftWingBase = {material = "SilverPlumage", baseColorFactor = Vector3.new(0.419999987, 0.460000008, 0.49000001), color = Color3.fromRGB(173, 181, 186)},
			LeftWingLower = {material = "SnowPlumage", baseColorFactor = Vector3.new(0.899999976, 0.910000026, 0.889999986), color = Color3.fromRGB(243, 245, 242)},
			LeftWingMiddle = {material = "SilverPlumage", baseColorFactor = Vector3.new(0.419999987, 0.460000008, 0.49000001), color = Color3.fromRGB(173, 181, 186)},
			LeftWingTip = {material = "SilverPlumage", baseColorFactor = Vector3.new(0.419999987, 0.460000008, 0.49000001), color = Color3.fromRGB(173, 181, 186)},
			LeftWingUpper = {material = "SnowPlumage", baseColorFactor = Vector3.new(0.899999976, 0.910000026, 0.889999986), color = Color3.fromRGB(243, 245, 242)},
			RightEye = {material = "EyeBlack", baseColorFactor = Vector3.new(0.00600000005, 0.00600000005, 0.00700000022), color = Color3.fromRGB(18, 18, 20)},
			RightEyeDisc = {material = "SilverPlumage", baseColorFactor = Vector3.new(0.419999987, 0.460000008, 0.49000001), color = Color3.fromRGB(173, 181, 186)},
			RightEyeHighlight = {material = "EyeHighlight", baseColorFactor = Vector3.new(1, 1, 0.959999979), color = Color3.fromRGB(255, 255, 250)},
			RightFoot = {material = "Amber", baseColorFactor = Vector3.new(0.939999998, 0.469999999, 0.0500000007), color = Color3.fromRGB(248, 182, 63)},
			RightLeg = {material = "StormCharcoal", baseColorFactor = Vector3.new(0.0799999982, 0.0900000036, 0.100000001), color = Color3.fromRGB(80, 85, 89)},
			RightTalon1 = {material = "Amber", baseColorFactor = Vector3.new(0.939999998, 0.469999999, 0.0500000007), color = Color3.fromRGB(248, 182, 63)},
			RightTalon2 = {material = "Amber", baseColorFactor = Vector3.new(0.939999998, 0.469999999, 0.0500000007), color = Color3.fromRGB(248, 182, 63)},
			RightTalon3 = {material = "Amber", baseColorFactor = Vector3.new(0.939999998, 0.469999999, 0.0500000007), color = Color3.fromRGB(248, 182, 63)},
			RightWingBase = {material = "SilverPlumage", baseColorFactor = Vector3.new(0.419999987, 0.460000008, 0.49000001), color = Color3.fromRGB(173, 181, 186)},
			RightWingLower = {material = "SnowPlumage", baseColorFactor = Vector3.new(0.899999976, 0.910000026, 0.889999986), color = Color3.fromRGB(243, 245, 242)},
			RightWingMiddle = {material = "SilverPlumage", baseColorFactor = Vector3.new(0.419999987, 0.460000008, 0.49000001), color = Color3.fromRGB(173, 181, 186)},
			RightWingTip = {material = "SilverPlumage", baseColorFactor = Vector3.new(0.419999987, 0.460000008, 0.49000001), color = Color3.fromRGB(173, 181, 186)},
			RightWingUpper = {material = "SnowPlumage", baseColorFactor = Vector3.new(0.899999976, 0.910000026, 0.889999986), color = Color3.fromRGB(243, 245, 242)},
			TailCenter = {material = "SnowPlumage", baseColorFactor = Vector3.new(0.899999976, 0.910000026, 0.889999986), color = Color3.fromRGB(243, 245, 242)},
			TailLeft = {material = "SilverPlumage", baseColorFactor = Vector3.new(0.419999987, 0.460000008, 0.49000001), color = Color3.fromRGB(173, 181, 186)},
			TailRight = {material = "SilverPlumage", baseColorFactor = Vector3.new(0.419999987, 0.460000008, 0.49000001), color = Color3.fromRGB(173, 181, 186)},
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
		visuals = {
			Belt = {material = "DragonArmorLight", baseColorFactor = Vector3.new(0.25, 0.389999986, 0.379999995), color = Color3.fromRGB(137, 168, 166)},
			Body = {material = "VoidRobe", baseColorFactor = Vector3.new(0.0250000004, 0.0399999991, 0.0450000018), color = Color3.fromRGB(44, 56, 60)},
			ChestRune = {material = "AuraCyan", baseColorFactor = Vector3.new(0.00999999978, 0.860000014, 0.839999974), color = Color3.fromRGB(25, 239, 236)},
			Collar = {material = "DragonArmorLight", baseColorFactor = Vector3.new(0.25, 0.389999986, 0.379999995), color = Color3.fromRGB(137, 168, 166)},
			FaceMask = {material = "DragonArmor", baseColorFactor = Vector3.new(0.0799999982, 0.129999995, 0.140000001), color = Color3.fromRGB(80, 101, 105)},
			Head = {material = "AuraCyan", baseColorFactor = Vector3.new(0.00999999978, 0.860000014, 0.839999974), color = Color3.fromRGB(25, 239, 236)},
			HelmetBand = {material = "DragonArmor", baseColorFactor = Vector3.new(0.0799999982, 0.129999995, 0.140000001), color = Color3.fromRGB(80, 101, 105)},
			HelmetCrest = {material = "DragonArmor", baseColorFactor = Vector3.new(0.0799999982, 0.129999995, 0.140000001), color = Color3.fromRGB(80, 101, 105)},
			HelmetDome = {material = "DragonArmorLight", baseColorFactor = Vector3.new(0.25, 0.389999986, 0.379999995), color = Color3.fromRGB(137, 168, 166)},
			LeftArm = {material = "VoidRobe", baseColorFactor = Vector3.new(0.0250000004, 0.0399999991, 0.0450000018), color = Color3.fromRGB(44, 56, 60)},
			LeftBoot = {material = "DragonArmor", baseColorFactor = Vector3.new(0.0799999982, 0.129999995, 0.140000001), color = Color3.fromRGB(80, 101, 105)},
			LeftCoatPanel = {material = "DragonArmor", baseColorFactor = Vector3.new(0.0799999982, 0.129999995, 0.140000001), color = Color3.fromRGB(80, 101, 105)},
			LeftCuff = {material = "AuraCyan", baseColorFactor = Vector3.new(0.00999999978, 0.860000014, 0.839999974), color = Color3.fromRGB(25, 239, 236)},
			LeftEye = {material = "AuraCyanSoft", baseColorFactor = Vector3.new(0.100000001, 0.959999979, 0.930000007), color = Color3.fromRGB(89, 250, 247)},
			LeftHand = {material = "AuraCyan", baseColorFactor = Vector3.new(0.00999999978, 0.860000014, 0.839999974), color = Color3.fromRGB(25, 239, 236)},
			LeftHelmetPillar = {material = "DragonArmor", baseColorFactor = Vector3.new(0.0799999982, 0.129999995, 0.140000001), color = Color3.fromRGB(80, 101, 105)},
			LeftHelmetRune = {material = "AuraCyan", baseColorFactor = Vector3.new(0.00999999978, 0.860000014, 0.839999974), color = Color3.fromRGB(25, 239, 236)},
			LeftLeg = {material = "VoidRobe", baseColorFactor = Vector3.new(0.0250000004, 0.0399999991, 0.0450000018), color = Color3.fromRGB(44, 56, 60)},
			LeftLegRune = {material = "AuraCyan", baseColorFactor = Vector3.new(0.00999999978, 0.860000014, 0.839999974), color = Color3.fromRGB(25, 239, 236)},
			LeftShoulder = {material = "DragonArmor", baseColorFactor = Vector3.new(0.0799999982, 0.129999995, 0.140000001), color = Color3.fromRGB(80, 101, 105)},
			LeftSleeveRune = {material = "AuraCyan", baseColorFactor = Vector3.new(0.00999999978, 0.860000014, 0.839999974), color = Color3.fromRGB(25, 239, 236)},
			RightArm = {material = "VoidRobe", baseColorFactor = Vector3.new(0.0250000004, 0.0399999991, 0.0450000018), color = Color3.fromRGB(44, 56, 60)},
			RightBoot = {material = "DragonArmor", baseColorFactor = Vector3.new(0.0799999982, 0.129999995, 0.140000001), color = Color3.fromRGB(80, 101, 105)},
			RightCoatPanel = {material = "DragonArmor", baseColorFactor = Vector3.new(0.0799999982, 0.129999995, 0.140000001), color = Color3.fromRGB(80, 101, 105)},
			RightCuff = {material = "AuraCyan", baseColorFactor = Vector3.new(0.00999999978, 0.860000014, 0.839999974), color = Color3.fromRGB(25, 239, 236)},
			RightEye = {material = "AuraCyanSoft", baseColorFactor = Vector3.new(0.100000001, 0.959999979, 0.930000007), color = Color3.fromRGB(89, 250, 247)},
			RightHand = {material = "AuraCyan", baseColorFactor = Vector3.new(0.00999999978, 0.860000014, 0.839999974), color = Color3.fromRGB(25, 239, 236)},
			RightHelmetPillar = {material = "DragonArmor", baseColorFactor = Vector3.new(0.0799999982, 0.129999995, 0.140000001), color = Color3.fromRGB(80, 101, 105)},
			RightHelmetRune = {material = "AuraCyan", baseColorFactor = Vector3.new(0.00999999978, 0.860000014, 0.839999974), color = Color3.fromRGB(25, 239, 236)},
			RightLeg = {material = "VoidRobe", baseColorFactor = Vector3.new(0.0250000004, 0.0399999991, 0.0450000018), color = Color3.fromRGB(44, 56, 60)},
			RightLegRune = {material = "AuraCyan", baseColorFactor = Vector3.new(0.00999999978, 0.860000014, 0.839999974), color = Color3.fromRGB(25, 239, 236)},
			RightShoulder = {material = "DragonArmor", baseColorFactor = Vector3.new(0.0799999982, 0.129999995, 0.140000001), color = Color3.fromRGB(80, 101, 105)},
			RightSleeveRune = {material = "AuraCyan", baseColorFactor = Vector3.new(0.00999999978, 0.860000014, 0.839999974), color = Color3.fromRGB(25, 239, 236)},
			StaffCrown = {material = "DragonArmor", baseColorFactor = Vector3.new(0.0799999982, 0.129999995, 0.140000001), color = Color3.fromRGB(80, 101, 105)},
			StaffFlameCore = {material = "AuraCyanSoft", baseColorFactor = Vector3.new(0.100000001, 0.959999979, 0.930000007), color = Color3.fromRGB(89, 250, 247)},
			StaffFlameLeft = {material = "AuraCyan", baseColorFactor = Vector3.new(0.00999999978, 0.860000014, 0.839999974), color = Color3.fromRGB(25, 239, 236)},
			StaffFlameRight = {material = "AuraCyan", baseColorFactor = Vector3.new(0.00999999978, 0.860000014, 0.839999974), color = Color3.fromRGB(25, 239, 236)},
			StaffLeftClaw = {material = "StaffDark", baseColorFactor = Vector3.new(0.0250000004, 0.0350000001, 0.0350000001), color = Color3.fromRGB(44, 53, 53)},
			StaffLeftProng = {material = "DragonArmor", baseColorFactor = Vector3.new(0.0799999982, 0.129999995, 0.140000001), color = Color3.fromRGB(80, 101, 105)},
			StaffLowerGrip = {material = "DragonArmorLight", baseColorFactor = Vector3.new(0.25, 0.389999986, 0.379999995), color = Color3.fromRGB(137, 168, 166)},
			StaffRightClaw = {material = "StaffDark", baseColorFactor = Vector3.new(0.0250000004, 0.0350000001, 0.0350000001), color = Color3.fromRGB(44, 53, 53)},
			StaffRightProng = {material = "DragonArmor", baseColorFactor = Vector3.new(0.0799999982, 0.129999995, 0.140000001), color = Color3.fromRGB(80, 101, 105)},
			StaffShaft = {material = "StaffDark", baseColorFactor = Vector3.new(0.0250000004, 0.0350000001, 0.0350000001), color = Color3.fromRGB(44, 53, 53)},
			StaffTip = {material = "AuraCyan", baseColorFactor = Vector3.new(0.00999999978, 0.860000014, 0.839999974), color = Color3.fromRGB(25, 239, 236)},
			StaffUpperGrip = {material = "DragonArmorLight", baseColorFactor = Vector3.new(0.25, 0.389999986, 0.379999995), color = Color3.fromRGB(137, 168, 166)},
			TorsoArmor = {material = "DragonArmor", baseColorFactor = Vector3.new(0.0799999982, 0.129999995, 0.140000001), color = Color3.fromRGB(80, 101, 105)},
		},
		effects = {
			{name = "GoldShimmer", className = "ParticleEmitter", position = Vector3.new(0, 0.25, 0)},
			{name = "CyanSoulfire", className = "ParticleEmitter", position = Vector3.new(0, 0.55, 0)},
			{name = "LegendaryAuraLight", className = "PointLight", position = Vector3.new(0, 0.3, 0)},
		},
	},
}

local IMPORT_SUFFIXES = {"_Node_Mesh", "_Mesh", "_Node", ""}
local INITIAL_POSE_SUFFIXES = {"_Initial", "_Original", "_Composited"}
local DIAGNOSTIC_ORDER = {
	{"General", "general"},
	{"Unknown MeshParts", "unknownMeshParts"},
	{"Missing canonical components", "missingComponents"},
	{"Duplicate canonical components", "duplicateComponents"},
	{"Importer support problems", "importerSupport"},
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
	table.insert(lines, "Visual bounds: " .. boundsStatus)
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

local visualContractCount = 0
for meshName, visual in spec.visuals do
	visualContractCount += 1
	if not expectedMeshNames[meshName] then
		addProblem(problems, "general", string.format("Visual contract targets unknown MeshPart %s.", meshName))
	end
	if type(visual.material) ~= "string" or visual.material == ""
		or typeof(visual.baseColorFactor) ~= "Vector3" or typeof(visual.color) ~= "Color3" then
		addProblem(problems, "general", string.format("Visual contract for %s is malformed.", meshName))
	end
end
for meshName in expectedMeshNames do
	if not spec.visuals[meshName] then
		addProblem(problems, "general", string.format("Visual contract is missing MeshPart %s.", meshName))
	end
end
if visualContractCount ~= spec.meshCount then
	addProblem(problems, "general", "Visual contract count does not match its exact MeshPart count.")
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

local function isFiniteCFrame(value)
	for _, component in {value:GetComponents()} do
		if not isFiniteNumber(component) then
			return false
		end
	end
	return true
end

local function hasFiniteCFrame(instance)
	return isFiniteCFrame(instance.CFrame)
end

local function normalizeInitialPoseName(rawName)
	for _, suffix in INITIAL_POSE_SUFFIXES do
		if #rawName > #suffix and string.sub(rawName, -#suffix) == suffix then
			local targetName = string.sub(rawName, 1, #rawName - #suffix)
			if targetName == "RootPart" or targetName == "Root" then
				return "RootPart"
			end
			return normalizeMeshName(targetName)
		end
	end
	return nil
end

local function hasFiniteJointTransforms(joint)
	for _, value in {joint.C0, joint.C1, joint.Transform} do
		if not isFiniteCFrame(value) then
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

local function computeVisualMeshBounds(parts)
	local minimum = Vector3.new(math.huge, math.huge, math.huge)
	local maximum = Vector3.new(-math.huge, -math.huge, -math.huge)
	for _, part in parts do
		local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = part.CFrame:GetComponents()
		local half = part.Size * 0.5
		local extent = Vector3.new(
			math.abs(r00) * half.X + math.abs(r01) * half.Y + math.abs(r02) * half.Z,
			math.abs(r10) * half.X + math.abs(r11) * half.Y + math.abs(r12) * half.Z,
			math.abs(r20) * half.X + math.abs(r21) * half.Y + math.abs(r22) * half.Z
		)
		local position = Vector3.new(x, y, z)
		local partMinimum = position - extent
		local partMaximum = position + extent
		minimum = Vector3.new(
			math.min(minimum.X, partMinimum.X),
			math.min(minimum.Y, partMinimum.Y),
			math.min(minimum.Z, partMinimum.Z)
		)
		maximum = Vector3.new(
			math.max(maximum.X, partMaximum.X),
			math.max(maximum.Y, partMaximum.Y),
			math.max(maximum.Z, partMaximum.Z)
		)
	end
	return maximum - minimum
end

local meshParts = {}
local meshByName = {}
local canonicalByMeshPart = {}
local rawNamesByCanonical = {}
local existingVfxByName = {}
local importerRootPart = nil
local importerAnimationController = nil
local importerInitialPoses = nil
local importerMotor6Ds = {}
local importerPoseValues = {}
for _, descendant in candidate:GetDescendants() do
	if descendant:IsA("LuaSourceContainer") then
		addProblem(problems, "wrongClasses", string.format("Script %s is forbidden.", descendant:GetFullName()))
	elseif descendant:IsA("BasePart") then
		if not hasFiniteCFrame(descendant) or not hasFinitePositiveSize(descendant) then
			addProblem(problems, "transforms", string.format("%s has a non-finite transform or invalid size.", descendant:GetFullName()))
		end
		if descendant:IsA("MeshPart") then
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
		elseif descendant:IsA("Part") and descendant.Name == "RootPart" then
			if descendant.Parent ~= candidate then
				addProblem(problems, "importerSupport", "RootPart must be a direct child of the selected Model.")
			elseif importerRootPart then
				addProblem(problems, "importerSupport", "RootPart appears more than once.")
			else
				importerRootPart = descendant
			end
		else
			addProblem(problems, "wrongClasses", string.format("%s is %s; character geometry must be MeshPart.", descendant:GetFullName(), descendant.ClassName))
		end
	elseif descendant:IsA("AnimationController") then
		if descendant.Name ~= "AnimationController" or descendant.Parent ~= candidate then
			addProblem(problems, "importerSupport", string.format("Unexpected AnimationController %s.", descendant:GetFullName()))
		elseif importerAnimationController then
			addProblem(problems, "importerSupport", "AnimationController appears more than once.")
		else
			importerAnimationController = descendant
		end
	elseif descendant:IsA("Folder") then
		if descendant.Name ~= "InitialPoses" or descendant.Parent ~= candidate then
			addProblem(problems, "importerSupport", string.format("Unexpected Folder %s.", descendant:GetFullName()))
		elseif importerInitialPoses then
			addProblem(problems, "importerSupport", "InitialPoses appears more than once.")
		else
			importerInitialPoses = descendant
		end
	elseif descendant:IsA("Motor6D") then
		local parentMesh = descendant.Parent
		local canonicalName = if parentMesh and parentMesh:IsA("MeshPart") then normalizeMeshName(parentMesh.Name) else nil
		if not canonicalName or descendant.Name ~= parentMesh.Name .. "Motor6D" then
			addProblem(problems, "importerSupport", string.format("Unexpected Motor6D %s.", descendant:GetFullName()))
		else
			table.insert(importerMotor6Ds, {instance = descendant, meshPart = parentMesh, canonicalName = canonicalName})
			if not hasFiniteJointTransforms(descendant) then
				addProblem(problems, "transforms", string.format("Motor6D %s has a non-finite transform.", descendant.Name))
			end
		end
	elseif descendant:IsA("CFrameValue") then
		local poseTarget = normalizeInitialPoseName(descendant.Name)
		local validParent = descendant.Parent and descendant.Parent:IsA("Folder")
			and descendant.Parent.Name == "InitialPoses" and descendant.Parent.Parent == candidate
		if not validParent or not poseTarget then
			addProblem(problems, "importerSupport", string.format("Unexpected CFrameValue %s.", descendant:GetFullName()))
		elseif importerPoseValues[descendant.Name] then
			addProblem(problems, "importerSupport", string.format("Initial pose %s appears more than once.", descendant.Name))
		else
			importerPoseValues[descendant.Name] = {instance = descendant, target = poseTarget}
			if not isFiniteCFrame(descendant.Value) then
				addProblem(problems, "transforms", string.format("Initial pose %s has a non-finite value.", descendant.Name))
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

local importerSupportPresent = importerRootPart ~= nil or importerAnimationController ~= nil
	or importerInitialPoses ~= nil or #importerMotor6Ds > 0 or next(importerPoseValues) ~= nil
local importerSupportStatus = if importerSupportPresent then "recognized" else "not present"
if importerSupportPresent then
	if not importerRootPart then
		addProblem(problems, "importerSupport", "Studio importer profile is missing its direct RootPart Part.")
	end
	if not importerAnimationController then
		addProblem(problems, "importerSupport", "Studio importer profile is missing its direct AnimationController.")
	end
	if not importerInitialPoses then
		addProblem(problems, "importerSupport", "Studio importer profile is missing its direct InitialPoses Folder.")
	end

	local motorByCanonical = {}
	for _, record in importerMotor6Ds do
		if motorByCanonical[record.canonicalName] then
			addProblem(problems, "importerSupport", string.format("Motor6D for %s appears more than once.", record.canonicalName))
		else
			motorByCanonical[record.canonicalName] = record.instance
		end
		local joint = record.instance
		local part0IsKnown = joint.Part0 ~= nil
			and (joint.Part0 == importerRootPart or canonicalByMeshPart[joint.Part0] ~= nil)
		local part1IsKnown = joint.Part1 ~= nil
			and (joint.Part1 == importerRootPart or canonicalByMeshPart[joint.Part1] ~= nil)
		local parentIsEndpoint = joint.Part0 == record.meshPart or joint.Part1 == record.meshPart
		if not part0IsKnown or not part1IsKnown or joint.Part0 == joint.Part1 or not parentIsEndpoint then
			addProblem(problems, "importerSupport", string.format("Motor6D %s has invalid imported-part endpoints.", joint.Name))
		end
	end
	for expectedName in expectedMeshNames do
		if not motorByCanonical[expectedName] then
			addProblem(problems, "importerSupport", string.format("Studio importer profile is missing %sMotor6D.", expectedName))
		end
	end

	local poseTargets = {}
	for _, record in importerPoseValues do
		poseTargets[record.target] = true
	end
	for expectedName in expectedMeshNames do
		if not poseTargets[expectedName] then
			addProblem(problems, "importerSupport", string.format("InitialPoses has no deterministic pose for %s.", expectedName))
		end
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
	local hasKnownVisualParent = meshPart.Parent == candidate or (body and meshPart.Parent == body)
	if canonicalName and canonicalName ~= "Body" and not hasKnownVisualParent then
		rootIsValid = false
		addProblem(problems, "hierarchy", string.format(
			"%s must be a direct child of the selected Model or Body; parent is %s.",
			meshPart.Name,
			meshPart.Parent:GetFullName()
		))
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

local visualBounds = Vector3.zero
local boundsOk, measuredBounds = pcall(computeVisualMeshBounds, meshParts)
if not boundsOk then
	boundsStatus = "FAIL"
	addProblem(problems, "general", "Canonical visual MeshPart bounds could not be measured.")
else
	visualBounds = measuredBounds
	local boundsChecks = {
		{axis = "X", value = visualBounds.X, minimum = spec.boundsMin.X, maximum = spec.boundsMax.X},
		{axis = "Y", value = visualBounds.Y, minimum = spec.boundsMin.Y, maximum = spec.boundsMax.Y},
		{axis = "Z", value = visualBounds.Z, minimum = spec.boundsMin.Z, maximum = spec.boundsMax.Z},
	}
	local validBounds = true
	for _, check in boundsChecks do
		if not isFiniteNumber(check.value) or check.value <= 0 then
			validBounds = false
			addProblem(problems, "transforms", string.format("Imported %s bound is not positive and finite.", check.axis))
		elseif check.value < check.minimum or check.value > check.maximum then
			validBounds = false
			addProblem(problems, "general", string.format(
				"Visual-only %s bound %.3f is outside approved %.3f-%.3f.",
				check.axis, check.value, check.minimum, check.maximum
			))
		end
	end
	boundsStatus = if validBounds then string.format(
		"PASS (%.3f x %.3f x %.3f)", visualBounds.X, visualBounds.Y, visualBounds.Z
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
	meshPart.Color = spec.visuals[canonicalName].color
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

-- Geometry CFrames, sizes, mesh IDs, and Roblox material types are intentionally untouched.
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

local removedSupportObjectCount = 0
if importerSupportPresent then
	for _ in importerPoseValues do
		removedSupportObjectCount += 1
	end
	for _, record in importerMotor6Ds do
		record.instance:Destroy()
		removedSupportObjectCount += 1
	end
	for _, supportObject in {importerInitialPoses, importerAnimationController, importerRootPart} do
		supportObject:Destroy()
		removedSupportObjectCount += 1
	end
end

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
	assert(meshPart.Color == spec.visuals[meshPart.Name].color, string.format("%s color configuration failed.", meshPart.Name))
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

local finalVisualBounds = computeVisualMeshBounds(meshParts)
assert(
	(finalVisualBounds - visualBounds).Magnitude < 0.001,
	"Configuration unexpectedly changed visual MeshPart bounds."
)
assert(not candidate:FindFirstChild("RootPart"), "Importer RootPart cleanup failed.")
assert(not candidate:FindFirstChild("AnimationController"), "Importer AnimationController cleanup failed.")
assert(not candidate:FindFirstChild("InitialPoses"), "Importer InitialPoses cleanup failed.")

Selection:Set({candidate})
print(table.concat({
	"[Auralit Pet Import Validation PASSED]",
	"Pet: " .. petId,
	string.format("MeshParts: %d/%d", #meshParts, spec.meshCount),
	string.format("Canonical names: PASS (%d deterministic importer names normalized)", renamedMeshPartCount),
	"Studio importer support objects: " .. importerSupportStatus,
	"Visual bounds: " .. boundsStatus,
	"Root: " .. rootStatus,
	string.format("Importer cleanup: PASS (%d deterministic support objects removed)", removedSupportObjectCount),
	"Metadata/physics/VFX: PASS",
	"Candidate: " .. candidate:GetFullName(),
	"No ServerStorage model was deleted, moved, or replaced.",
}, "\n"))
