# Auralit

Auralit is a bright, mobile-first Roblox pet-collecting simulator built around rarity auras and server-authoritative passive progression.

## Development workflow

The project currently uses a manual Roblox Studio sync workflow. Mirror the repository paths in Studio:

- `src/ReplicatedStorage/Shared/*.lua` as ModuleScripts under `ReplicatedStorage/Shared`
- `src/ServerScriptService/Services/*.lua` as ModuleScripts under `ServerScriptService/Services`
- `src/ServerScriptService/*.server.lua` as Scripts under `ServerScriptService`
- `src/ServerStorage/PetModels/*.rbxmx` under `ServerStorage/PetModels`

## Current status

Phase B2 player-data code is implemented and statically reviewed. Roblox Studio runtime verification is still required for DataStore persistence, shutdown saves, and multiplayer isolation; see `ROADMAP.md` and `REPAIR_LOG.md`.

For Studio persistence testing, publish a private test place and enable **Game Settings > Security > Enable Studio Access to API Services**. Do not enable Studio API access against a live production place with valuable player data.
