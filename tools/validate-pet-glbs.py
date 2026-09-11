"""Validate Auralit's six exported GLBs without requiring Blender or Roblox Studio."""

from __future__ import annotations

import argparse
import ast
from collections import Counter
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

VFX = {
    "FrostBunny": {"CyanMist": "ParticleEmitter", "SnowSpecks": "ParticleEmitter"},
    "ChibiCat": {"SilverDust": "ParticleEmitter"},
    "FluffDog": {"SilverDust": "ParticleEmitter"},
    "FrostFox": {"VioletSparkles": "ParticleEmitter", "FrostSpecks": "ParticleEmitter", "EpicAuraLight": "PointLight"},
    "StormOwl": {"VioletSparkles": "ParticleEmitter", "EpicAuraLight": "PointLight"},
    "AuraDragon": {"GoldShimmer": "ParticleEmitter", "CyanSoulfire": "ParticleEmitter", "LegendaryAuraLight": "PointLight"},
}

IMPORT_SUFFIXES = ("_Node_Mesh", "_Mesh", "_Node", "")
REJECTED_RAW_NAMES = ("Sphere001", "Mesh123", "BodyMesh", "Body_Node_Node", "Body_Mesh.001", "Body_extra")
STUDIO_ALIASES = {
    "FrostBunny": {
        "LeftEyeShine": "LeftEyeHighlight",
        "RightEyeShine": "RightEyeHighlight",
        "LeftFootPad": "LeftPawPad",
        "RightFootPad": "RightPawPad",
    },
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


def load_helper_text() -> str:
    return (ROOT / "tools" / "roblox" / "configure_pet_import.lua").read_text(encoding="utf-8")


def load_helper_pet_block(text: str, pet_id: str) -> str:
    start = text.index(f"\n\t{pet_id} = {{")
    later_starts = [
        text.find(f"\n\t{other_pet_id} = {{", start + 1)
        for other_pet_id in SPECS
        if text.find(f"\n\t{other_pet_id} = {{", start + 1) >= 0
    ]
    table_end = text.index("\n}\n\nlocal IMPORT_SUFFIXES", start)
    end = min(later_starts + [table_end])
    return text[start:end]


def load_helper_contract(text: str, pet_id: str) -> dict:
    block = load_helper_pet_block(text, pet_id)
    mesh_block = block.split("meshNames = {", 1)[1].split("\n\t\t},", 1)[0]
    names = set(re.findall(r'"([A-Za-z][A-Za-z0-9]*)"', mesh_block))
    aliases = {}
    if "aliases = {" in block:
        alias_block = block.split("aliases = {", 1)[1].split("\n\t\t},", 1)[0]
        aliases = dict(re.findall(r'([A-Za-z][A-Za-z0-9]*)\s*=\s*"([A-Za-z][A-Za-z0-9]*)"', alias_block))
    effects_block = block.split("effects = {", 1)[1]
    effects = dict(re.findall(r'name = "([A-Za-z][A-Za-z0-9]*)", className = "([A-Za-z]+)"', effects_block))
    metadata_match = re.search(
        r'petId = "([^"]+)", petName = "([^"]+)", rarity = "([^"]+)", baseRate = ([0-9.]+),'
        r'\s*modelVersion = "([^"]+)", forwardAxis = "([^"]+)", meshCount = ([0-9]+)',
        block,
    )
    bounds_match = re.search(r'boundsMin = Vector3\.new\(([^)]+)\), boundsMax = Vector3\.new\(([^)]+)\)', block)
    assert metadata_match and bounds_match, f"{pet_id} helper contract is malformed"
    bounds_min = tuple(float(value.strip()) for value in bounds_match.group(1).split(","))
    bounds_max = tuple(float(value.strip()) for value in bounds_match.group(2).split(","))
    return {
        "names": names,
        "aliases": aliases,
        "effects": effects,
        "metadata": metadata_match.groups()[:6],
        "mesh_count": int(metadata_match.group(7)),
        "bounds": tuple(value for pair in zip(bounds_min, bounds_max) for value in pair),
    }


def load_powershell_validator_names(pet_id: str) -> set[str]:
    text = (ROOT / "tools" / "validate-pet-models.ps1").read_text(encoding="utf-8")
    pet_block = text.split(f'Id = "{pet_id}"', 1)[1]
    mesh_block = pet_block.split("MeshCritical = @(", 1)[1].split("\n\t\t)", 1)[0]
    return set(re.findall(r'"([A-Za-z][A-Za-z0-9]*)"', mesh_block))


def normalize_raw_name(raw_name: str, canonical_names: set[str], aliases: dict[str, str]) -> str | None:
    for suffix in IMPORT_SUFFIXES:
        if suffix and (len(raw_name) <= len(suffix) or not raw_name.endswith(suffix)):
            continue
        base_name = raw_name[:-len(suffix)] if suffix else raw_name
        canonical_name = aliases.get(base_name, base_name)
        if canonical_name in canonical_names:
            return canonical_name
    return None


def analyze_raw_names(raw_names: list[str], canonical_names: set[str], aliases: dict[str, str]) -> dict:
    normalized = [normalize_raw_name(name, canonical_names, aliases) for name in raw_names]
    accepted = [name for name in normalized if name is not None]
    counts = Counter(accepted)
    return {
        "unknown": {raw for raw, canonical in zip(raw_names, normalized) if canonical is None},
        "missing": canonical_names - set(accepted),
        "duplicates": {name for name, count in counts.items() if count > 1},
        "count_ok": len(raw_names) == len(canonical_names),
    }


def validate_normalization(pet_id: str, canonical_names: set[str], aliases: dict[str, str]) -> None:
    for canonical_name in canonical_names:
        for suffix in IMPORT_SUFFIXES:
            raw_name = canonical_name + suffix
            assert normalize_raw_name(raw_name, canonical_names, aliases) == canonical_name, (
                f"{pet_id} failed to normalize {raw_name}"
            )
    for alias, canonical_name in aliases.items():
        for suffix in IMPORT_SUFFIXES:
            assert normalize_raw_name(alias + suffix, canonical_names, aliases) == canonical_name, (
                f"{pet_id} failed to normalize deterministic alias {alias + suffix}"
            )
    for invalid_name in REJECTED_RAW_NAMES:
        assert normalize_raw_name(invalid_name, canonical_names, aliases) is None, (
            f"{pet_id} incorrectly accepted invalid name {invalid_name}"
        )

    duplicate = analyze_raw_names(sorted(canonical_names) + ["Body_Mesh"], canonical_names, aliases)
    assert duplicate["duplicates"] == {"Body"} and not duplicate["unknown"] and not duplicate["missing"]
    unknown = analyze_raw_names(["Sphere001" if name == "Body" else name for name in canonical_names], canonical_names, aliases)
    assert unknown["unknown"] == {"Sphere001"} and unknown["missing"] == {"Body"} and unknown["count_ok"]
    missing = analyze_raw_names([name for name in canonical_names if name != "Body"], canonical_names, aliases)
    assert missing["missing"] == {"Body"} and not missing["count_ok"]
    wrong_count = analyze_raw_names(sorted(canonical_names) + ["Mesh123"], canonical_names, aliases)
    assert wrong_count["unknown"] == {"Mesh123"} and not wrong_count["count_ok"]


def validate_helper_safety(text: str) -> None:
    suffix_match = re.search(r"local IMPORT_SUFFIXES = \{([^}]+)\}", text)
    assert suffix_match and tuple(re.findall(r'"([^"]*)"', suffix_match.group(1))) == IMPORT_SUFFIXES
    assert not (ROOT / "tools" / "roblox" / "configure_frost_bunny.lua").exists(), "Stale dedicated helper still exists"
    assert not any(token in text for token in (":Destroy(", "ClearAllChildren", "Remove()")), "Helper contains destructive logic"
    stage_a = text.split("-- Stage B starts here.", 1)[0]
    forbidden_stage_a_mutations = (
        ".Name =", "PrimaryPart =", "SetAttribute(", "Instance.new(", ".Parent =",
        ".Anchored =", ".CanCollide =", ".CanTouch =", ".CanQuery =", ".Massless =", "Selection:Set(",
    )
    assert not any(token in stage_a for token in forbidden_stage_a_mutations), "Stage A is not read-only"
    for required_text in (
        "[Auralit Pet Import Validation FAILED]", "Unknown MeshParts", "Missing canonical components",
        "Duplicate canonical components", "Wrong classes", "Hierarchy problems", "No changes were made.",
        "[Auralit Pet Import Validation PASSED]",
    ):
        assert required_text in text, f"Helper diagnostic contract is missing {required_text}"


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


def validate_pet(pet_id: str, helper_text: str) -> None:
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
    mesh_names = [mesh.get("name") for mesh in meshes]
    assert len(nodes) == len(mesh_nodes) == len(meshes) == len(expected_names), f"{pet_id} object/mesh count mismatch"
    assert len(names) == len(set(names)) and set(names) == expected_names, f"{pet_id} GLB node names differ from its generator"
    assert len(mesh_names) == len(set(mesh_names)) and set(mesh_names) == {name + "_Mesh" for name in expected_names}, (
        f"{pet_id} GLB mesh-data names are not exact canonical _Mesh variants"
    )
    assert {node["mesh"] for node in mesh_nodes} == set(range(len(meshes))), f"{pet_id} mesh mapping is not one-to-one"
    for node in mesh_nodes:
        assert meshes[node["mesh"]].get("name") == node.get("name") + "_Mesh", f"{pet_id} node/mesh name pair differs"

    helper = load_helper_contract(helper_text, pet_id)
    assert helper["names"] == expected_names, f"{pet_id} Studio helper canonical names differ from its GLB contract"
    assert helper["mesh_count"] == len(expected_names), f"{pet_id} helper MeshPart count differs"
    assert helper["aliases"] == STUDIO_ALIASES.get(pet_id, {}), f"{pet_id} helper aliases differ from the approved set"
    assert helper["effects"] == VFX[pet_id], f"{pet_id} helper VFX contract differs"
    helper_pet_id, helper_pet_name, helper_rarity, helper_rate, helper_version, helper_axis = helper["metadata"]
    assert (helper_pet_id, helper_pet_name, helper_rarity, float(helper_rate), helper_version, helper_axis) == (
        pet_id, pet_name, rarity, base_rate, "3.0.0", "-Z",
    ), f"{pet_id} helper metadata contract differs"
    validate_normalization(pet_id, expected_names, helper["aliases"])
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
    for value, low, high, axis in zip(dimensions, helper["bounds"][::2], helper["bounds"][1::2], "XYZ"):
        assert low <= value <= high, f"{pet_id} {axis} dimension is outside its Studio helper bounds"

    print(
        f"[PASS] {pet_id}: {len(meshes)} objects/meshes, {triangles} triangles, "
        f"{dimensions[0]:.3f} x {dimensions[1]:.3f} x {dimensions[2]:.3f}, "
        f"{len(material_names)} materials, generator/node/mesh/helper/PS names "
        f"{len(expected_names)}/{len(names)}/{len(mesh_names)}/{len(helper['names'])}/{len(expected_names)}; "
        "canonical/_Mesh/_Node/_Node_Mesh and negative import cases passed"
    )


def print_name_audit(helper_text: str) -> None:
    for pet_id in SPECS:
        generator_name = re.sub(r"(?<!^)(?=[A-Z])", "_", pet_id).lower()
        _, _, canonical_names = load_generator_contract(GENERATOR_DIR / f"build_{generator_name}.py")
        document = load_glb(MODEL_DIR / f"{pet_id}.glb")
        node_to_mesh = {
            node["name"]: document["meshes"][node["mesh"]]["name"]
            for node in document["nodes"]
            if "mesh" in node
        }
        helper = load_helper_contract(helper_text, pet_id)
        aliases_by_canonical: dict[str, list[str]] = {}
        for alias, canonical_name in helper["aliases"].items():
            aliases_by_canonical.setdefault(canonical_name, []).append(alias)
        print(f"\nPET: {pet_id}")
        print(f"Root: Body -> {node_to_mesh['Body']}; nodes/meshes: {len(node_to_mesh)}/{len(document['meshes'])}")
        print("Canonical | GLB node | GLB mesh | accepted Studio raw names")
        for canonical_name in sorted(canonical_names):
            bases = [canonical_name] + sorted(aliases_by_canonical.get(canonical_name, []))
            accepted = [base + suffix for base in bases for suffix in IMPORT_SUFFIXES]
            print(f"{canonical_name} | {canonical_name} | {node_to_mesh[canonical_name]} | {', '.join(accepted)}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--audit-names", action="store_true", help="Print every canonical/node/mesh/Studio-name mapping")
    args = parser.parse_args()
    helper_text = load_helper_text()
    validate_helper_safety(helper_text)
    expected_glbs = {f"{pet_id}.glb" for pet_id in SPECS}
    expected_previews = {f"{pet_id}_preview.png" for pet_id in SPECS}
    assert {path.name for path in MODEL_DIR.glob("*.glb")} == expected_glbs, "GLB directory does not have exact six-pet parity"
    assert {path.name for path in MODEL_DIR.glob("*_preview.png")} == expected_previews, "Preview directory does not have exact six-pet parity"
    for pet_id in SPECS:
        validate_pet(pet_id, helper_text)
    print("[PASS] Canonical-name parity, exact MeshPart counts, metadata, VFX, bounds, and hierarchy: all six pets")
    print("[PASS] _Mesh, _Node, and _Node_Mesh normalization: every canonical component across all six pets")
    print("[PASS] Duplicate detection, unknown-name rejection, missing-name rejection, and wrong-count rejection: all six pets")
    print("[PASS] Universal helper Stage A is read-only and contains comprehensive failure diagnostics")
    if args.audit_names:
        print_name_audit(helper_text)


if __name__ == "__main__":
    main()
