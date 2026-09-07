param(
	[string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$culture = [Globalization.CultureInfo]::InvariantCulture

$pets = @(
	@{ Id = "FluffDog"; Name = "Fluff Dog"; Rarity = "Common"; Rate = 10; Reference = "ref_dog.png"; Critical = @("Body", "Head", "FaceBlaze", "LeftFloppyEar", "RightFloppyEar", "Nose", "TailTip"); Effects = @("SilverDust") },
	@{ Id = "ChibiCat"; Name = "Chibi Cat"; Rarity = "Common"; Rate = 10; Reference = "ref_cat.png"; Critical = @("Body", "Head", "LeftOuterEar", "RightOuterEar", "LeftInnerEar", "RightInnerEar", "Nose", "TailBase", "TailTip"); Effects = @("SilverDust") },
	@{ Id = "FrostBunny"; Name = "Frost Bunny"; Rarity = "Rare"; Rate = 25; Reference = "ref_bunny.png"; Critical = @("Body", "Head", "LeftEar", "RightEar", "LeftInnerEar", "RightInnerEar", "CoralNose", "RabbitTail"); Effects = @("CyanMist", "SnowSpecks") },
	@{ Id = "StormOwl"; Name = "Storm Owl"; Rarity = "Epic"; Rate = 50; Reference = "ref_owl.png"; Critical = @("Body", "Head", "LeftEyeDisc", "RightEyeDisc", "AmberBeak", "LeftWingRoot", "RightWingRoot", "LeftFoot", "RightFoot"); Effects = @("VioletSparkles", "EpicAuraLight") },
	@{ Id = "FrostFox"; Name = "Frost Fox"; Rarity = "Epic"; Rate = 50; Reference = "ref_frost_fox.png"; Critical = @("Body", "Head", "LeftOuterEar", "RightOuterEar", "ChestRuffCenter", "TailPlumeLower", "TailPlumeTip", "Nose"); Effects = @("VioletSparkles", "FrostSpecks", "EpicAuraLight") },
	@{ Id = "AuraDragon"; Name = "Aura Dragon"; Rarity = "Legendary"; Rate = 100; Reference = "ref_aura_dragon.png"; Critical = @("Body", "Head", "Snout", "LeftHornBase", "RightHornBase", "LeftWingInner", "RightWingInner", "TailTip", "ForeheadRune"); Effects = @("GoldShimmer", "CyanSoulfire", "LegendaryAuraLight") }
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
$allowedClasses = @("Model", "Part", "WedgePart", "ParticleEmitter", "PointLight")

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

	$parts = @($items | Where-Object { $_.class -eq "Part" -or $_.class -eq "WedgePart" })
	Assert-Condition ($parts.Count -ge 15) "$($pet.Id) has too few BaseParts for the approved character assembly."
	$partNames = @($parts | ForEach-Object { ($_.Properties.string | Where-Object name -eq "Name").InnerText })
	Assert-Condition (($partNames | Sort-Object -Unique).Count -eq $partNames.Count) "$($pet.Id) contains duplicate part names."
	foreach ($criticalName in $pet.Critical) {
		Assert-Condition ($partNames -contains $criticalName) "$($pet.Id) is missing critical part $criticalName."
	}

	$primaryRef = ($model.Properties.Ref | Where-Object name -eq "PrimaryPart").InnerText
	$primary = $parts | Where-Object referent -eq $primaryRef
	Assert-Condition ($null -ne $primary) "$($pet.Id) PrimaryPart does not resolve to a BasePart."
	$primaryName = ($primary.Properties.string | Where-Object name -eq "Name").InnerText
	Assert-Condition ($primaryName -eq "Body") "$($pet.Id) PrimaryPart must be Body."

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
	}

	$attributeNode = $model.Properties.BinaryString | Where-Object name -eq "AttributesSerialize"
	Assert-Condition (-not [string]::IsNullOrWhiteSpace($attributeNode.InnerText)) "$($pet.Id) metadata attributes are empty."
	$attributes = Read-Attributes $attributeNode.InnerText
	Assert-Condition ($attributes.PetId -eq $pet.Id) "$($pet.Id) PetId attribute is wrong."
	Assert-Condition ($attributes.PetName -eq $pet.Name) "$($pet.Id) PetName attribute is wrong."
	Assert-Condition ($attributes.Rarity -eq $pet.Rarity) "$($pet.Id) Rarity attribute is wrong."
	Assert-Condition ([double]$attributes.BaseRate -eq [double]$pet.Rate) "$($pet.Id) BaseRate attribute is wrong."
	Assert-Condition ($attributes.ModelVersion -match '^\d+\.\d+\.\d+$') "$($pet.Id) ModelVersion is not semantic."
	Assert-Condition ($attributes.Placeholder -eq $true) "$($pet.Id) Placeholder state must be explicit."
	Assert-Condition ($attributes.ForwardAxis -eq "-Z") "$($pet.Id) forward-axis contract is wrong."

	$effectNames = @($items | Where-Object { $_.class -eq "ParticleEmitter" -or $_.class -eq "PointLight" } | ForEach-Object { ($_.Properties.string | Where-Object name -eq "Name").InnerText })
	foreach ($effectName in $pet.Effects) {
		Assert-Condition ($effectNames -contains $effectName) "$($pet.Id) is missing VFX $effectName."
	}
	$particleRate = 0.0
	foreach ($emitter in @($items | Where-Object class -eq "ParticleEmitter")) {
		$rateNode = $emitter.Properties.float | Where-Object name -eq "Rate"
		$particleRate += Read-FiniteNumber $rateNode "$($pet.Id) particle rate"
		$textureNodes = @($emitter.Properties.SelectNodes("*[@name='Texture']"))
		Assert-Condition ($textureNodes.Count -eq 0) "$($pet.Id) uses a texture asset."
	}
	Assert-Condition ($particleRate -le 40) "$($pet.Id) VFX particle rate is not restrained."

	Write-Host ("[PASS] {0}: {1} parts, {2} VFX nodes, version {3}" -f $pet.Id, $parts.Count, $effectNames.Count, $attributes.ModelVersion)
}

Write-Host "[PASS] PetConfig, committed models, and references have exact 6/6/6 parity."
Write-Host "[PASS] All pet-model XML, metadata, geometry, safety, naming, and VFX checks passed."
