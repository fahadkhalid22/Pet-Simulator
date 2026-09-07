--!strict

local DataService = require(script.Parent:WaitForChild("Services"):WaitForChild("DataService"))
local PetService = require(script.Parent:WaitForChild("Services"):WaitForChild("PetService"))
local PetRuntimeService = require(script.Parent:WaitForChild("Services"):WaitForChild("PetRuntimeService"))

PetService.Start()
PetRuntimeService.Start()
DataService.Start()
