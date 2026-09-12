--!strict

-- Shared, non-authoritative presentation tuning for equipped pet clones.
-- PetService and DataService remain the only authorities for ownership/equip state.
local PetRuntimeConfig = {}

PetRuntimeConfig.ContainerName = "AuralitPetRuntime"
PetRuntimeConfig.ParkCFrame = CFrame.new(0, -10_000, 0)
PetRuntimeConfig.FormationOffsets = table.freeze({
	Vector3.new(0, 0, 4.75),
	Vector3.new(-3, 0, 6.25),
	Vector3.new(3, 0, 6.25),
})

PetRuntimeConfig.RaycastInterval = 0.1
PetRuntimeConfig.RaycastHeight = 8
PetRuntimeConfig.RaycastDepth = 28
PetRuntimeConfig.FollowResponsiveness = 9
PetRuntimeConfig.TeleportDistance = 30
PetRuntimeConfig.MoveThreshold = 1.25

PetRuntimeConfig.Profiles = table.freeze({
	FrostBunny = table.freeze({Mode = "Ground", Style = "Hop", Pace = 7.2, RootMotion = 0.16, BodyMotion = 0.055, AccentMotion = 0.11}),
	ChibiCat = table.freeze({Mode = "Ground", Style = "Trot", Pace = 8.2, RootMotion = 0.07, BodyMotion = 0.045, AccentMotion = 0.16}),
	FluffDog = table.freeze({Mode = "Ground", Style = "Bounce", Pace = 7.5, RootMotion = 0.10, BodyMotion = 0.055, AccentMotion = 0.20}),
	FrostFox = table.freeze({Mode = "Ground", Style = "Bound", Pace = 7.8, RootMotion = 0.11, BodyMotion = 0.05, AccentMotion = 0.15}),
	StormOwl = table.freeze({Mode = "Hover", Style = "Wingbeat", Pace = 4.8, RootMotion = 0.12, BodyMotion = 0.04, AccentMotion = 0.20, HoverHeight = 1.25}),
	AuraDragon = table.freeze({Mode = "Ground", Style = "Stride", Pace = 6.8, RootMotion = 0.035, BodyMotion = 0.035, AccentMotion = 0.10}),
})

return table.freeze(PetRuntimeConfig)
