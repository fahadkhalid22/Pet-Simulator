--!strict

local TweenService = game:GetService("TweenService")

local UIConfig = require(script.Parent.Parent:WaitForChild("Shared"):WaitForChild("UIConfig"))

local UIBuilder = {}
local colors = UIConfig.Colors

local function addCorner(parent: GuiObject, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
end

local function addStroke(parent: GuiObject, color: Color3, thickness: number?)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness or UIConfig.Layout.StrokeThickness
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
end

local function addTextConstraint(parent: TextLabel | TextButton, minimum: number, maximum: number)
	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MinTextSize = minimum
	constraint.MaxTextSize = maximum
	constraint.Parent = parent
end

local function createLabel(parent: Instance, name: string, text: string): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = colors.Ink
	label.TextScaled = true
	label.Parent = parent
	addTextConstraint(label, 12, 28)
	return label
end

local function tweenScale(scale: UIScale, value: number)
	TweenService:Create(
		scale,
		TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Scale = value }
	):Play()
end

local function createButton(
	parent: Instance,
	name: string,
	text: string,
	color: Color3,
	size: UDim2
): TextButton
	local button = Instance.new("TextButton")
	button.Name = name
	button.AutoButtonColor = false
	button.BackgroundColor3 = color
	button.Font = Enum.Font.GothamBold
	button.Size = size
	button.Text = text
	button.TextColor3 = colors.Ink
	button.TextScaled = true
	button.Parent = parent
	addCorner(button, UIConfig.Layout.SmallCornerRadius)
	addStroke(button, colors.Ink, 2)
	addTextConstraint(button, 12, 22)

	local scale = Instance.new("UIScale")
	scale.Parent = button
	button.MouseEnter:Connect(function()
		if button.Active then
			tweenScale(scale, 1.04)
		end
	end)
	button.MouseLeave:Connect(function()
		tweenScale(scale, 1)
	end)
	button.InputBegan:Connect(function(input)
		if button.Active and (input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch) then
			tweenScale(scale, 0.96)
		end
	end)
	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			tweenScale(scale, 1)
		end
	end)
	return button
end

function UIBuilder.SetButtonEnabled(button: TextButton, enabled: boolean)
	button.Active = enabled
	button.TextTransparency = if enabled then 0 else 0.35
	button.BackgroundTransparency = if enabled then 0 else 0.25
end

local function createStatusHud(screenGui: ScreenGui): (TextLabel, TextLabel, TextLabel)
	local coinFrame = Instance.new("Frame")
	coinFrame.Name = "CoinPill"
	coinFrame.AnchorPoint = Vector2.new(1, 0)
	coinFrame.BackgroundColor3 = colors.Peach
	coinFrame.Position = UDim2.new(1, -20, 0, 18)
	coinFrame.Size = UDim2.fromOffset(230, 68)
	coinFrame.Parent = screenGui
	addCorner(coinFrame, 20)
	addStroke(coinFrame, colors.Ink)

	local coinLabel = createLabel(coinFrame, "CoinLabel", "Coins: --")
	coinLabel.Position = UDim2.fromScale(0.05, 0.08)
	coinLabel.Size = UDim2.fromScale(0.9, 0.55)
	coinLabel.TextXAlignment = Enum.TextXAlignment.Right

	local incomeLabel = createLabel(coinFrame, "IncomeLabel", "+0 / sec")
	incomeLabel.Font = Enum.Font.GothamMedium
	incomeLabel.Position = UDim2.fromScale(0.05, 0.62)
	incomeLabel.Size = UDim2.fromScale(0.9, 0.28)
	incomeLabel.TextColor3 = colors.Muted
	incomeLabel.TextXAlignment = Enum.TextXAlignment.Right
	addTextConstraint(incomeLabel, 11, 17)

	local equippedFrame = Instance.new("Frame")
	equippedFrame.Name = "EquippedPill"
	equippedFrame.AnchorPoint = Vector2.new(1, 0)
	equippedFrame.BackgroundColor3 = colors.SkyBlue
	equippedFrame.Position = UDim2.new(1, -20, 0, 98)
	equippedFrame.Size = UDim2.fromOffset(180, 52)
	equippedFrame.Parent = screenGui
	addCorner(equippedFrame, 18)
	addStroke(equippedFrame, colors.Ink)

	local equippedLabel = createLabel(equippedFrame, "EquippedLabel", "Pets: -- / --")
	equippedLabel.Position = UDim2.fromScale(0.06, 0.12)
	equippedLabel.Size = UDim2.fromScale(0.88, 0.76)

	return coinLabel, incomeLabel, equippedLabel
end

local function createNavigation(screenGui: ScreenGui): (TextButton, TextButton)
	local navigation = Instance.new("Frame")
	navigation.Name = "Navigation"
	navigation.AnchorPoint = Vector2.new(0, 0.5)
	navigation.BackgroundTransparency = 1
	navigation.Position = UDim2.new(0, 18, 0.5, 0)
	navigation.Size = UDim2.fromOffset(78, 148)
	navigation.Parent = screenGui

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 14)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = navigation

	local inventoryButton = createButton(
		navigation,
		"InventoryButton",
		"PETS",
		colors.SkyBlue,
		UDim2.fromOffset(72, 64)
	)
	inventoryButton.LayoutOrder = 1

	local shopButton = createButton(
		navigation,
		"ShopButton",
		"SHOP",
		colors.Mint,
		UDim2.fromOffset(72, 64)
	)
	shopButton.LayoutOrder = 2

	return inventoryButton, shopButton
end

local function createModalShell(
	screenGui: ScreenGui
): (Frame, TextButton, Frame, TextLabel, TextButton)
	local overlay = Instance.new("Frame")
	overlay.Name = "ModalOverlay"
	overlay.BackgroundTransparency = 1
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.Visible = false
	overlay.Parent = screenGui

	local backdrop = Instance.new("TextButton")
	backdrop.Name = "Backdrop"
	backdrop.AutoButtonColor = false
	backdrop.BackgroundColor3 = colors.Backdrop
	backdrop.BackgroundTransparency = 0.35
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.Text = ""
	backdrop.Parent = overlay

	local panel = Instance.new("Frame")
	panel.Name = "ModalPanel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.BackgroundColor3 = colors.Lavender
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromScale(0.78, 0.82)
	panel.ZIndex = 2
	panel.Parent = overlay
	addCorner(panel, 20)
	addStroke(panel, colors.Ink, 4)

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MinSize = Vector2.new(340, 320)
	sizeConstraint.MaxSize = Vector2.new(UIConfig.Layout.ModalMaxWidth, UIConfig.Layout.ModalMaxHeight)
	sizeConstraint.Parent = panel

	local title = createLabel(panel, "Title", "PETS")
	title.Position = UDim2.new(0, 24, 0, 14)
	title.Size = UDim2.new(1, -100, 0, 48)
	title.TextXAlignment = Enum.TextXAlignment.Left

	local closeButton = createButton(
		panel,
		"CloseButton",
		"X",
		colors.Coral,
		UDim2.fromOffset(UIConfig.Layout.MinimumTouchSize, UIConfig.Layout.MinimumTouchSize)
	)
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -14, 0, 10)

	return overlay, backdrop, panel, title, closeButton
end

local function createModalContent(
	panel: Frame
): (TextLabel, ScrollingFrame, UIGridLayout, TextLabel)
	local statusLabel = createLabel(panel, "StatusLabel", "Loading pets...")
	statusLabel.Font = Enum.Font.GothamMedium
	statusLabel.Position = UDim2.new(0, 24, 0, 68)
	statusLabel.Size = UDim2.new(1, -48, 0, 28)
	statusLabel.TextColor3 = colors.Muted
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	addTextConstraint(statusLabel, 11, 17)

	local scrolling = Instance.new("ScrollingFrame")
	scrolling.Name = "CardScroller"
	scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrolling.BackgroundColor3 = colors.White
	scrolling.BackgroundTransparency = 0.08
	scrolling.BorderSizePixel = 0
	scrolling.CanvasSize = UDim2.fromOffset(0, 0)
	scrolling.Position = UDim2.new(0, 20, 0, 104)
	scrolling.ScrollBarImageColor3 = colors.Muted
	scrolling.ScrollBarThickness = 8
	scrolling.Size = UDim2.new(1, -40, 1, -124)
	scrolling.Parent = panel
	addCorner(scrolling, UIConfig.Layout.CornerRadius)

	local padding = Instance.new("UIPadding")
	padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.PaddingTop = UDim.new(0, 12)
	padding.Parent = scrolling

	local grid = Instance.new("UIGridLayout")
	grid.CellPadding = UDim2.fromOffset(12, 12)
	grid.CellSize = UDim2.new(0.31, -8, 0, UIConfig.Layout.CardHeight)
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = scrolling

	local emptyLabel = createLabel(panel, "EmptyLabel", "No pets to show yet.")
	emptyLabel.Position = UDim2.new(0.12, 0, 0.42, 0)
	emptyLabel.Size = UDim2.fromScale(0.76, 0.16)
	emptyLabel.TextColor3 = colors.Muted
	emptyLabel.Visible = false

	return statusLabel, scrolling, grid, emptyLabel
end

local function createPetPreview(card: Frame, definition: any)
	local rarityColor = UIConfig.GetRarityColor(definition.Rarity)
	local preview = Instance.new("Frame")
	preview.Name = "Preview"
	preview.BackgroundColor3 = rarityColor:Lerp(colors.White, 0.45)
	preview.Position = UDim2.new(0, 10, 0, 10)
	preview.Size = UDim2.new(1, -20, 0, 84)
	preview.Parent = card
	addCorner(preview, UIConfig.Layout.SmallCornerRadius)

	local petMark = createLabel(preview, "PetMark", string.sub(definition.DisplayName, 1, 1))
	petMark.AnchorPoint = Vector2.new(0.5, 0.5)
	petMark.Position = UDim2.fromScale(0.5, 0.5)
	petMark.Size = UDim2.fromOffset(64, 64)
	petMark.TextColor3 = rarityColor
	addTextConstraint(petMark, 30, 52)

	local rarity = createLabel(preview, "Rarity", string.upper(definition.Rarity))
	rarity.AnchorPoint = Vector2.new(1, 0)
	rarity.BackgroundColor3 = rarityColor
	rarity.BackgroundTransparency = 0.08
	rarity.Position = UDim2.new(1, -6, 0, 6)
	rarity.Size = UDim2.fromOffset(90, 26)
	rarity.TextColor3 = colors.Ink
	addCorner(rarity, 8)
	addTextConstraint(rarity, 10, 14)
end

function UIBuilder.CreatePetCard(
	parent: Instance,
	definition: any,
	actionText: string,
	actionColor: Color3,
	detailText: string
): (Frame, TextButton)
	local card = Instance.new("Frame")
	card.Name = definition.Id .. "Card"
	card.BackgroundColor3 = colors.White
	card.LayoutOrder = definition.SortOrder or 0
	card.Parent = parent
	addCorner(card, UIConfig.Layout.CornerRadius)
	addStroke(card, UIConfig.GetRarityColor(definition.Rarity), 3)
	createPetPreview(card, definition)

	local nameLabel = createLabel(card, "PetName", definition.DisplayName)
	nameLabel.Position = UDim2.new(0, 10, 0, 100)
	nameLabel.Size = UDim2.new(1, -20, 0, 28)
	addTextConstraint(nameLabel, 14, 22)

	local incomeLabel = createLabel(
		card,
		"Income",
		string.format("+%d coins / sec", definition.PassiveIncome)
	)
	incomeLabel.Position = UDim2.new(0, 10, 0, 130)
	incomeLabel.Size = UDim2.new(1, -20, 0, 22)
	incomeLabel.TextColor3 = colors.GreenShadow
	addTextConstraint(incomeLabel, 11, 16)

	local detailLabel = createLabel(card, "Detail", detailText)
	detailLabel.Font = Enum.Font.GothamMedium
	detailLabel.Position = UDim2.new(0, 10, 0, 156)
	detailLabel.Size = UDim2.new(1, -20, 0, 22)
	detailLabel.TextColor3 = colors.Muted
	addTextConstraint(detailLabel, 10, 15)

	local actionButton = createButton(
		card,
		"ActionButton",
		actionText,
		actionColor,
		UDim2.new(1, -20, 0, UIConfig.Layout.MinimumTouchSize)
	)
	actionButton.Position = UDim2.new(0, 10, 1, -(UIConfig.Layout.MinimumTouchSize + 10))
	return card, actionButton
end

function UIBuilder.Create(playerGui: PlayerGui): {[string]: any}
	local previous = playerGui:FindFirstChild("AuralitUI")
	if previous then
		previous:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AuralitUI"
	screenGui.DisplayOrder = 20
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	local coinLabel, incomeLabel, equippedLabel = createStatusHud(screenGui)
	local inventoryButton, shopButton = createNavigation(screenGui)
	local overlay, backdrop, panel, title, closeButton = createModalShell(screenGui)
	local statusLabel, scrolling, grid, emptyLabel = createModalContent(panel)

	local notificationLayer = Instance.new("Frame")
	notificationLayer.Name = "NotificationLayer"
	notificationLayer.AnchorPoint = Vector2.new(0.5, 0)
	notificationLayer.BackgroundTransparency = 1
	notificationLayer.Position = UDim2.fromScale(0.5, 0.03)
	notificationLayer.Size = UDim2.new(0.7, 0, 0, 180)
	notificationLayer.Parent = screenGui

	local notificationConstraint = Instance.new("UISizeConstraint")
	notificationConstraint.MinSize = Vector2.new(220, 180)
	notificationConstraint.MaxSize = Vector2.new(520, 180)
	notificationConstraint.Parent = notificationLayer

	local notificationLayout = Instance.new("UIListLayout")
	notificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	notificationLayout.Padding = UDim.new(0, 8)
	notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
	notificationLayout.Parent = notificationLayer

	return {
		ScreenGui = screenGui,
		CoinLabel = coinLabel,
		IncomeLabel = incomeLabel,
		EquippedLabel = equippedLabel,
		InventoryButton = inventoryButton,
		ShopButton = shopButton,
		ModalOverlay = overlay,
		Backdrop = backdrop,
		ModalPanel = panel,
		ModalTitle = title,
		CloseButton = closeButton,
		StatusLabel = statusLabel,
		CardScroller = scrolling,
		CardGrid = grid,
		EmptyLabel = emptyLabel,
		NotificationLayer = notificationLayer,
	}
end

function UIBuilder.UpdateGrid(grid: UIGridLayout, viewportWidth: number)
	if viewportWidth < 700 then
		grid.CellSize = UDim2.new(1, -4, 0, UIConfig.Layout.CardHeight)
	elseif viewportWidth < 1100 then
		grid.CellSize = UDim2.new(0.48, -6, 0, UIConfig.Layout.CardHeight)
	else
		grid.CellSize = UDim2.new(0.31, -8, 0, UIConfig.Layout.CardHeight)
	end
end

function UIBuilder.ShowToast(notificationLayer: Frame, message: string, isError: boolean?)
	local toast = Instance.new("Frame")
	toast.Name = "Toast"
	toast.BackgroundColor3 = if isError then colors.Coral else colors.Mint
	toast.Size = UDim2.new(1, 0, 0, 52)
	toast.ZIndex = 20
	toast.Parent = notificationLayer
	addCorner(toast, UIConfig.Layout.SmallCornerRadius)
	addStroke(toast, colors.Ink, 2)

	local label = createLabel(toast, "Message", message)
	label.Position = UDim2.new(0, 12, 0, 6)
	label.Size = UDim2.new(1, -24, 1, -12)
	label.ZIndex = 21
	addTextConstraint(label, 11, 18)

	local scale = Instance.new("UIScale")
	scale.Scale = 0.85
	scale.Parent = toast
	TweenService:Create(
		scale,
		TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 }
	):Play()

	task.delay(2.4, function()
		if not toast.Parent then
			return
		end
		TweenService:Create(toast, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(label, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
		task.delay(0.22, function()
			toast:Destroy()
		end)
	end)
end

function UIBuilder.ShowIncomePopup(screenGui: ScreenGui, amount: number)
	local popup = createLabel(screenGui, "IncomePopup", string.format("+%d COINS", amount))
	popup.AnchorPoint = Vector2.new(1, 0)
	popup.BackgroundColor3 = colors.Gold
	popup.BackgroundTransparency = 0.08
	popup.Position = UDim2.new(1, -20, 0, 152)
	popup.Size = UDim2.fromOffset(160, 40)
	popup.ZIndex = 10
	addCorner(popup, UIConfig.Layout.SmallCornerRadius)
	addStroke(popup, colors.Ink, 2)
	addTextConstraint(popup, 12, 18)

	local tween = TweenService:Create(
		popup,
		TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -20, 0, 122),
			TextTransparency = 1,
		}
	)
	tween:Play()
	tween.Completed:Once(function()
		popup:Destroy()
	end)
end

return table.freeze(UIBuilder)
