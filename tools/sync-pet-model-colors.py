#!/usr/bin/env python3
"""Check or synchronize Roblox MeshPart colors from authoritative pet GLBs."""

from __future__ import annotations

import argparse
import json
import math
import re
import struct
from pathlib import Path


PET_IDS = (
    "FrostBunny",
    "ChibiCat",
    "FluffDog",
    "FrostFox",
    "StormOwl",
    "AuraDragon",
)


def read_glb_json(path: Path) -> dict:
    data = path.read_bytes()
    if len(data) < 20 or data[:4] != b"glTF":
        raise ValueError(f"{path} is not a valid GLB")
    version, total_length = struct.unpack_from("<II", data, 4)
    if version != 2 or total_length != len(data):
        raise ValueError(f"{path} has an invalid GLB header")
    chunk_length, chunk_type = struct.unpack_from("<II", data, 12)
    if chunk_type != 0x4E4F534A:
        raise ValueError(f"{path} does not begin with a JSON chunk")
    return json.loads(data[20 : 20 + chunk_length].decode("utf-8"))


def linear_to_srgb_byte(value: float) -> int:
    if not math.isfinite(value) or value < 0 or value > 1:
        raise ValueError(f"invalid linear color component {value}")
    srgb = 12.92 * value if value <= 0.0031308 else 1.055 * value ** (1 / 2.4) - 0.055
    return round(255 * srgb)


def glb_colors(path: Path) -> dict[str, int]:
    document = read_glb_json(path)
    if document.get("images") or document.get("textures"):
        raise ValueError(f"{path} unexpectedly contains image textures")
    materials = document.get("materials", [])
    meshes = document.get("meshes", [])
    colors: dict[str, int] = {}
    for node in document.get("nodes", []):
        if "mesh" not in node:
            continue
        name = node.get("name")
        if not isinstance(name, str) or not name:
            raise ValueError(f"{path} contains an unnamed mesh node")
        primitives = meshes[node["mesh"]].get("primitives", [])
        if len(primitives) != 1 or "material" not in primitives[0]:
            raise ValueError(f"{path}:{name} must have exactly one materialized primitive")
        material = materials[primitives[0]["material"]]
        factor = material.get("pbrMetallicRoughness", {}).get("baseColorFactor", [1, 1, 1, 1])
        if len(factor) != 4 or factor[3] != 1:
            raise ValueError(f"{path}:{name} has an unsupported base color factor")
        red, green, blue = (linear_to_srgb_byte(float(component)) for component in factor[:3])
        if name in colors:
            raise ValueError(f"{path} contains duplicate mesh node {name}")
        colors[name] = 0xFF000000 | red << 16 | green << 8 | blue
    return colors


def synchronize_model(path: Path, expected: dict[str, int], apply: bool) -> int:
    text = path.read_text(encoding="utf-8")
    seen: set[str] = set()
    changes = 0
    item_pattern = re.compile(r'(<Item class="MeshPart"[^>]*>\s*<Properties>)(.*?)(</Properties>)', re.S)
    name_pattern = re.compile(r'<string name="Name">([^<]+)</string>')
    color_pattern = re.compile(r'(<Color3uint8 name="Color3uint8">)(\d+)(</Color3uint8>)')

    def replace_item(match: re.Match[str]) -> str:
        nonlocal changes
        properties = match.group(2)
        name_match = name_pattern.search(properties)
        if not name_match:
            raise ValueError(f"{path} contains a MeshPart without a Name")
        name = name_match.group(1)
        if name in seen:
            raise ValueError(f"{path} contains duplicate MeshPart {name}")
        seen.add(name)
        if name not in expected:
            raise ValueError(f"{path} contains unknown MeshPart {name}")
        color_matches = list(color_pattern.finditer(properties))
        if len(color_matches) != 1:
            raise ValueError(f"{path}:{name} must contain exactly one Color3uint8")
        actual = int(color_matches[0].group(2))
        target = expected[name]
        if actual == target:
            return match.group(0)
        changes += 1
        updated = color_pattern.sub(lambda color: color.group(1) + str(target) + color.group(3), properties)
        return match.group(1) + updated + match.group(3)

    updated_text = item_pattern.sub(replace_item, text)
    if seen != set(expected):
        missing = ", ".join(sorted(set(expected) - seen))
        raise ValueError(f"{path} is missing GLB MeshParts: {missing}")
    if apply and changes:
        path.write_text(updated_text, encoding="utf-8", newline="")
    return changes


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pet", action="append", choices=PET_IDS, dest="pets")
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    repository = Path(__file__).resolve().parent.parent
    pet_ids = args.pets or PET_IDS
    pending = 0
    for pet_id in pet_ids:
        expected = glb_colors(repository / "assets" / "models" / "pets" / f"{pet_id}.glb")
        model = repository / "src" / "ServerStorage" / "PetModels" / f"{pet_id}.rbxmx"
        changes = synchronize_model(model, expected, args.apply)
        pending += changes
        action = "updated" if args.apply else "mismatched"
        print(f"[{pet_id}] {len(expected)} exact GLB colors; {changes} {action}")
    if pending and not args.apply:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
