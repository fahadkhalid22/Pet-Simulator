param(
	[string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$culture = [Globalization.CultureInfo]::InvariantCulture

$pets = @(
	@{
		Id = "FluffDog"; Name = "Fluff Dog"; Rarity = "Common"; Rate = 10; Reference = "ref_dog.png"
		Critical = @("Body", "Head", "FaceBlaze", "LeftFloppyEar", "RightFloppyEar", "Nose", "TailTip")
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
		MaxParticleRate = 8
	},
	@{
		Id = "ChibiCat"; Name = "Chibi Cat"; Rarity = "Common"; Rate = 10; Reference = "ref_cat.png"
		Critical = @("Body", "Head", "LeftOuterEar", "RightOuterEar", "LeftInnerEar", "RightInnerEar", "Nose", "TailBase", "TailTip")
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
		MaxParticleRate = 8
	},
	@{
		Id = "FrostBunny"; Name = "Frost Bunny"; Rarity = "Rare"; Rate = 25; Reference = "ref_bunny.png"
		Critical = @("Body", "Head", "LeftEar", "RightEar", "LeftInnerEar", "RightInnerEar", "CoralNose", "RabbitTail")
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
		MaxParticleRate = 12
	},
	@{
		Id = "StormOwl"; Name = "Storm Owl"; Rarity = "Epic"; Rate = 50; Reference = "ref_owl.png"
		Critical = @("Body", "Head", "LeftEyeDisc", "RightEyeDisc", "AmberBeak", "LeftWingRoot", "RightWingRoot", "LeftFoot", "RightFoot")
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
		MaxParticleRate = 5
	},
	@{
		Id = "FrostFox"; Name = "Frost Fox"; Rarity = "Epic"; Rate = 50; Reference = "ref_frost_fox.png"
		Critical = @("Body", "Head", "LeftOuterEar", "RightOuterEar", "ChestRuffCenter", "TailPlumeLower", "TailPlumeTip", "Nose")
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
		MaxParticleRate = 10
	},
	@{
		Id = "AuraDragon"; Name = "Aura Dragon"; Rarity = "Legendary"; Rate = 100; Reference = "ref_aura_dragon.png"
		Critical = @("Body", "Head", "Snout", "LeftHornBase", "RightHornBase", "LeftWingInner", "RightWingInner", "TailTip", "ForeheadRune")
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
$allowedClasses = @("Model", "Part", "WedgePart", "MeshPart", "Attachment", "ParticleEmitter", "PointLight")

foreach ($pet in $pets) {
	$modelPath = Join-Path $modelDirectory ($pet.Id + ".rbxmx")
	$referencePath = Join-Path $referenceDirectory $pet.Reference
	Assert-Condition (Test-Path -LiteralPath $modelPath -PathType Leaf) "Missing model file $($pet.Id).rbxmx."
	Assert-Condition (Test-Path -LiteralPath $referencePath -PathType Leaf) "Missing reference $($pet.Reference)."

	$blockPattern = "(?s)definitions\." + [regex]::Escape($pet.Id) + "\s*=\s*table\.freeze\(\{.*?\n\}\)"
	$configBlock = [regex]::Match($config, $blockPattern)
	Assert-Condition $configBlock.Success "PetConfig is missing $($pet.Id)."
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
		Assert-Condition ($allowedClasses -contains $item.class) "$($pet.Id) contains forbidden class $($item.class)."
	}

	$parts = @($items | Where-Object { $_.class -in @("Part", "WedgePart", "MeshPart") })
	$meshParts = @($parts | Where-Object class -eq "MeshPart")
	$primitiveParts = @($parts | Where-Object { $_.class -eq "Part" -or $_.class -eq "WedgePart" })
	$isMeshCandidate = $meshParts.Count -gt 0
	if ($isMeshCandidate) {
		Assert-Condition ($pet.ContainsKey("MeshCritical") -and $pet.ContainsKey("MeshPartCount")) "$($pet.Id) has no approved imported-mesh validation contract."
	}
	Assert-Condition ($parts.Count -ge $(if ($isMeshCandidate) { 1 } else { 15 })) "$($pet.Id) has too few BaseParts for the approved character assembly."
	$partNames = @($parts | ForEach-Object { ($_.Properties.string | Where-Object name -eq "Name").InnerText })
	Assert-Condition (($partNames | Sort-Object -Unique).Count -eq $partNames.Count) "$($pet.Id) contains duplicate part names."
	$criticalNames = if ($isMeshCandidate -and $pet.ContainsKey("MeshCritical")) { $pet.MeshCritical } else { $pet.Critical }
	foreach ($criticalName in $criticalNames) {
		Assert-Condition ($partNames -contains $criticalName) "$($pet.Id) is missing critical part $criticalName."
	}
	if ($isMeshCandidate -and $pet.ContainsKey("MeshPartCount")) {
		Assert-Condition ($meshParts.Count -eq $pet.MeshPartCount) "$($pet.Id) must contain exactly $($pet.MeshPartCount) MeshParts."
	}
	if ($isMeshCandidate) {
		Assert-Condition ($primitiveParts.Count -eq 0) "$($pet.Id) v3 geometry may not fall back to Part/WedgePart primitives."
	}

	$attachments = @($items | Where-Object class -eq "Attachment")
	$attachmentNames = @($attachments | ForEach-Object { ($_.Properties.string | Where-Object name -eq "Name").InnerText })
	Assert-Condition (@($attachmentNames | Sort-Object -Unique).Count -eq $attachmentNames.Count) "$($pet.Id) contains duplicate attachment names."
	if ($isMeshCandidate) {
		$expectedAttachments = if ($pet.ContainsKey("Attachments")) { @($pet.Attachments) } else { @() }
		Assert-Condition ($attachments.Count -eq $expectedAttachments.Count) "$($pet.Id) has an unexpected attachment count."
		foreach ($expectedAttachment in $expectedAttachments) {
			Assert-Condition ($attachmentNames -contains $expectedAttachment) "$($pet.Id) is missing attachment $expectedAttachment."
		}
		foreach ($attachment in $attachments) {
			Assert-Condition ($attachment.ParentNode.class -eq "MeshPart") "$($pet.Id) attachments must be parented to MeshParts."
			$attachmentParentName = ($attachment.ParentNode.Properties.string | Where-Object name -eq "Name").InnerText
			Assert-Condition ($attachmentParentName -eq "Body") "$($pet.Id) VFX attachments must be parented to Body."
		}
	}
	else {
		Assert-Condition ($attachments.Count -eq 0) "$($pet.Id) legacy primitive model may not contain v3 attachments."
	}

	$primaryRef = ($model.Properties.Ref | Where-Object name -eq "PrimaryPart").InnerText
	$primary = $parts | Where-Object referent -eq $primaryRef
	Assert-Condition ($null -ne $primary) "$($pet.Id) PrimaryPart does not resolve to a BasePart."
	$primaryName = ($primary.Properties.string | Where-Object name -eq "Name").InnerText
	Assert-Condition ($primaryName -eq "Body") "$($pet.Id) PrimaryPart must be Body."
	Assert-Condition ($primary.ParentNode.referent -eq $model.referent) "$($pet.Id) Body must be a direct child of the root Model."
	if ($isMeshCandidate) {
		foreach ($meshPart in $meshParts | Where-Object referent -ne $primaryRef) {
			$meshPartName = ($meshPart.Properties.string | Where-Object name -eq "Name").InnerText
			Assert-Condition ($meshPart.ParentNode.referent -eq $primaryRef) "$($pet.Id).$meshPartName must be parented directly beneath Body."
		}
	}

	foreach ($part in $parts) {
		$name = ($part.Properties.string | Where-Object name -eq "Name").InnerText
		$size = $part.Properties.Vector3 | Where-Object name -eq "size"
		foreach ($axis in @("X", "Y", "Z")) {
			$value = Read-FiniteNumber $size.$axis "$($pet.Id).$name.Size.$axis"
			Assert-Condition ($value -gt 0 -and $value -le 10) "$($pet.Id).$name has invalid size."
		}
		$frame = $part.Properties.CoordinateFrame | Where-Object name -eq "CFrame"
		foreach ($component in @("X", "Y", "Z", "R00", "R01", "R02", "R10", "R11", "R12", "R20", "R21", "R22")) {
			[void](Read-FiniteNumber $frame.$component "$($pet.Id).$name.CFrame.$component")
		}
		Assert-Condition (($part.Properties.bool | Where-Object name -eq "CanCollide").InnerText -eq "false") "$($pet.Id).$name must not collide."
		Assert-Condition (($part.Properties.bool | Where-Object name -eq "CanTouch").InnerText -eq "false") "$($pet.Id).$name must not generate touch events."
		Assert-Condition (($part.Properties.bool | Where-Object name -eq "CanQuery").InnerText -eq "false") "$($pet.Id).$name must not participate in spatial queries."
		Assert-Condition (($part.Properties.bool | Where-Object name -eq "Massless").InnerText -eq "true") "$($pet.Id).$name must be massless."
		if ($part.class -eq "MeshPart") {
			$meshIdNodes = @($part.Properties.SelectNodes("*[@name='MeshId']"))
			Assert-Condition ($meshIdNodes.Count -eq 1 -and -not [string]::IsNullOrWhiteSpace($meshIdNodes[0].InnerText)) "$($pet.Id).$name must reference imported mesh geometry."
			Assert-Condition (($part.Properties.bool | Where-Object name -eq "Anchored").InnerText -eq "true") "$($pet.Id).$name must be anchored for runtime following."
		}
	}

	$attributeNode = $model.Properties.BinaryString | Where-Object name -eq "AttributesSerialize"
	Assert-Condition (-not [string]::IsNullOrWhiteSpace($attributeNode.InnerText)) "$($pet.Id) metadata attributes are empty."
	$attributes = Read-Attributes $attributeNode.InnerText
	Assert-Condition ($attributes.PetId -eq $pet.Id) "$($pet.Id) PetId attribute is wrong."
	Assert-Condition ($attributes.PetName -eq $pet.Name) "$($pet.Id) PetName attribute is wrong."
	Assert-Condition ($attributes.Rarity -eq $pet.Rarity) "$($pet.Id) Rarity attribute is wrong."
	Assert-Condition ([double]$attributes.BaseRate -eq [double]$pet.Rate) "$($pet.Id) BaseRate attribute is wrong."
	Assert-Condition ($attributes.ModelVersion -match '^\d+\.\d+\.\d+$') "$($pet.Id) ModelVersion is not semantic."
	if ($isMeshCandidate) {
		Assert-Condition ($attributes.ModelVersion -eq "3.0.0") "$($pet.Id) imported mesh candidate must use ModelVersion 3.0.0."
		Assert-Condition ($attributes.Placeholder -eq $false) "$($pet.Id) imported mesh candidate may not be marked Placeholder."
	}
	else {
		Assert-Condition ($attributes.ModelVersion -eq "2.0.0") "$($pet.Id) legacy primitive model must remain ModelVersion 2.0.0."
		Assert-Condition ($attributes.Placeholder -eq $true) "$($pet.Id) legacy primitive model must remain explicitly marked Placeholder."
	}
	Assert-Condition ($attributes.ForwardAxis -eq "-Z") "$($pet.Id) forward-axis contract is wrong."

	$effectItems = @($items | Where-Object { $_.class -eq "ParticleEmitter" -or $_.class -eq "PointLight" })
	$effectNames = @($effectItems | ForEach-Object { ($_.Properties.string | Where-Object name -eq "Name").InnerText })
	Assert-Condition ($effectNames.Count -eq $pet.Effects.Count) "$($pet.Id) has an unexpected VFX-node count."
	Assert-Condition (@($effectNames | Sort-Object -Unique).Count -eq $effectNames.Count) "$($pet.Id) contains duplicate VFX names."
	foreach ($effectName in $pet.Effects) {
		Assert-Condition ($effectNames -contains $effectName) "$($pet.Id) is missing VFX $effectName."
	}
	if ($isMeshCandidate -and $pet.ContainsKey("Attachments")) {
		for ($effectIndex = 0; $effectIndex -lt $pet.Effects.Count; $effectIndex++) {
			$effect = $effectItems | Where-Object { ($_.Properties.string | Where-Object name -eq "Name").InnerText -eq $pet.Effects[$effectIndex] }
			Assert-Condition ($effect.ParentNode.class -eq "Attachment") "$($pet.Id).$($pet.Effects[$effectIndex]) must be parented to an Attachment."
			$effectParentName = ($effect.ParentNode.Properties.string | Where-Object name -eq "Name").InnerText
			Assert-Condition ($effectParentName -eq $pet.Attachments[$effectIndex]) "$($pet.Id).$($pet.Effects[$effectIndex]) is parented to the wrong Attachment."
		}
	}
	$particleRate = 0.0
	foreach ($emitter in @($items | Where-Object class -eq "ParticleEmitter")) {
		$rateNode = $emitter.Properties.float | Where-Object name -eq "Rate"
		$particleRate += Read-FiniteNumber $rateNode "$($pet.Id) particle rate"
		$textureNodes = @($emitter.Properties.SelectNodes("*[@name='Texture']"))
		Assert-Condition ($textureNodes.Count -eq 0) "$($pet.Id) uses a texture asset."
	}
	$maxParticleRate = if ($pet.ContainsKey("MaxParticleRate")) { [double]$pet.MaxParticleRate } else { 40.0 }
	Assert-Condition ($particleRate -le $maxParticleRate) "$($pet.Id) VFX particle rate is not restrained."

	Write-Host ("[PASS] {0}: {1} parts, {2} VFX nodes, version {3}" -f $pet.Id, $parts.Count, $effectNames.Count, $attributes.ModelVersion)
}

Write-Host "[PASS] PetConfig, committed models, and references have exact 6/6/6 parity."
Write-Host "[PASS] All pet-model XML, metadata, geometry, safety, naming, and VFX checks passed."
