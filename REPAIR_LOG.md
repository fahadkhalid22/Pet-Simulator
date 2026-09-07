# Auralit Repair Log

| ID | File/System | Purpose | Status | Problem | Severity | Fix | Verification |
|---|---|---|---|---|---|---|---|
| B2-01 | Player data configuration | Centralize persistence limits and defaults | DIRECTOR VERIFIED | DataStore, scope, and starter-pet string literals were stripped during the interrupted Windows write | CRITICAL | Restored valid literals and frozen centralized configuration | TEST-B2-01 passed in Studio; defaults loaded correctly |
| B2-02 | Player data schema | Create and sanitize versioned persistent profiles | DIRECTOR VERIFIED | Schema draft contained stripped literals and could not safely normalize saved data | CRITICAL | Added defaults, legacy-field migration, bounds, ownership/equip validation, deep cloning, and future-version detection | TEST-B2-01 and TEST-B2-02 passed; persistence and profile isolation verified |
| B2-03 | DataService | Load, lock, mutate, autosave, and release isolated player profiles | DIRECTOR VERIFIED | Service draft was syntactically damaged and stopped before load/release/startup implementation | CRITICAL | Added guarded UpdateAsync lifecycle, retries, session/revision conflict checks, mutation serialization, autosave, leave save, and shutdown save | Persistence survived rejoin; no critical B2 errors observed |
| B2-04 | Data bootstrap | Start the server-side player data lifecycle | DIRECTOR VERIFIED | No executable server bootstrap started DataService | CRITICAL | Added `DataBootstrap.server.lua` and idempotent `DataService.Start()` | Data lifecycle started successfully in Studio |

## B2 Root-Cause Report

```text
ITEM: B2 Player Data System
PROBLEM: Player persistence was incomplete and the draft Luau contained stripped string literals.
ROOT CAUSE: An interrupted Windows generation path damaged quoting and left DataService unfinished.
FILES AFFECTED: GameConfig.lua, DataSchema.lua, DataService.lua, DataBootstrap.server.lua
DEPENDENCIES: Roblox DataStore access (verified in Studio)
SEVERITY: CRITICAL
ACTION: Repaired the drafts and completed a server-authoritative, versioned persistence lifecycle.
TEST: Static checks, leave/rejoin persistence, and two-player isolation completed.
RESULT: DIRECTOR VERIFIED / TEST-B2-01 AND TEST-B2-02 PASSED
```

| ID | File/System | Purpose | Status | Problem | Severity | Fix | Verification |
|---|---|---|---|---|---|---|---|
| B3-01 | PetConfig | Centralize pet identity, prices, rarity, models, and income | DIRECTOR VERIFIED | Pet definitions and economy values were not implemented | HIGH | Added a frozen six-pet catalog with confirmed rarity income and documented prices | TEST-B3-01 and TEST-B3-02 passed with correct rates and purchase values |
| B3-02 | Pet acquisition and equipment | Purchase, grant, equip, and unequip persistent pets | DIRECTOR VERIFIED | No authoritative acquisition or equipment service existed | HIGH | Added atomic balance checks, unique pet UIDs, inventory/equip limits, ownership validation, and auto-equip | Purchases, deductions, ownership, equip limits, and persistence passed |
| B3-03 | Passive income | Award coins from equipped owned pets | DIRECTOR VERIFIED | Equipped pets did not generate currency | HIGH | Added one server loop with authoritative aggregation, fractional carry, catch-up cap, and coin cap | Passive income and unequip/re-equip behavior passed |
| B3-04 | Pet remotes | Provide a secure B4-facing request surface | DIRECTOR VERIFIED | No validated client request path existed | HIGH | Added rate-limited purchase/equip/unequip requests plus player-only state and income events | TEST-B3-03 validation and rate limiting passed; no critical B3 errors |

## B3 Root-Cause Report

```text
ITEM: B3 Pet Acquisition & Passive Earning
PROBLEM: The verified data layer had no pet catalog, acquisition API, equipment actions, income loop, or secure client request surface.
ROOT CAUSE: Step B3 had not been implemented.
FILES AFFECTED: GameConfig.lua, PetConfig.lua, PetService.lua, DataBootstrap.server.lua
DEPENDENCIES: B2 complete; B3 runtime behavior verified in Studio
SEVERITY: HIGH
ACTION: Implemented centralized configuration and server-authoritative pet progression.
TEST: Static checks plus TEST-B3-01, TEST-B3-02, and TEST-B3-03 completed.
RESULT: DIRECTOR VERIFIED / ALL B3 RUNTIME TESTS PASSED
```

| ID | File/System | Purpose | Status | Problem | Severity | Fix | Verification |
|---|---|---|---|---|---|---|---|
| B4-01 | UIConfig | Centralize the Auralit UI palette and responsive dimensions | STATICALLY VERIFIED | B4 had no shared visual tokens | HIGH | Added frozen palette, rarity colors, modal limits, card sizing, and 56-pixel touch minimum | Source reviewed; Studio rendering required |
| B4-02 | UIBuilder | Build the HUD, navigation, shop/inventory modal, pet cards, and feedback | STATICALLY VERIFIED | No core player UI existed | HIGH | Added code-native responsive components, constrained text, scrolling grids, reusable buttons, toasts, and income popups | Source reviewed; TEST-B4-01 through TEST-B4-04 required |
| B4-03 | Auralit UI controller | Connect UI views to authoritative pet state and actions | STATICALLY VERIFIED | Players had no interface for B3 progression | HIGH | Added validated snapshot rendering, live HUD attributes, affordability states, request locking, purchase/equip actions, and viewport updates | Server authority preserved; Studio interaction and mobile verification required |

## B4 Root-Cause Report

```text
ITEM: B4 UI Implementation
PROBLEM: The verified pet loop had no HUD, pet shop, inventory, or mobile interaction layer.
ROOT CAUSE: Step B4 had not been implemented.
FILES AFFECTED: UIConfig.lua, UIBuilder.lua, AuralitUI.client.lua
DEPENDENCIES: B3 Director verified; Roblox Studio runtime and device-emulator access required
SEVERITY: HIGH
ACTION: Implemented a code-native, server-backed, mobile-responsive Phase 1 interface.
TEST: Static source and diff checks completed; four focused Studio runtime checks remain.
RESULT: STATICALLY VERIFIED / DIRECTOR RUNTIME TEST REQUIRED
```

## B4R Director Runtime Tests

Use a Studio place containing the repaired six models under `ServerStorage/PetModels`. During play, runtime clones must be under `Workspace/AuralitPetRuntime/Player_<UserId>` and must never appear under `ServerStorage/PetModels` as modifications.

| Test | Action | Pass condition |
|---|---|---|
| TEST-B4R-01 | Join with one equipped pet | Exactly one matching model appears and follows the player |
| TEST-B4R-02 | Equip three owned pets | Exactly three models occupy distinct deterministic formation slots behind/beside the player |
| TEST-B4R-03 | Unequip the middle equipped pet | Only the model with that pet UID is removed and the remaining pets reconcile slots |
| TEST-B4R-04 | Re-equip the removed pet | Its model returns once, follows correctly, and has the expected `PetUid` |
| TEST-B4R-05 | Purchase a pet while an equip slot is free | The auto-equipped purchase appears without rejoining or manually refreshing |
| TEST-B4R-06 | Reset or kill the character, then respawn | Old runtime pets are removed and the authoritative equipped set returns for the new character |
| TEST-B4R-07 | Leave and rejoin after saving equipped pets | The saved equipped set is restored visually after data load |
| TEST-B4R-08 | Run a two-player server | Each player has a separate owner folder and only follows their own models |
| TEST-B4R-09 | Repeat equip, unequip, purchase, death, and rejoin transitions | Runtime model count always equals equipped count, with one unique model per equipped UID |
| TEST-B4R-10 | Review Output throughout all tests | No critical errors, infinite yields, physics warnings, or runtime-service error spam occur |

| ID | File/System | Purpose | Status | Problem | Severity | Fix | Verification |
|---|---|---|---|---|---|---|---|
| B4R-01 | PetService runtime signal | Publish authoritative equipped snapshots to server dependents | STATICALLY VERIFIED | Equipped state affected income but had no server-internal visual synchronization path | HIGH | Added a server-only state signal fired after data load and every successful pet mutation | Source and dependency order reviewed; Studio verification required |
| B4R-02 | PetRuntimeService spawning | Materialize only equipped pets without trusting clients | STATICALLY VERIFIED | No runtime pet models were spawned | HIGH | Added trusted PetConfig model lookup, cloned-model validation, per-player Workspace folders, UID deduplication, and immediate reconciliation | TEST-B4R-01 through TEST-B4R-05, TEST-B4R-08, and TEST-B4R-09 required |
| B4R-03 | PetRuntimeService follow/lifecycle | Follow owners safely through movement and character lifecycle | STATICALLY VERIFIED | Equipped pets had no formation, movement, respawn, or cleanup behavior | HIGH | Added one shared Heartbeat loop, deterministic three-slot offsets, exponential smoothing, bobbing, anchored collision-free parts, respawn resync, and leave cleanup | TEST-B4R-02, TEST-B4R-06 through TEST-B4R-08, and TEST-B4R-10 required |
| B4R-04 | ServerStorage pet model sources | Provide valid cloneable source assets | STATICALLY VERIFIED | All six `.rbxmx` files had unquoted XML attributes and were not reliably importable | HIGH | Restored valid XML attribute quoting without changing pet identities or source behavior | All six files parse as XML; fresh Studio import required |

## B4R Root-Cause Report

```text
ITEM: B4.5 Pet Runtime Visual & Follow System
PROBLEM: Equipped pets persisted and generated income but had no world representation.
ROOT CAUSE: B3 implemented authoritative pet state, but no server runtime consumed that state to clone and move equipped models.
FILES AFFECTED: PetService.lua, PetRuntimeService.lua, DataBootstrap.server.lua, ServerStorage/PetModels/*.rbxmx
DEPENDENCIES: B3 Director verified; B4 UI available; ServerStorage pet models required
SEVERITY: HIGH
ACTION: Added authoritative runtime reconciliation, isolated spawning, shared smooth following, lifecycle cleanup, and valid source XML.
TEST: Static source review, XML parsing, catalog/model checks, and diff checks completed; Director Studio tests remain.
RESULT: STATICALLY VERIFIED / DIRECTOR RUNTIME TEST REQUIRED
```
