param(
	[string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$culture = [Globalization.CultureInfo]::InvariantCulture

$pets = @(
	@{
		Id = "FluffDog"; Name = "Fluff Dog"; Rarity = "Common"; Rate = 10; Reference = "ref_dog.png"
		MeshCritical = @(
			"Body", "Head", "LeftEar", "RightEar", "FaceBlaze", "LeftMuzzle", "RightMuzzle",
			"LeftEye", "RightEye", "LeftIris", "RightIris", "LeftEyeHighlight", "RightEyeHighlight",
			"LeftBrow", "RightBrow", "LeftCheek", "RightCheek", "Nose", "Mouth", "Tongue", "Chest",
			"LeftFrontLeg", "RightFrontLeg", "LeftFrontPaw", "RightFrontPaw", "LeftRearLeg", "RightRearLeg",
			"LeftRearPaw", "RightRearPaw", "Tail", "TailTip"
		)
		MeshPartCount = 31
		Attachments = @("SilverDustAttachment")
		Effects = @("SilverDust")
		EffectClasses = @("ParticleEmitter")
		MaxParticleRate = 8
	},
	@{
		Id = "ChibiCat"; Name = "Chibi Cat"; Rarity = "Common"; Rate = 10; Reference = "ref_cat.png"
		MeshCritical = @(
			"Body", "Head", "LeftOuterEar", "RightOuterEar", "LeftInnerEar", "RightInnerEar",
			"LeftMuzzle", "RightMuzzle", "ForeheadBlaze", "LeftEye", "RightEye", "LeftEyeRing", "RightEyeRing",
			"LeftEyeHighlight", "RightEyeHighlight", "Nose", "Mouth", "Chest", "LeftFrontLeg", "RightFrontLeg",
			"LeftFrontPaw", "RightFrontPaw", "LeftHaunch", "RightHaunch", "LeftToe1", "LeftToe2", "LeftToe3",
			"RightToe1", "RightToe2", "RightToe3", "Tail"
		)
		MeshPartCount = 31
		Attachments = @("SilverDustAttachment")
		Effects = @("SilverDust")
		EffectClasses = @("ParticleEmitter")
		MaxParticleRate = 8
	},
	@{
		Id = "FrostBunny"; Name = "Frost Bunny"; Rarity = "Rare"; Rate = 25; Reference = "ref_bunny.png"
		MeshCritical = @(
			"Body", "Head", "LeftEar", "RightEar", "LeftInnerEar", "RightInnerEar",
			"LeftEye", "RightEye", "LeftEyeHighlight", "RightEyeHighlight", "Nose",
			"LeftMuzzle", "RightMuzzle", "LeftCheek", "RightCheek", "Mouth",
			"LeftArm", "RightArm", "LeftLeg", "RightLeg", "LeftFoot", "RightFoot",
			"LeftPawPad", "RightPawPad", "LeftToePad1", "LeftToePad2", "LeftToePad3",
			"RightToePad1", "RightToePad2", "RightToePad3", "Tail"
		)
		MeshPartCount = 31
		Attachments = @("CyanMistAttachment", "SnowSpecksAttachment")
		Effects = @("CyanMist", "SnowSpecks")
		EffectClasses = @("ParticleEmitter", "ParticleEmitter")
		MaxParticleRate = 12
	},
	@{
		Id = "StormOwl"; Name = "Storm Owl"; Rarity = "Epic"; Rate = 50; Reference = "ref_owl.png"
		MeshCritical = @(
			"Body", "Head", "LeftEyeDisc", "RightEyeDisc", "LeftEye", "RightEye", "LeftEyeHighlight", "RightEyeHighlight",
			"Beak", "ChestUpper", "ChestLeft", "ChestRight", "ChestLower", "LeftWingBase", "LeftWingUpper",
			"LeftWingMiddle", "LeftWingLower", "LeftWingTip", "RightWingBase", "RightWingUpper", "RightWingMiddle",
			"RightWingLower", "RightWingTip", "LeftLeg", "RightLeg", "LeftFoot", "RightFoot", "LeftTalon1",
			"LeftTalon2", "LeftTalon3", "RightTalon1", "RightTalon2", "RightTalon3", "TailLeft", "TailCenter", "TailRight"
		)
		MeshPartCount = 36
		Attachments = @("VioletSparklesAttachment", "EpicAuraLightAttachment")
		Effects = @("VioletSparkles", "EpicAuraLight")
		EffectClasses = @("ParticleEmitter", "PointLight")
		MaxParticleRate = 5
	},
	@{
		Id = "FrostFox"; Name = "Frost Fox"; Rarity = "Epic"; Rate = 50; Reference = "ref_frost_fox.png"
		MeshCritical = @(
			"Body", "Head", "LeftOuterEar", "RightOuterEar", "LeftInnerEar", "RightInnerEar", "LeftEye", "RightEye",
			"LeftEyeHighlight", "RightEyeHighlight", "Nose", "LeftCheekFur", "RightCheekFur", "ForeheadTuftCenter",
			"ForeheadTuftLeft", "ForeheadTuftRight", "ChestRuffUpper", "ChestRuffLeft", "ChestRuffRight", "ChestRuffLower",
			"LeftFrontLeg", "RightFrontLeg", "LeftRearLeg", "RightRearLeg", "LeftFrontPaw", "RightFrontPaw",
			"LeftRearPaw", "RightRearPaw", "TailRoot", "TailPlume", "TailTip"
		)
		MeshPartCount = 31
		Attachments = @("VioletSparklesAttachment", "FrostSpecksAttachment", "EpicAuraLightAttachment")
		Effects = @("VioletSparkles", "FrostSpecks", "EpicAuraLight")
		EffectClasses = @("ParticleEmitter", "ParticleEmitter", "PointLight")
		MaxParticleRate = 10
	},
	@{
		Id = "AuraDragon"; Name = "Aura Dragon"; Rarity = "Legendary"; Rate = 100; Reference = "ref_aura_dragon.png"
		MeshCritical = @(
			"Body", "TorsoArmor", "Collar", "Head", "FaceMask", "LeftEye", "RightEye", "HelmetDome", "HelmetBand",
			"HelmetCrest", "LeftHelmetPillar", "RightHelmetPillar", "LeftHelmetRune", "RightHelmetRune", "LeftShoulder",
			"RightShoulder", "LeftArm", "RightArm", "LeftCuff", "RightCuff", "LeftHand", "RightHand", "LeftLeg", "RightLeg",
			"LeftBoot", "RightBoot", "LeftCoatPanel", "RightCoatPanel", "Belt", "ChestRune", "LeftSleeveRune", "RightSleeveRune",
			"LeftLegRune", "RightLegRune", "StaffShaft", "StaffLowerGrip", "StaffUpperGrip", "StaffCrown", "StaffLeftProng",
			"StaffRightProng", "StaffLeftClaw", "StaffRightClaw", "StaffFlameCore", "StaffFlameLeft", "StaffFlameRight", "StaffTip"
		)
		MeshPartCount = 46
		Attachments = @("GoldShimmerAttachment", "CyanSoulfireAttachment", "LegendaryAuraLightAttachment")
		Effects = @("GoldShimmer", "CyanSoulfire", "LegendaryAuraLight")
		EffectClasses = @("ParticleEmitter", "ParticleEmitter", "PointLight")
		MaxParticleRate = 9
	}
)

function Assert-Condition([bool]$Condition, [string]$Message) {
	if (-not $Condition) {
		throw $Message
	}
}

function Read-BlobString([IO.BinaryReader]$Reader) {
	$length = $Reader.ReadUInt32()
	return [Text.Encoding]::UTF8.GetString($Reader.ReadBytes($length))
}

function Read-Attributes([string]$Base64) {
	$stream = [IO.MemoryStream]::new([Convert]::FromBase64String($Base64))
	$reader = [IO.BinaryReader]::new($stream)
	$attributes = @{}
	try {
		$count = $reader.ReadUInt32()
		for ($index = 0; $index -lt $count; $index++) {
			$name = Read-BlobString $reader
			$type = $reader.ReadByte()
			$value = switch ($type) {
				2 { Read-BlobString $reader }
				3 { $reader.ReadByte() -ne 0 }
				4 { $reader.ReadInt32() }
				5 { $reader.ReadSingle() }
				6 { $reader.ReadDouble() }
				default { throw "Unsupported attribute type $type for $name" }
			}
			$attributes[$name] = $value
		}
		Assert-Condition ($stream.Position -eq $stream.Length) "Attribute blob contains trailing data."
		return $attributes
	}
	finally {
		$reader.Dispose()
		$stream.Dispose()
	}
}

function Read-ModelAttributes([object]$Properties, [string]$Context) {
	$binaryNodes = @($Properties.SelectNodes("BinaryString[@name='AttributesSerialize']"))
	$jsonNodes = @($Properties.SelectNodes("Attributes[@name='Attributes']"))
	Assert-Condition ($binaryNodes.Count + $jsonNodes.Count -eq 1) "$Context must contain exactly one supported metadata property."
	if ($binaryNodes.Count -eq 1) {
		Assert-Condition (-not [string]::IsNullOrWhiteSpace($binaryNodes[0].InnerText)) "$Context metadata attributes are empty."
		return Read-Attributes $binaryNodes[0].InnerText
	}
	$decoded = $jsonNodes[0].InnerText | ConvertFrom-Json
	$attributes = @{}
	foreach ($property in $decoded.PSObject.Properties) {
		$attributes[$property.Name] = $property.Value.Value
	}
	return $attributes
}

function Read-FiniteNumber([object]$Node, [string]$Context) {
	$text = if ($Node -is [System.Xml.XmlNode]) { $Node.InnerText } else { [string]$Node }
	$value = [double]::Parse($text, $culture)
	Assert-Condition (-not [double]::IsNaN($value) -and -not [double]::IsInfinity($value)) "$Context is not finite."
	return $value
}

$modelDirectory = Join-Path $RepositoryRoot "src/ServerStorage/PetModels"
$referenceDirectory = Join-Path $RepositoryRoot "assets/references/pets"
$configPath = Join-Path $RepositoryRoot "src/ReplicatedStorage/Shared/PetConfig.lua"
$modelFiles = @(Get-ChildItem -LiteralPath $modelDirectory -File -Filter "*.rbxmx")
$referenceFiles = @(Get-ChildItem -LiteralPath $referenceDirectory -File -Filter "ref_*.png")

Assert-Condition ($modelFiles.Count -eq $pets.Count) "Expected exactly 6 pet model files; found $($modelFiles.Count)."
Assert-Condition ($referenceFiles.Count -eq $pets.Count) "Expected exactly 6 pet references; found $($referenceFiles.Count)."

$config = Get-Content -Raw -LiteralPath $configPath
$allowedV3Classes = @("MeshPart", "Attachment", "ParticleEmitter", "PointLight")
$legacyCount = 0
$v3Count = 0

foreach ($pet in $pets) {
	$modelPath = Join-Path $modelDirectory ($pet.Id + ".rbxmx")
	$referencePath = Join-Path $referenceDirectory $pet.Reference
	Assert-Condition (Test-Path -LiteralPath $modelPath -PathType Leaf) "Missing model file $($pet.Id).rbxmx."
	Assert-Condition (Test-Path -LiteralPath $referencePath -PathType Leaf) "Missing reference $($pet.Reference)."

	$blockPattern = "(?s)definitions\." + [regex]::Escape($pet.Id) + "\s*=\s*table\.freeze\(\{.*?\n\}\)"
	$configBlock = [regex]::Match($config, $blockPattern)
	Assert-Condition $configBlock.Success "PetConfig is missing $($pet.Id)."
	Assert-Condition ($configBlock.Value -match ('Id\s*=\s*"' + [regex]::Escape($pet.Id) + '"')) "PetConfig Id is wrong for $($pet.Id)."
	Assert-Condition ($configBlock.Value -match ('DisplayName\s*=\s*"' + [regex]::Escape($pet.Name) + '"')) "PetConfig DisplayName is wrong for $($pet.Id)."
	Assert-Condition ($configBlock.Value -match ('Rarity\s*=\s*"' + [regex]::Escape($pet.Rarity) + '"')) "PetConfig rarity is wrong for $($pet.Id)."
	Assert-Condition ($configBlock.Value -match ('PassiveIncome\s*=\s*rarityIncome\.' + [regex]::Escape($pet.Rarity))) "PetConfig passive income mapping is wrong for $($pet.Id)."
	Assert-Condition ($configBlock.Value -match ('ModelName\s*=\s*"' + [regex]::Escape($pet.Id) + '"')) "PetConfig model mapping is wrong for $($pet.Id)."

	[xml]$xml = Get-Content -Raw -LiteralPath $modelPath
	$model = $xml.roblox.Item
	Assert-Condition ($model.class -eq "Model") "$($pet.Id) root is not a Model."
	$modelName = ($model.Properties.string | Where-Object name -eq "Name").InnerText
	Assert-Condition ($modelName -eq $pet.Id) "$($pet.Id) root model name is incorrect."
	$archivableNodes = @($model.Properties.SelectNodes("bool[@name='Archivable']"))
	Assert-Condition ($archivableNodes.Count -eq 0 -or $archivableNodes[0].InnerText -ne "false") "$($pet.Id) is not cloneable."

	$items = @($model.SelectNodes(".//Item"))
	$referents = @($items | ForEach-Object { $_.referent })
	Assert-Condition (($referents | Sort-Object -Unique).Count -eq $referents.Count) "$($pet.Id) contains duplicate referents."
	foreach ($item in $items) {
		Assert-Condition ($item.class -notin @("Script", "LocalScript", "ModuleScript")) "$($pet.Id) contains forbidden script class $($item.class)."
	}

	$attributes = Read-ModelAttributes $model.Properties $pet.Id
	Assert-Condition ($attributes.ModelVersion -match '^\d+\.\d+\.\d+$') "$($pet.Id) ModelVersion is not semantic."
	Assert-Condition ($attributes.ModelVersion -in @("2.0.0", "3.0.0")) "$($pet.Id) must use final ModelVersion 3.0.0 or be explicitly legacy 2.0.0."
	if ($attributes.ModelVersion -eq "2.0.0") {
		$legacyCount++
		Write-Host ("[LEGACY/NOT YET REPLACED] {0}: source model is version 2.0.0; final v3 validation was not claimed." -f $pet.Id)
		continue
	}
	$sourceMeshParts = @($items | Where-Object class -eq "MeshPart")
	if ($sourceMeshParts.Count -eq 0) {
		$legacyCount++
		Write-Host ("[LEGACY/NOT YET REPLACED] {0}: source model reports 3.0.0 but still uses primitive geometry; final v3 validation was not claimed." -f $pet.Id)
		continue
	}
	foreach ($item in $items) {
		Assert-Condition ($allowedV3Classes -contains $item.class) "$($pet.Id) v3 contains unknown class $($item.class)."
	}
	$v3Count++

	Assert-Condition ($pet.ContainsKey("MeshCritical") -and $pet.ContainsKey("MeshPartCount")) "$($pet.Id) has no approved v3 MeshPart contract."
	Assert-Condition ($pet.MeshCritical.Count -eq $pet.MeshPartCount) "$($pet.Id) validator contract has a component-count mismatch."
	$meshParts = @($items | Where-Object class -eq "MeshPart")
	Assert-Condition ($meshParts.Count -eq $pet.MeshPartCount) "$($pet.Id) must contain exactly $($pet.MeshPartCount) MeshParts."
	$partNames = @($meshParts | ForEach-Object { ($_.Properties.string | Where-Object name -eq "Name").InnerText })
	Assert-Condition (($partNames | Sort-Object -Unique).Count -eq $partNames.Count) "$($pet.Id) contains duplicate canonical components."
	foreach ($criticalName in $pet.MeshCritical) {
		Assert-Condition ($partNames -contains $criticalName) "$($pet.Id) is missing canonical component $criticalName."
	}
	foreach ($partName in $partNames) {
		Assert-Condition ($pet.MeshCritical -contains $partName) "$($pet.Id) contains unknown MeshPart $partName."
	}

	$attachments = @($items | Where-Object class -eq "Attachment")
	$attachmentNames = @($attachments | ForEach-Object { ($_.Properties.string | Where-Object name -eq "Name").InnerText })
	Assert-Condition (@($attachmentNames | Sort-Object -Unique).Count -eq $attachmentNames.Count) "$($pet.Id) contains duplicate attachment names."
	Assert-Condition ($attachments.Count -eq $pet.Attachments.Count) "$($pet.Id) has an unexpected attachment count."
	foreach ($expectedAttachment in $pet.Attachments) {
		Assert-Condition ($attachmentNames -contains $expectedAttachment) "$($pet.Id) is missing attachment $expectedAttachment."
	}
	foreach ($attachment in $attachments) {
		Assert-Condition ($attachment.ParentNode.class -eq "MeshPart") "$($pet.Id) attachments must be parented to MeshParts."
		$attachmentParentName = ($attachment.ParentNode.Properties.string | Where-Object name -eq "Name").InnerText
		Assert-Condition ($attachmentParentName -eq "Body") "$($pet.Id) VFX attachments must be parented to Body."
	}

	$primaryRef = ($model.Properties.Ref | Where-Object name -eq "PrimaryPart").InnerText
	$primaryMatches = @($meshParts | Where-Object referent -eq $primaryRef)
	Assert-Condition ($primaryMatches.Count -eq 1) "$($pet.Id) PrimaryPart does not resolve to exactly one MeshPart."
	$primary = $primaryMatches[0]
	$primaryName = ($primary.Properties.string | Where-Object name -eq "Name").InnerText
	Assert-Condition ($primaryName -eq "Body") "$($pet.Id) PrimaryPart must be Body."
	Assert-Condition ($primary.ParentNode.referent -eq $model.referent) "$($pet.Id) Body must be a direct child of the root Model."
	foreach ($meshPart in $meshParts | Where-Object referent -ne $primaryRef) {
		$meshPartName = ($meshPart.Properties.string | Where-Object name -eq "Name").InnerText
		$parentRef = $meshPart.ParentNode.referent
		Assert-Condition ($parentRef -eq $model.referent -or $parentRef -eq $primaryRef) "$($pet.Id).$meshPartName must be a direct child of the root Model or Body."
	}

	foreach ($part in $meshParts) {
		$name = ($part.Properties.string | Where-Object name -eq "Name").InnerText
		$sizeNodes = @($part.Properties.SelectNodes("Vector3[@name='size']"))
		Assert-Condition ($sizeNodes.Count -eq 1) "$($pet.Id).$name must have exactly one Size."
		$size = $sizeNodes[0]
		foreach ($axis in @("X", "Y", "Z")) {
			$value = Read-FiniteNumber $size.$axis "$($pet.Id).$name.Size.$axis"
			Assert-Condition ($value -gt 0 -and $value -le 10) "$($pet.Id).$name has invalid size."
		}
		$frameNodes = @($part.Properties.SelectNodes("CoordinateFrame[@name='CFrame']"))
		Assert-Condition ($frameNodes.Count -eq 1) "$($pet.Id).$name must have exactly one CFrame."
		$frame = $frameNodes[0]
		foreach ($component in @("X", "Y", "Z", "R00", "R01", "R02", "R10", "R11", "R12", "R20", "R21", "R22")) {
			[void](Read-FiniteNumber $frame.$component "$($pet.Id).$name.CFrame.$component")
		}
		Assert-Condition (($part.Properties.bool | Where-Object name -eq "CanCollide").InnerText -eq "false") "$($pet.Id).$name must not collide."
		Assert-Condition (($part.Properties.bool | Where-Object name -eq "CanTouch").InnerText -eq "false") "$($pet.Id).$name must not generate touch events."
		Assert-Condition (($part.Properties.bool | Where-Object name -eq "CanQuery").InnerText -eq "false") "$($pet.Id).$name must not participate in spatial queries."
		Assert-Condition (($part.Properties.bool | Where-Object name -eq "Massless").InnerText -eq "true") "$($pet.Id).$name must be massless."
		$meshIdNodes = @($part.Properties.SelectNodes("*[@name='MeshId']"))
		Assert-Condition ($meshIdNodes.Count -eq 1 -and -not [string]::IsNullOrWhiteSpace($meshIdNodes[0].InnerText)) "$($pet.Id).$name must reference imported mesh geometry."
		Assert-Condition (($part.Properties.bool | Where-Object name -eq "Anchored").InnerText -eq "true") "$($pet.Id).$name must be anchored for runtime following."
	}

	Assert-Condition ($attributes.PetId -eq $pet.Id) "$($pet.Id) PetId attribute is wrong."
	Assert-Condition ($attributes.PetName -eq $pet.Name) "$($pet.Id) PetName attribute is wrong."
	Assert-Condition ($attributes.Rarity -eq $pet.Rarity) "$($pet.Id) Rarity attribute is wrong."
	Assert-Condition ([double]$attributes.BaseRate -eq [double]$pet.Rate) "$($pet.Id) BaseRate attribute is wrong."
	Assert-Condition ($attributes.ModelVersion -eq "3.0.0") "$($pet.Id) final source model must use ModelVersion 3.0.0."
	Assert-Condition ($attributes.Placeholder -eq $false) "$($pet.Id) final source model must set Placeholder=false."
	Assert-Condition ($attributes.ForwardAxis -eq "-Z") "$($pet.Id) forward-axis contract is wrong."

	$effectItems = @($items | Where-Object { $_.class -eq "ParticleEmitter" -or $_.class -eq "PointLight" })
	$effectNames = @($effectItems | ForEach-Object { ($_.Properties.string | Where-Object name -eq "Name").InnerText })
	Assert-Condition ($pet.Effects.Count -eq $pet.Attachments.Count -and $pet.Effects.Count -eq $pet.EffectClasses.Count) "$($pet.Id) validator VFX contract is misaligned."
	Assert-Condition ($effectNames.Count -eq $pet.Effects.Count) "$($pet.Id) has an unexpected VFX-node count."
	Assert-Condition (@($effectNames | Sort-Object -Unique).Count -eq $effectNames.Count) "$($pet.Id) contains duplicate VFX names."
	for ($effectIndex = 0; $effectIndex -lt $pet.Effects.Count; $effectIndex++) {
		$effectName = $pet.Effects[$effectIndex]
		$effectMatches = @($effectItems | Where-Object { ($_.Properties.string | Where-Object name -eq "Name").InnerText -eq $effectName })
		Assert-Condition ($effectMatches.Count -eq 1) "$($pet.Id) must contain exactly one VFX node named $effectName."
		$effect = $effectMatches[0]
		Assert-Condition ($effect.class -eq $pet.EffectClasses[$effectIndex]) "$($pet.Id).$effectName has the wrong class."
		Assert-Condition ($effect.ParentNode.class -eq "Attachment") "$($pet.Id).$effectName must be parented to an Attachment."
		$effectParentName = ($effect.ParentNode.Properties.string | Where-Object name -eq "Name").InnerText
		Assert-Condition ($effectParentName -eq $pet.Attachments[$effectIndex]) "$($pet.Id).$effectName is parented to the wrong Attachment."
	}
	$particleRate = 0.0
	foreach ($emitter in @($items | Where-Object class -eq "ParticleEmitter")) {
		$rateNodes = @($emitter.Properties.SelectNodes("float[@name='Rate']"))
		Assert-Condition ($rateNodes.Count -eq 1) "$($pet.Id) particle emitter must have exactly one Rate."
		$rate = Read-FiniteNumber $rateNodes[0] "$($pet.Id) particle rate"
		Assert-Condition ($rate -ge 0) "$($pet.Id) particle rate may not be negative."
		$particleRate += $rate
		$textureNodes = @($emitter.Properties.SelectNodes("*[@name='Texture']"))
		Assert-Condition ($textureNodes.Count -eq 0) "$($pet.Id) uses a texture asset."
	}
	$maxParticleRate = if ($pet.ContainsKey("MaxParticleRate")) { [double]$pet.MaxParticleRate } else { 40.0 }
	Assert-Condition ($particleRate -le $maxParticleRate) "$($pet.Id) VFX particle rate is not restrained."

	Write-Host ("[PASS] {0}: {1} MeshParts, {2} Attachments, {3} VFX nodes, version {4}" -f $pet.Id, $meshParts.Count, $attachments.Count, $effectNames.Count, $attributes.ModelVersion)
}

Write-Host "[PASS] PetConfig, committed models, and references have exact 6/6/6 parity."
if ($legacyCount -gt 0) {
	Write-Host ("[TRANSITION] {0}/6 source models are final v3; {1}/6 are LEGACY/NOT YET REPLACED. B4.5 requires 6/6 v3." -f $v3Count, $legacyCount)
	Write-Host "[PASS] Every present v3 source passed XML, metadata, MeshPart, safety, naming, hierarchy, and VFX validation."
}
else {
	Write-Host "[PASS] All 6/6 source models passed final v3 XML, metadata, MeshPart, safety, naming, hierarchy, and VFX validation."
}
