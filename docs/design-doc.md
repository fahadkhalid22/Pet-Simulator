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

### Design Style & Paradigm
- **Benchmark:** Pet Simulator 99 (tactile, chunky cartoon aesthetic with modern mobile-first clarity).
- **Geometry:** Rounded cards and pill buttons (UICorner 10px-14px radius), bold outlines (UIStroke 3px, color #2D253F), and simulated 3D bottom bevels for physical click feel.
- **Color Mapping:**
  - Panels & Window Backgrounds: Soft Lavender (#DED2F9) with crisp white interior content cards.
  - Borders & Outlines: High-contrast Deep Night Violet (#2D253F).
  - Action / Buy Buttons: Mint Green (#A8E6CF) with darker green bottom bevel #72C5A3.
  - Equip / Active Buttons: Sky Blue (#A0D2EB) with darker blue bevel #6FAAC7).
  - Close / Destructive Buttons: Coral Peach (#FF9AA2).
  - Currency Badges: Radiant Gold (#FFD3B6 / #FFBE0B).

### Screens & Layout

#### 1. Main HUD (Always Visible)
- **Top-Right Currency Container:**
  - Pill frame with gold coin icon, displaying formatted coin count (e.g., 100, 1.5K, 250K).
  - Floating +XX coin popups on passive earnings tick.
- **Top-Center/Right Equipped Pet Badge:**
  - Compact badge displaying active pet count (e.g., Pets: 1/3).
- **Left-Side Vertical Action Dock:**
  - Stacked square-rounded buttons (60x60 px on desktop, scaled via UIScale on mobile):
    - Inventory Button: Toggles Pet Management modal.
    - Shop Button: Toggles Pet Hatching & Egg Shop modal.
    - Settings Button: Audio mute, graphic toggles.

#### 2. Modal Windows (Shop & Inventory)
- **Framework:** Centered modal dialog (AnchorPoint = (0.5, 0.5), Position = (0.5, 0, 0.5, 0)).
- **Header:** Clean pastel header bar with bold title and top-right chunky close button.
- **Pet Card Grid:**
  - Responsive UIGridLayout of square pet cards.
  - Card Header: Pet rarity badge (Common/Rare/Epic/Legendary colors).
  - Card Body: 3D ViewportFrame showing rotating pet model with active particle aura.
  - Card Footer: Pet Name, earning rate (+XX/s), and interactive action button (BUY [XX Coins] or EQUIP / UNEQUIP).

### Button Interaction States
- **Normal:** Full size (1.0x), 4px visible bottom shadow bevel.
- **Hover (Desktop):** Scales to 1.04x, slight brightness lift.
- **Pressed / Tap (Mobile & Desktop):** Compresses to 0.96x scale, bottom bevel depresses, emits tactile pop sound.

---


## 4. Animation & VFX Specification
*(To be decided in Step A4)*

---

## 5. Economy Balancing Table
*(To be finalized in Phase B)*
