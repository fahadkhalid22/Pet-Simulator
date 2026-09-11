"""Validate Auralit's six exported GLBs without requiring Blender or Roblox Studio."""

from __future__ import annotations

import ast
import json
import math
import re
import struct
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODEL_DIR = ROOT / "assets" / "models" / "pets"
GENERATOR_DIR = ROOT / "tools" / "blender"

SPECS = {
    "FrostBunny": ("Frost Bunny", "Rare", 25.0, (2500, 6000), (2.3, 2.9, 4.0, 4.6, 1.8, 2.3)),
    "ChibiCat": ("Chibi Cat", "Common", 10.0, (2500, 5000), (2.4, 2.8, 3.5, 3.9, 1.7, 2.1)),
    "FluffDog": ("Fluff Dog", "Common", 10.0, (3000, 6000), (3.0, 3.3, 3.15, 3.55, 1.7, 2.1)),
    "FrostFox": ("Frost Fox", "Epic", 50.0, (3500, 6500), (3.0, 3.4, 3.45, 3.9, 2.5, 2.9)),
    "StormOwl": ("Storm Owl", "Epic", 50.0, (3000, 6000), (4.0, 4.4, 3.5, 4.0, 1.8, 2.2)),
    "AuraDragon": ("Aura Dragon", "Legendary", 100.0, (4500, 9000), (3.2, 3.6, 5.0, 5.5, 1.1, 1.4)),
}

MATERIALS = {
    "FrostBunny": {"BunnyWhite", "InnerEarPink", "EyeBlack", "EyeHighlight", "NosePink", "CheekPink", "MouthBlack", "PawPink"},
    "ChibiCat": {"CatCharcoal", "CatWhite", "InnerEarPink", "EyeBlack", "EyeLime", "EyeHighlight", "NoseDark"},
    "FluffDog": {"DogSlate", "DogWhite", "DogCaramel", "EyeBlack", "EyeAmber", "EyeHighlight", "MouthDark", "TonguePink"},
    "FrostFox": {"FrostCyan", "FrostCyanLight", "FrostWhite", "FrostNavy", "FrostPawBlue", "EyeHighlight"},
    "StormOwl": {"SnowPlumage", "SilverPlumage", "StormCharcoal", "EyeBlack", "EyeHighlight", "Amber"},
    "AuraDragon": {"VoidRobe", "DragonArmor", "DragonArmorLight", "AuraCyan", "AuraCyanSoft", "StaffDark"},
}


def load_generator_contract(path: Path) -> tuple[str, str, set[str]]:
    tree = ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
    values: dict[str, object] = {}
    for node in tree.body:
        if isinstance(node, ast.Assign) and len(node.targets) == 1 and isinstance(node.targets[0], ast.Name):
            if node.targets[0].id in {"PET_ID", "REFERENCE", "EXPECTED_NAMES"}:
                values[node.targets[0].id] = ast.literal_eval(node.value)
    assert set(values) == {"PET_ID", "REFERENCE", "EXPECTED_NAMES"}, f"Incomplete generator contract in {path}"
    return str(values["PET_ID"]), str(values["REFERENCE"]), set(values["EXPECTED_NAMES"])


def load_glb(path: Path) -> dict:
    payload = path.read_bytes()
    assert len(payload) >= 20, f"{path.name} is truncated"
    magic, version, declared_length = struct.unpack_from("<4sII", payload, 0)
    assert magic == b"glTF" and version == 2 and declared_length == len(payload), f"{path.name} has an invalid GLB header"
    chunk_length, chunk_type = struct.unpack_from("<II", payload, 12)
    assert chunk_type == 0x4E4F534A, f"{path.name} has no leading JSON chunk"
    return json.loads(payload[20:20 + chunk_length])


def load_helper_names(pet_id: str) -> set[str]:
    if pet_id == "FrostBunny":
        text = (ROOT / "tools" / "roblox" / "configure_frost_bunny.lua").read_text(encoding="utf-8")
        block = text.split("local expectedMeshNames = {", 1)[1].split("local studioNameAliases", 1)[0]
        return set(re.findall(r"^\s*([A-Za-z][A-Za-z0-9]*)\s*=\s*true", block, re.MULTILINE))
    text = (ROOT / "tools" / "roblox" / "configure_pet_import.lua").read_text(encoding="utf-8")
    pet_block = text.split(f"\n\t{pet_id} = {{", 1)[1]
    mesh_block = pet_block.split("meshNames = {", 1)[1].split("\n\t\t},", 1)[0]
    return set(re.findall(r'"([A-Za-z][A-Za-z0-9]*)"', mesh_block))


def load_powershell_validator_names(pet_id: str) -> set[str]:
    text = (ROOT / "tools" / "validate-pet-models.ps1").read_text(encoding="utf-8")
    pet_block = text.split(f'Id = "{pet_id}"', 1)[1]
    mesh_block = pet_block.split("MeshCritical = @(", 1)[1].split("\n\t\t)", 1)[0]
    return set(re.findall(r'"([A-Za-z][A-Za-z0-9]*)"', mesh_block))


def geometry_stats(document: dict) -> tuple[int, tuple[float, float, float]]:
    accessors = document["accessors"]
    nodes = document["nodes"]
    parent_by_child = {
        child: parent_index
        for parent_index, node in enumerate(nodes)
        for child in node.get("children", [])
    }

    def world_translation(node_index: int) -> tuple[float, float, float]:
        node = nodes[node_index]
        assert not any(key in node for key in ("matrix", "rotation", "scale")), "Exported transforms were not applied"
        local = tuple(float(value) for value in node.get("translation", (0.0, 0.0, 0.0)))
        assert all(math.isfinite(value) for value in local), "Non-finite node translation"
        parent_index = parent_by_child.get(node_index)
        if parent_index is None:
            return local
        parent = world_translation(parent_index)
        return tuple(parent[axis] + local[axis] for axis in range(3))

    minimum = [math.inf, math.inf, math.inf]
    maximum = [-math.inf, -math.inf, -math.inf]
    triangles = 0
    for node_index, node in enumerate(nodes):
        if "mesh" not in node:
            continue
        translation = world_translation(node_index)
        for primitive in document["meshes"][node["mesh"]]["primitives"]:
            assert primitive.get("mode", 4) == 4 and "indices" in primitive, "Only indexed triangle meshes are approved"
            index_count = int(accessors[primitive["indices"]]["count"])
            assert index_count % 3 == 0, "Triangle index count is malformed"
            triangles += index_count // 3
            position = accessors[primitive["attributes"]["POSITION"]]
            assert len(position["min"]) == 3 and len(position["max"]) == 3, "Position bounds are malformed"
            for axis in range(3):
                low = float(position["min"][axis]) + translation[axis]
                high = float(position["max"][axis]) + translation[axis]
                assert math.isfinite(low) and math.isfinite(high) and low <= high, "Position bounds are invalid"
                minimum[axis] = min(minimum[axis], low)
                maximum[axis] = max(maximum[axis], high)
    dimensions = tuple(maximum[axis] - minimum[axis] for axis in range(3))
    return triangles, dimensions


def validate_pet(pet_id: str) -> None:
    pet_name, rarity, base_rate, triangle_range, dimension_range = SPECS[pet_id]
    generator_name = re.sub(r"(?<!^)(?=[A-Z])", "_", pet_id).lower()
    generator_path = GENERATOR_DIR / f"build_{generator_name}.py"
    generator_id, reference, expected_names = load_generator_contract(generator_path)
    assert generator_id == pet_id, f"{generator_path.name} declares {generator_id}"
    assert (ROOT / reference).is_file(), f"{pet_id} reference is missing"

    glb_path = MODEL_DIR / f"{pet_id}.glb"
    preview_path = MODEL_DIR / f"{pet_id}_preview.png"
    assert glb_path.is_file() and glb_path.stat().st_size > 0, f"{pet_id} GLB is missing or empty"
    assert preview_path.is_file() and preview_path.stat().st_size > 0, f"{pet_id} preview is missing or empty"
    document = load_glb(glb_path)

    assert not any(document.get(key) for key in ("animations", "cameras", "images", "skins", "textures")), (
        f"{pet_id} contains an unsupported animation, camera, image, skin, or texture"
    )
    nodes = document.get("nodes", [])
    meshes = document.get("meshes", [])
    mesh_nodes = [node for node in nodes if "mesh" in node]
    names = [node.get("name") for node in mesh_nodes]
    assert len(nodes) == len(mesh_nodes) == len(meshes) == len(expected_names), f"{pet_id} object/mesh count mismatch"
    assert len(names) == len(set(names)) and set(names) == expected_names, f"{pet_id} mesh names differ from its generator"
    assert {node["mesh"] for node in mesh_nodes} == set(range(len(meshes))), f"{pet_id} mesh mapping is not one-to-one"
    assert load_helper_names(pet_id) == expected_names, f"{pet_id} Studio helper whitelist differs from its GLB contract"
    assert load_powershell_validator_names(pet_id) == expected_names, (
        f"{pet_id} committed-model validator whitelist differs from its GLB contract"
    )

    body_index = names.index("Body")
    body = mesh_nodes[body_index]
    actual_body_index = nodes.index(body)
    assert document["scenes"][document.get("scene", 0)]["nodes"] == [actual_body_index], f"{pet_id} Body is not the sole root"
    assert set(body.get("children", [])) == set(range(len(nodes))) - {actual_body_index}, (
        f"{pet_id} components are not direct Body children"
    )

    extras = body.get("extras", {})
    expected_metadata = {
        "PetId": pet_id,
        "PetName": pet_name,
        "Rarity": rarity,
        "BaseRate": base_rate,
        "ModelVersion": "3.0.0",
        "ForwardAxis": "-Z",
        "Reference": reference,
    }
    for key, expected in expected_metadata.items():
        assert extras.get(key) == expected, f"{pet_id} metadata {key} is {extras.get(key)!r}, expected {expected!r}"

    material_names = {material.get("name") for material in document.get("materials", [])}
    assert material_names == MATERIALS[pet_id], f"{pet_id} material contract mismatch: {sorted(material_names)}"
    triangles, dimensions = geometry_stats(document)
    assert triangle_range[0] <= triangles <= triangle_range[1], f"{pet_id} triangle count {triangles} is outside budget"
    for value, low, high, axis in zip(dimensions, dimension_range[::2], dimension_range[1::2], "XYZ"):
        assert low <= value <= high, f"{pet_id} {axis} dimension {value:.3f} is outside {low:.3f}-{high:.3f}"

    print(
        f"[PASS] {pet_id}: {len(meshes)} objects/meshes, {triangles} triangles, "
        f"{dimensions[0]:.3f} x {dimensions[1]:.3f} x {dimensions[2]:.3f}, "
        f"{len(material_names)} materials, generator/GLB/helper/PS names "
        f"{len(expected_names)}/{len(expected_names)}/{len(expected_names)}/{len(expected_names)}"
    )


def main() -> None:
    expected_glbs = {f"{pet_id}.glb" for pet_id in SPECS}
    expected_previews = {f"{pet_id}_preview.png" for pet_id in SPECS}
    assert {path.name for path in MODEL_DIR.glob("*.glb")} == expected_glbs, "GLB directory does not have exact six-pet parity"
    assert {path.name for path in MODEL_DIR.glob("*_preview.png")} == expected_previews, "Preview directory does not have exact six-pet parity"
    for pet_id in SPECS:
        validate_pet(pet_id)
    print("[PASS] All six v3 GLBs have exact generator, hierarchy, metadata, material, budget, and helper parity.")


if __name__ == "__main__":
    main()
