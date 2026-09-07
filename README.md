# Auralit

Auralit is a bright, mobile-first Roblox pet-collecting simulator built around rarity auras and server-authoritative passive progression.

## Development workflow

The project currently uses a manual Roblox Studio sync workflow. Mirror the repository paths in Studio:

- `src/ReplicatedStorage/Shared/*.lua` as ModuleScripts under `ReplicatedStorage/Shared`
- `src/ReplicatedStorage/Client/*.lua` as ModuleScripts under `ReplicatedStorage/Client`
- `src/ServerScriptService/Services/*.lua` as ModuleScripts under `ServerScriptService/Services`
- `src/ServerScriptService/*.server.lua` as Scripts under `ServerScriptService`
- `src/ServerStorage/PetModels/*.rbxmx` under `ServerStorage/PetModels`
- `src/StarterPlayer/StarterPlayerScripts/*.client.lua` as LocalScripts under `StarterPlayerScripts`

### Pet roster replacement sync

Use this exact sequence when bringing the rebuilt character roster into an existing Studio place:

1. Stop Play mode.
2. Delete `ServerScriptService/BuildPetModels` if that legacy Script exists. It is intentionally no longer part of the source tree.
3. Ensure `ServerStorage/PetModels` is a Folder.
4. Inside that Folder, delete only `FluffDog`, `ChibiCat`, `FrostBunny`, `StormOwl`, `FrostFox`, and `AuraDragon`, including any suffixed duplicate copies of those six names.
5. Right-click `PetModels`, choose **Insert from File**, and import each matching file from `src/ServerStorage/PetModels`.
6. Confirm the Folder contains exactly those six Models, each model name matches its filename, and each PrimaryPart is `Body`.
7. Replace the Studio `ServerScriptService/Services/PetRuntimeService` ModuleScript source with `src/ServerScriptService/Services/PetRuntimeService.lua`.
8. Save, then enter Play mode and run the tests in `REPAIR_LOG.md`.

The committed `.rbxmx` files are the canonical source models. Repeating the exact delete-and-import sequence is safe and prevents duplicate runtime sources; no Play-time model builder should remain.

## Current status

Phase B2 player data and Phase B3 pet acquisition/passive earning are Director verified. Phase B4 has a responsive code-native HUD, pet shop, and inventory. The server-authoritative pet runtime/follow dependency and rebuilt native six-pet roster are statically implemented between B4 and B5; focused Roblox Studio verification is still required. See `ROADMAP.md` and `REPAIR_LOG.md`.

For Studio persistence testing, publish a private test place and enable **Game Settings > Security > Enable Studio Access to API Services**. Do not enable Studio API access against a live production place with valuable player data.
