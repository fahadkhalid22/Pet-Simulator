# Auralit - Game Design Document

## 1. Theme & Art Direction

### Game Identity
- **Title:** Auralit (Origin: *Aura* + *Lit* — emphasizing the signature glowing rarity-aura hook)
- **Genre:** Pet-collecting simulator with passive-income / tycoon mechanics
- **Target Audience:** Ages 8–16 (bright, approachable, family-friendly, high clarity)
- **Overall Tone:** Warm, cheerful, whimsical, and magical. Clean and cozy aesthetics without violence or gritty tones.

### Color Direction & Palette
- **Base UI & World Palette (Soft Pastels):**
  - Mint: #A8E6CF (Nature, secondary accents)
  - Lavender: #DED2F9 (Primary UI windows, card containers)
  - Sky Blue: #A0D2EB (Buttons, action highlights, HUD badges)
  - Peach / Warm Cream: #FFD3B6 (Borders, interactive hovers, warm callouts)
  - Deep Night Violet: #2D253F (High-contrast typography, sharp legible outlines)
- **Rarity Tier Accents:**
  - Common: #E5E5E5 (Neutral Soft White / Silver)
  - Rare: #3A86FF (Luminous Aqua / Sky Blue Glow)
  - Epic: #8338EC (Royal Violet Sparkle)
  - Legendary: #FFBE0B (Radiant Gold / Prismatic Rainbow Shimmer)

### Shape Language & Visual Proportions
- **Character Geometry:** Chibi proportions (approx. 1.5:1 to 2:1 head-to-body ratio). Rounded, friendly silhouettes with pill or spherical torsos, stubby paws, and large expressive eyes. Strictly no sharp edges or intimidating silhouettes.
- **UI Shape Language:** Friendly and modern. Rounded rectangles (UICorner 10px–14px radius), pill buttons, bold readable typography, and high contrast against pastel backgrounds.

### Fantasy Intensity & VFX Approach
- **Light Fantasy:** The core 3D models are recognizable, lovable animals (e.g., Dog, Cat, Bunny, Owl, Fox).
- **Aura-Driven Evolution:** Elemental fantasy power is conveyed primarily through colored particle auras and tinting (frost mist, ember sparks, starlight glow) rather than heavy mesh remodeling, ensuring an efficient, beginner-friendly 3D asset pipeline.

---

## 2. Character Roster

All characters strictly follow our smooth chibi shape language (pill-shaped torsos, stubby limbs, oversized heads, rounded contours). Initial models are generated as clean Studio primitive assemblies with rarity particle auras, serving as placeholders until custom 3D mesh assets are imported.

| Pet ID | Name | Rarity Tier | Reference File | Color & Silhouette Specification | Aura VFX Specification | Base Income Rate |
|---|---|---|---|---|---|---|
| dog_fluff | **Fluff Dog** | **Common** | ssets/references/pets/ref_dog.png | Charcoal grey coat with snowy white muzzle & chest blaze, warm caramel eyebrow dots and cheeks, floppy ears. | Soft White / Silver subtle aura glow | 10 coins/sec |
| cat_chibi | **Chibi Cat** | **Common** | ssets/references/pets/ref_cat.png | Plump tuxedo kitten, dark espresso & white blaze, lime green eyes, pink inner ears. | Soft White / Silver subtle aura glow | 10 coins/sec |
| unny_frost | **Frost Bunny** | **Rare** | ssets/references/pets/ref_bunny.png | Standing pill-shaped white rabbit, coral-pink button nose, pastel pink teardrop ears. | Luminous Aqua / Cyan cold mist aura | 25 coins/sec |
| owl_storm | **Storm Owl** | **Epic** | ssets/references/pets/ref_owl.png | Chubby snowy owl, white and silver-grey plumage, spread layered wings, amber-orange beak. | Royal Purple twinkling star-sparkle aura | 50 coins/sec |
| ox_frost | **Frost Fox** | **Epic** | ssets/references/pets/ref_frost_fox.png | Radiant cyan kitsune fox, oversized flared ears, tiered white plume tail and chest ruff. | Royal Purple & crystalline frost aura | 50 coins/sec |
| dragon_aura | **Aura Dragon** | **Legendary** | ssets/references/pets/ref_aura_dragon.png | Midnight charcoal chibi dragon, glowing neon-cyan runic horns & wing accents, ethereal cyan soulfire. | Radiant Gold halo & Prismatic shimmer aura | 100 coins/sec |

### Asset Sourcing & Placeholder Policy
- Source meshes are not provided upfront.
- Working placeholder models are constructed in Roblox Studio using smooth CSG/primitive assemblies (Spheres, Cylinders, Block meshes) and colored according to the palette above.
- Each model is tagged as Placeholder = true in its attributes.
- Final meshes can be swapped directly into ServerStorage/PetModels with matching part names (PrimaryPart = Body) without any code changes.

---

## 3. UI/UX Specification
*(To be decided in Step A3)*

---

## 4. Animation & VFX Specification
*(To be decided in Step A4)*

---

## 5. Economy Balancing Table
*(To be finalized in Phase B)*
