# Project Decisions Log

| Date | Step | Decision | Rationale |
|---|---|---|---|
| 2026-09-03 | Step 0 | Initialized repo structure | Established standard Roblox and project directory hierarchy. |
| 2026-09-03 | Step A1 | Established Theme & Art Direction for Auralit | Locked in pastel palette (#A8E6CF, #DED2F9, #A0D2EB, #FFD3B6, #2D253F), chibi shape language, light fantasy aura hook, and 8-16 age target. |
| 2026-09-03 | Step A2 | Locked Initial 6-Pet Character Roster | Confirmed Fluff Dog, Chibi Cat (Common), Frost Bunny (Rare), Storm Owl, Frost Fox (Epic), and Aura Dragon (Legendary Option A chibi dragon with Overseer aesthetic). Sourced as Studio primitive assemblies with rarity auras. |

### Bugs Fixed
- **2026-09-03**: SerializerPugi::deserializeImpl ill-formed XML when opening custom .rbxlx. Root cause: PowerShell string escaping stripped XML quotes during generation. Fix: Removed generated .rbxlx; use native Studio Baseplate template with ServerScriptService script creation.

| 2026-09-03 | Step A3 | Defined UI/UX Direction (PS99 Style) | Benchmarked Pet Simulator 99 chunky cartoon buttons, left-dock HUD, pastel lavender modal frames, and mobile-first responsive layout. |