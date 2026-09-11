"""Build the reference-matched Auralit StormOwl v3 mesh."""

from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pet_mesh_common import PetMeshBuilder


PET_ID = "StormOwl"
REFERENCE = "assets/references/pets/ref_owl.png"
EXPECTED_NAMES = {
    "Body", "Head", "LeftEyeDisc", "RightEyeDisc", "LeftEye", "RightEye",
    "LeftEyeHighlight", "RightEyeHighlight", "Beak",
    "ChestUpper", "ChestLeft", "ChestRight", "ChestLower",
    "LeftWingBase", "LeftWingUpper", "LeftWingMiddle", "LeftWingLower", "LeftWingTip",
    "RightWingBase", "RightWingUpper", "RightWingMiddle", "RightWingLower", "RightWingTip",
    "LeftLeg", "RightLeg", "LeftFoot", "RightFoot",
    "LeftTalon1", "LeftTalon2", "LeftTalon3", "RightTalon1", "RightTalon2", "RightTalon3",
    "TailLeft", "TailCenter", "TailRight",
}


def build(builder: PetMeshBuilder):
    snow = builder.material("SnowPlumage", (0.90, 0.91, 0.89, 1.0), 0.52)
    silver = builder.material("SilverPlumage", (0.42, 0.46, 0.49, 1.0), 0.50)
    charcoal = builder.material("StormCharcoal", (0.08, 0.09, 0.10, 1.0), 0.43)
    black = builder.material("EyeBlack", (0.006, 0.006, 0.007, 1.0), 0.12, 0.23)
    highlight = builder.material("EyeHighlight", (1.0, 1.0, 0.96, 1.0), 0.12)
    amber = builder.material("Amber", (0.94, 0.47, 0.05, 1.0), 0.46)

    body = builder.ellipsoid("Body", (0.0, -0.06, 1.37), (0.88, 0.73, 1.15), snow,
                             segments=18, rings=9)
    builder.ellipsoid("Head", (0.0, 0.03, 2.64), (1.03, 0.76, 0.88), snow,
                      segments=20, rings=10)
    for side, x in (("Left", -0.40), ("Right", 0.40)):
        builder.ellipsoid(f"{side}EyeDisc", (x, 0.72, 2.70), (0.43, 0.12, 0.48), silver,
                          segments=14, rings=7)
        builder.ellipsoid(f"{side}Eye", (x, 0.84, 2.70), (0.22, 0.07, 0.27), black,
                          segments=14, rings=7)
        builder.ellipsoid(f"{side}EyeHighlight", (x - 0.04, 0.91, 2.80), (0.043, 0.018, 0.052),
                          highlight, segments=8, rings=4)

    builder.cone("Beak", (0.0, 0.93, 2.40), 0.20, 0.035, 0.43, amber,
                 rotation=(math.radians(90), 0.0, 0.0), vertices=12, scale=(1.0, 0.8, 1.0))
    builder.feather("ChestUpper", (0.0, 0.60, 1.86), (0.50, 0.18, 0.55), silver,
                    rotation=(math.radians(180), 0.0, 0.0), segments=12, rings=6)
    builder.feather("ChestLeft", (-0.29, 0.58, 1.51), (0.38, 0.18, 0.55), silver,
                    rotation=(math.radians(180), math.radians(-18), 0.0), segments=12, rings=6)
    builder.feather("ChestRight", (0.29, 0.58, 1.51), (0.38, 0.18, 0.55), silver,
                    rotation=(math.radians(180), math.radians(18), 0.0), segments=12, rings=6)
    builder.feather("ChestLower", (0.0, 0.56, 1.20), (0.42, 0.17, 0.49), snow,
                    rotation=(math.radians(180), 0.0, 0.0), segments=12, rings=6)

    wing_layers = (
        ("WingBase", 0.82, 2.05, 0.48, 0.80, 28, silver),
        ("WingUpper", 1.12, 2.45, 0.38, 0.76, 42, snow),
        ("WingMiddle", 1.36, 2.17, 0.37, 0.73, 57, silver),
        ("WingLower", 1.48, 1.85, 0.35, 0.67, 68, snow),
        ("WingTip", 1.55, 1.55, 0.32, 0.58, 76, silver),
    )
    for side, direction in (("Left", -1.0), ("Right", 1.0)):
        for suffix, x, z, width, length, tilt, material in wing_layers:
            builder.feather(
                f"{side}{suffix}",
                (direction * x, 0.02, z),
                (width, 0.31, length),
                material,
                rotation=(math.radians(-8), math.radians(direction * tilt), 0.0),
                segments=12,
                rings=6,
            )

    for side, x in (("Left", -0.37), ("Right", 0.37)):
        builder.ellipsoid(f"{side}Leg", (x, -0.01, 0.41), (0.16, 0.16, 0.46), charcoal,
                          segments=10, rings=5)
        builder.ellipsoid(f"{side}Foot", (x, 0.20, 0.14), (0.30, 0.34, 0.16), amber,
                          segments=10, rings=5)
        for index, toe_x in enumerate((-0.13, 0.0, 0.13), start=1):
            builder.tube(
                f"{side}Talon{index}",
                ((x + toe_x, 0.36, 0.13), (x + toe_x, 0.63, 0.10)),
                (0.045, 0.018),
                amber,
                radial_segments=6,
            )

    builder.feather("TailLeft", (-0.30, -0.52, 0.49), (0.31, 0.27, 0.58), silver,
                    rotation=(math.radians(180), math.radians(-9), 0.0), segments=12, rings=6)
    builder.feather("TailCenter", (0.0, -0.58, 0.42), (0.34, 0.29, 0.65), snow,
                    rotation=(math.radians(180), 0.0, 0.0), segments=12, rings=6)
    builder.feather("TailRight", (0.30, -0.52, 0.49), (0.31, 0.27, 0.58), silver,
                    rotation=(math.radians(180), math.radians(9), 0.0), segments=12, rings=6)
    return body


def main() -> None:
    builder = PetMeshBuilder(PET_ID)
    builder.clean_scene()
    body = build(builder)
    builder.parent_to_body(body, {
        "PetId": PET_ID,
        "PetName": "Storm Owl",
        "Rarity": "Epic",
        "BaseRate": 50.0,
        "ModelVersion": "3.0.0",
        "ForwardAxis": "-Z",
        "Reference": REFERENCE,
    })
    builder.validate(
        body,
        EXPECTED_NAMES,
        {"SnowPlumage", "SilverPlumage", "StormCharcoal", "EyeBlack", "EyeHighlight", "Amber"},
        (3000, 6000),
        ((3.3, 4.3), (1.4, 2.1), (3.3, 3.9)),
    )
    builder.export(body)
    builder.diagnostics(REFERENCE)
    builder.render_preview()


if __name__ == "__main__":
    main()
