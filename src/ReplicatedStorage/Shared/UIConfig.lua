--!strict

local colors = table.freeze({
	Mint = Color3.fromRGB(168, 230, 207),
	Lavender = Color3.fromRGB(222, 210, 249),
	SkyBlue = Color3.fromRGB(160, 210, 235),
	Peach = Color3.fromRGB(255, 211, 182),
	Ink = Color3.fromRGB(45, 37, 63),
	White = Color3.fromRGB(255, 255, 255),
	Gold = Color3.fromRGB(255, 190, 11),
	Coral = Color3.fromRGB(255, 154, 162),
	GreenShadow = Color3.fromRGB(114, 197, 163),
	BlueShadow = Color3.fromRGB(111, 170, 199),
	Muted = Color3.fromRGB(116, 105, 137),
	Backdrop = Color3.fromRGB(28, 23, 40),
})

local rarityColors: {[string]: Color3} = table.freeze({
	Common = Color3.fromRGB(229, 229, 229),
	Rare = Color3.fromRGB(58, 134, 255),
	Epic = Color3.fromRGB(131, 56, 236),
	Legendary = Color3.fromRGB(255, 190, 11),
})

local UIConfig = {
	Colors = colors,
	RarityColors = rarityColors,
	Layout = table.freeze({
		CornerRadius = 14,
		SmallCornerRadius = 10,
		StrokeThickness = 3,
		MinimumTouchSize = 56,
		ModalMaxWidth = 900,
		ModalMaxHeight = 640,
		CardHeight = 264,
	}),
}

function UIConfig.GetRarityColor(rarity: any): Color3
	if type(rarity) ~= "string" then
		return rarityColors.Common
	end
	return rarityColors[rarity] or rarityColors.Common
end

return table.freeze(UIConfig)
