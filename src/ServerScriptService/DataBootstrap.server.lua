--!strict

local DataService = require(script.Parent:WaitForChild("Services"):WaitForChild("DataService"))
local PetService = require(script.Parent:WaitForChild("Services"):WaitForChild("PetService"))

PetService.Start()
DataService.Start()
