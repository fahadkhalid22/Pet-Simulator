--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
local shared = ReplicatedStorage:WaitForChild("Shared")
local clientModules = ReplicatedStorage:WaitForChild("Client")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local PetConfig = require(shared:WaitForChild("PetConfig"))
local UIConfig = require(shared:WaitForChild("UIConfig"))
local UIBuilder = require(clientModules:WaitForChild("UIBuilder"))

local petRequest = remotes:WaitForChild("PetRequest") :: RemoteFunction
local petStateChanged = remotes:WaitForChild("PetStateChanged") :: RemoteEvent
local passiveIncomeAwarded = remotes:WaitForChild("PassiveIncomeAwarded") :: RemoteEvent

local refs = UIBuilder.Create(playerGui)
local colors = UIConfig.Colors
local currentState: {[string]: any}? = nil
local activeView: string? = nil
local requestBusy = false
local shopButtons: {[string]: TextButton} = {}

local errorMessages: {[string]: string} = table.freeze({
	DATA_NOT_LOADED = "Your pet data is still loading.",
	DATA_UNAVAILABLE = "Pet data is temporarily unavailable.",
	INSUFFICIENT_COINS = "You need more coins for that pet.",
	INTERNAL_ERROR = "The pet service had a problem. Try again.",
	INVENTORY_FULL = "Your pet inventory is full.",
	NOT_EQUIPPED = "That pet is already unequipped.",
	PET_ALREADY_EQUIPPED = "That pet is already equipped.",
	PET_NOT_OWNED = "That pet is not in your inventory.",
	RATE_LIMITED = "Please wait a moment before trying again.",
	TOO_MANY_EQUIPPED = "Unequip a pet before equipping another.",
	UNKNOWN_PET = "That pet is no longer available.",
})

local function formatNumber(value: any): string
	local numberValue = if type(value) == "number" then math.max(0, math.floor(value)) else 0
	local suffixes = { "", "K", "M", "B", "T", "Q" }
	local suffixIndex = 1
	local scaled = numberValue
	while scaled >= 1_000 and suffixIndex < #suffixes do
		scaled /= 1_000
		suffixIndex += 1
	end
	if suffixIndex == 1 then
		return string.format("%d", numberValue)
	end
	local formatted = string.format("%.1f", scaled):gsub("%.0$", "")
	return formatted .. suffixes[suffixIndex]
end

local function currentCoins(): number
	local attributeCoins = player:GetAttribute("Coins")
	if type(attributeCoins) == "number" then
		return attributeCoins
	end
	local state = currentState
	return if state then state.Coins else 0
end

local function updateShopAffordability()
	local coins = currentCoins()
	refs.StatusLabel.Text = "Balance: " .. formatNumber(coins) .. " coins"
	for petId, button in pairs(shopButtons) do
		local definition = PetConfig.Get(petId)
		if definition and button.Parent then
			local canAfford = coins >= definition.Cost
			button.Text = if canAfford
				then "BUY"
				else "NEED " .. formatNumber(definition.Cost - coins)
			UIBuilder.SetButtonEnabled(button, canAfford)
		end
	end
end

local function updateHud()
	local state = currentState
	local coins = player:GetAttribute("Coins")
	local income = player:GetAttribute("PassiveIncomePerSecond")
	local equippedCount = player:GetAttribute("EquippedPetCount")
	local maxEquipped: any = "--"

	if state then
		coins = if type(coins) == "number" then coins else state.Coins
		income = if type(income) == "number" then income else state.PassiveIncome
		equippedCount = if type(equippedCount) == "number" then equippedCount else #state.Equipped
		maxEquipped = state.MaxEquipped
	end

	refs.CoinLabel.Text = "Coins: " .. formatNumber(coins)
	refs.IncomeLabel.Text = "+" .. formatNumber(income) .. " / sec"
	refs.EquippedLabel.Text = string.format(
		"Pets: %s / %s",
		formatNumber(equippedCount),
		tostring(maxEquipped)
	)
end

local function clearCards()
	table.clear(shopButtons)
	for _, child in refs.CardScroller:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

local function equippedSet(state: {[string]: any}): {[string]: boolean}
	local result: {[string]: boolean} = {}
	for _, uid in state.Equipped do
		if type(uid) == "string" then
			result[uid] = true
		end
	end
	return result
end

local function showRequestError(code: any)
	local safeCode = if type(code) == "string" then code else "INTERNAL_ERROR"
	UIBuilder.ShowToast(
		refs.NotificationLayer,
		errorMessages[safeCode] or "That pet action could not be completed.",
		true
	)
end

local renderActiveView: (() -> ())? = nil

local function isPetState(value: any): boolean
	return type(value) == "table"
		and type(value.Coins) == "number"
		and type(value.Owned) == "table"
		and type(value.Equipped) == "table"
		and type(value.MaxEquipped) == "number"
		and type(value.PassiveIncome) == "number"
end

local function applyState(state: any)
	if not isPetState(state) then
		return
	end
	currentState = state
	updateHud()
	local render = renderActiveView
	if activeView and render then
		render()
	end
end

local function requestPetAction(action: string, value: string, successMessage: string)
	if requestBusy then
		return
	end
	requestBusy = true
	local invoked, response = pcall(function()
		return petRequest:InvokeServer(action, value)
	end)
	requestBusy = false

	if not invoked or type(response) ~= "table" then
		showRequestError("INTERNAL_ERROR")
		return
	end
	if response.Success ~= true then
		showRequestError(response.Code)
		return
	end
	if response.State then
		applyState(response.State)
	end
	UIBuilder.ShowToast(refs.NotificationLayer, successMessage, false)
end

local function renderShop()
	clearCards()
	refs.ModalTitle.Text = "PET SHOP"
	refs.EmptyLabel.Visible = false
	local state = currentState
	if not state then
		refs.StatusLabel.Text = "Loading the pet shop..."
		return
	end

	local cardCount = 0
	for _, definition in PetConfig.GetAll() do
		if definition.Purchasable then
			cardCount += 1
			local petId = definition.Id
			local displayName = definition.DisplayName
			local _, actionButton = UIBuilder.CreatePetCard(
				refs.CardScroller,
				definition,
				"BUY",
				colors.Mint,
				"Cost: " .. formatNumber(definition.Cost) .. " coins"
			)
			shopButtons[petId] = actionButton
			actionButton.Activated:Connect(function()
				requestPetAction("Purchase", petId, displayName .. " joined your pets!")
			end)
		end
	end
	updateShopAffordability()
	refs.EmptyLabel.Visible = cardCount == 0
end

local function renderInventory()
	clearCards()
	refs.ModalTitle.Text = "YOUR PETS"
	refs.EmptyLabel.Visible = false
	local state = currentState
	if not state then
		refs.StatusLabel.Text = "Loading your pets..."
		return
	end

	local equipped = equippedSet(state)
	refs.StatusLabel.Text = string.format(
		"%d owned  |  %d / %d equipped",
		#state.Owned,
		#state.Equipped,
		state.MaxEquipped
	)
	local cardCount = 0
	for _, ownedPet in state.Owned do
		local definition = if type(ownedPet) == "table" then PetConfig.Get(ownedPet.PetId) else nil
		local uid = if type(ownedPet) == "table" then ownedPet.Uid else nil
		if definition and type(uid) == "string" then
			cardCount += 1
			local isEquipped = equipped[uid] == true
			local action = if isEquipped then "UNEQUIP" else "EQUIP"
			local actionColor = if isEquipped then colors.Peach else colors.SkyBlue
			local detail = if isEquipped then "Currently equipped" else "Ready to equip"
			local _, actionButton = UIBuilder.CreatePetCard(
				refs.CardScroller,
				definition,
				action,
				actionColor,
				detail
			)
			actionButton.Activated:Connect(function()
				if isEquipped then
					requestPetAction("Unequip", uid, definition.DisplayName .. " unequipped.")
				else
					requestPetAction("Equip", uid, definition.DisplayName .. " equipped!")
				end
			end)
		end
	end
	refs.EmptyLabel.Visible = cardCount == 0
end

renderActiveView = function()
	if activeView == "Shop" then
		renderShop()
	elseif activeView == "Inventory" then
		renderInventory()
	end
end

local function closeModal()
	activeView = nil
	refs.ModalOverlay.Visible = false
end

local function openView(viewName: string)
	if refs.ModalOverlay.Visible and activeView == viewName then
		closeModal()
		return
	end
	activeView = viewName
	refs.ModalOverlay.Visible = true
	refs.CardScroller.CanvasPosition = Vector2.zero
	local render = renderActiveView
	if render then
		render()
	end
end

refs.InventoryButton.Activated:Connect(function()
	openView("Inventory")
end)
refs.ShopButton.Activated:Connect(function()
	openView("Shop")
end)
refs.CloseButton.Activated:Connect(closeModal)
refs.Backdrop.Activated:Connect(closeModal)

petStateChanged.OnClientEvent:Connect(function(state)
	applyState(state)
end)

passiveIncomeAwarded.OnClientEvent:Connect(function(amount, _rate)
	if type(amount) == "number" and amount > 0 then
		UIBuilder.ShowIncomePopup(refs.ScreenGui, math.floor(amount))
	end
end)

player:GetAttributeChangedSignal("Coins"):Connect(function()
	updateHud()
	if activeView == "Shop" then
		updateShopAffordability()
	end
end)
player:GetAttributeChangedSignal("PassiveIncomePerSecond"):Connect(updateHud)
player:GetAttributeChangedSignal("EquippedPetCount"):Connect(updateHud)

local viewportConnection: RBXScriptConnection? = nil
local function bindViewport()
	if viewportConnection then
		viewportConnection:Disconnect()
		viewportConnection = nil
	end
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local function updateGrid()
		UIBuilder.UpdateGrid(refs.CardGrid, camera.ViewportSize.X)
	end
	updateGrid()
	viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateGrid)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindViewport)
bindViewport()
updateHud()

task.spawn(function()
	while player:GetAttribute("DataLoaded") ~= true do
		if player:GetAttribute("DataLoadFailed") == true then
			UIBuilder.ShowToast(
				refs.NotificationLayer,
				"Your saved data could not be loaded.",
				true
			)
			return
		end
		task.wait(0.1)
	end

	for attempt = 1, 3 do
		requestBusy = true
		local invoked, response = pcall(function()
			return petRequest:InvokeServer("GetState")
		end)
		requestBusy = false
		if invoked and type(response) == "table" and response.Success == true then
			applyState(response.State)
			return
		end
		if attempt < 3 then
			task.wait(0.6)
		elseif invoked and type(response) == "table" then
			showRequestError(response.Code)
		else
			showRequestError("INTERNAL_ERROR")
		end
	end
end)
