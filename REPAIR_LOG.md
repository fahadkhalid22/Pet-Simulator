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

| ID | File/System | Purpose | Status | Problem | Severity | Fix | Verification |
|---|---|---|---|---|---|---|---|
| B4P-01 | Pet character source models | Replace generic placeholder geometry with the six approved character identities | STATICALLY VERIFIED | The previous sources were minimal Body/Head primitives and did not represent the reference roster | HIGH | Rebuilt all six as detailed Roblox-native assemblies with species-specific silhouettes and exact PetConfig names | Automated 6/6/6 parity, XML, geometry, class, metadata, and naming checks passed; Studio visual review required |
| B4P-02 | Pet metadata and orientation | Make imported models deterministic and inspectable | STATICALLY VERIFIED | Source models lacked a complete shared authoring contract | HIGH | Set `Body` as PrimaryPart and added exact identity, rarity, rate, semantic version, placeholder state, and `-Z` forward attributes | `validate-pet-models.ps1` passed all six models |
| B4P-03 | Pet rarity VFX | Communicate rarity without external assets or obscuring geometry | STATICALLY VERIFIED | The old placeholders had no restrained per-rarity presentation | MEDIUM | Added texture-free native particles and local lights with capped aggregate rates | VFX node names, missing Texture properties, and rate caps validated; Studio readability/performance tests required |
| B4P-04 | PetRuntimeService grounding | Keep differently sized models aligned to the world while preserving B4.5 authority and follow behavior | STATICALLY VERIFIED | A fixed pivot offset would leave rebuilt pets floating or clipping | HIGH | Added guarded bounding-box bottom lift to the existing shared Heartbeat target calculation | Source reviewed; formation, respawn, rejoin, and multiplayer Studio tests required |
| B4P-05 | Pet model authoring pipeline | Prevent Play mode from replacing committed character sources | STATICALLY VERIFIED | `BuildPetModels.server.lua` destroyed canonical models and regenerated the rejected minimal placeholders | CRITICAL | Removed the startup builder; committed `.rbxmx` files are now the canonical, explicitly imported sources | Validator passes and Studio replacement-sync procedure documented |

## B4P Root-Cause Report

```text
ITEM: B4P Pet Character Roster Rebuild
PROBLEM: Runtime spawning worked, but every source model was an under-detailed generic primitive placeholder.
ROOT CAUSE: The startup builder treated generated placeholder geometry as authoritative and overwrote imported ServerStorage sources during Play.
FILES AFFECTED: ServerStorage/PetModels/*.rbxmx, BuildPetModels.server.lua, PetRuntimeService.lua
DEPENDENCIES: B4.5 authoritative equipped-state runtime; six approved reference PNGs; PetConfig mapping
SEVERITY: CRITICAL
ACTION: Rebuilt all six native character assemblies, removed the destructive builder, added bounded VFX and validation, and made follow grounding bounds-aware.
TEST: Static validator and repository checks completed; TEST-PETMODEL-01 through TEST-PETMODEL-12 remain for Director Studio execution.
RESULT: STATICALLY VERIFIED / DIRECTOR STUDIO TEST REQUIRED
```

## B4P Reference Checklist

| Pet | Reference-led native character treatment | Required identity cues present | VFX treatment |
|---|---|---|---|
| Fluff Dog | Charcoal, white, and caramel fluffy puppy | Floppy ears, facial blaze, layered amber eyes, muzzle, paws, visible tipped tail | Low-rate `SilverDust` |
| Chibi Cat | Black-and-white tuxedo cat | Triangular pink-inner ears, green eyes, feline muzzle, white face/chest, long raised tail | Low-rate `SilverDust` |
| Frost Bunny | Upright white-and-ice rabbit | Two long pink-inner ears, coral nose, standing limbs, round rabbit tail | `CyanMist` plus sparse `SnowSpecks` |
| Storm Owl | Snowy round owl | Paired eye discs, amber beak and feet, raised layered wings, tail feathers | `VioletSparkles` plus restrained local aura light |
| Frost Fox | Cyan arctic fox | Oversized ears, fox muzzle, white chest ruff, large tiered plume tail | `VioletSparkles`, sparse `FrostSpecks`, and restrained local aura light |
| Aura Dragon | Chibi dragon adaptation of the cyan/gold Overseer reference | Snout, four horns, clawed feet, wings, long tail, chest and forehead runes | `GoldShimmer`, `CyanSoulfire`, and restrained Legendary aura light |

## B4P Director Studio Tests

| Test | Action | Pass condition |
|---|---|---|
| TEST-PETMODEL-01 — Fluff Dog | Spawn one equipped Fluff Dog | It is clearly a dog, its face is readable, no geometry is detached, and it follows correctly |
| TEST-PETMODEL-02 — Chibi Cat | Spawn an equipped Chibi Cat beside a Fluff Dog if available | It is unmistakably a cat; triangular pink ears, green eyes, and tuxedo face/chest are visible; it cannot be confused with Fluff Dog |
| TEST-PETMODEL-03 — Frost Bunny | Spawn an equipped Frost Bunny | Rabbit identity, both ears, and nose are obvious; it does not look like a sphere-only placeholder |
| TEST-PETMODEL-04 — Storm Owl | Spawn an equipped Storm Owl | Owl identity, both wings, and beak are obvious |
| TEST-PETMODEL-05 — Frost Fox | Spawn an equipped Frost Fox | Fox identity, cyan body, large ears, white plume tail, and chest ruff are obvious |
| TEST-PETMODEL-06 — Aura Dragon | Spawn an equipped Aura Dragon | Dragon silhouette, wings, horns, tail, and cyan/gold Legendary details are readable |
| TEST-PETMODEL-07 — Three-pet formation | Equip three visually different pets | Three distinct models appear without overlaps and follow smoothing works |
| TEST-PETMODEL-08 — Aura readability | Inspect every rarity in motion | Each pet remains readable; no particle cloud obscures more than a small portion of it |
| TEST-PETMODEL-09 — Mobile performance | Use a phone viewport with three Epic/Legendary effects where possible | No severe FPS degradation, uncontrolled particle buildup, or duplicated emitters |
| TEST-PETMODEL-10 — Multiplayer | Run two players with three pets each | Each owner gets the correct models, no cross-owner clones occur, and performance remains acceptable |
| TEST-PETMODEL-11 — Respawn/rejoin | Reset, then leave and rejoin with an equipped set | Exact equipped identities return and no old clones remain |
| TEST-PETMODEL-12 — Output | Review F9 server and client logs throughout | Zero Critical model/runtime errors, infinite yields, or repeated model warnings |

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
