"""Build the reference-matched Auralit FrostFox v3 mesh."""

from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pet_mesh_common import PetMeshBuilder


PET_ID = "FrostFox"
REFERENCE = "assets/references/pets/ref_frost_fox.png"
EXPECTED_NAMES = {
    "Body", "Head", "LeftOuterEar", "RightOuterEar", "LeftInnerEar", "RightInnerEar",
    "LeftEye", "RightEye", "LeftEyeHighlight", "RightEyeHighlight", "Nose",
    "LeftCheekFur", "RightCheekFur", "ForeheadTuftCenter", "ForeheadTuftLeft", "ForeheadTuftRight",
    "ChestRuffUpper", "ChestRuffLeft", "ChestRuffRight", "ChestRuffLower",
    "LeftFrontLeg", "RightFrontLeg", "LeftRearLeg", "RightRearLeg",
    "LeftFrontPaw", "RightFrontPaw", "LeftRearPaw", "RightRearPaw",
    "TailRoot", "TailPlume", "TailTip",
}


def build(builder: PetMeshBuilder):
    cyan = builder.material("FrostCyan", (0.08, 0.56, 0.72, 1.0), 0.34, 0.10)
    cyan_light = builder.material("FrostCyanLight", (0.23, 0.80, 0.91, 1.0), 0.31, 0.10)
    white = builder.material("FrostWhite", (0.93, 0.98, 0.98, 1.0), 0.40, 0.06)
    navy = builder.material("FrostNavy", (0.025, 0.12, 0.20, 1.0), 0.30)
    blue = builder.material("FrostPawBlue", (0.03, 0.33, 0.55, 1.0), 0.38)
    highlight = builder.material("EyeHighlight", (0.92, 1.0, 1.0, 1.0), 0.12, emission=0.2)

    body = builder.ellipsoid("Body", (0.0, -0.35, 1.19), (0.95, 0.88, 0.73), cyan,
                             segments=18, rings=9)
    builder.ellipsoid("Head", (0.0, 0.31, 2.05), (1.02, 0.74, 0.74), cyan_light,
                      segments=18, rings=9)
    for side, x, tilt in (("Left", -0.61, -11), ("Right", 0.61, 11)):
        builder.feather(f"{side}OuterEar", (x, 0.18, 2.92), (0.48, 0.29, 0.82), cyan,
                        rotation=(0.0, math.radians(tilt), 0.0), segments=14, rings=7)
        builder.feather(f"{side}InnerEar", (x, 0.42, 2.91), (0.28, 0.045, 0.55), navy,
                        rotation=(0.0, math.radians(tilt), 0.0), segments=12, rings=6)
        builder.ellipsoid(f"{side}Eye", (x * 0.58, 1.00, 2.17), (0.22, 0.075, 0.27), navy,
                          segments=14, rings=7)
        builder.ellipsoid(f"{side}EyeHighlight", (x * 0.58 - 0.04, 1.075, 2.27),
                          (0.045, 0.022, 0.055), highlight, segments=8, rings=4)

    builder.ellipsoid("Nose", (0.0, 1.08, 1.93), (0.14, 0.09, 0.11), navy, segments=12, rings=6)
    builder.feather("LeftCheekFur", (-0.61, 0.86, 1.94), (0.42, 0.14, 0.38), white,
                    rotation=(math.radians(-4), math.radians(-62), 0.0), segments=12, rings=6)
    builder.feather("RightCheekFur", (0.61, 0.86, 1.94), (0.42, 0.14, 0.38), white,
                    rotation=(math.radians(-4), math.radians(62), 0.0), segments=12, rings=6)
    builder.feather("ForeheadTuftCenter", (0.0, 0.91, 2.63), (0.28, 0.10, 0.46), white,
                    rotation=(math.radians(-8), 0.0, math.radians(180)), segments=12, rings=6)
    builder.feather("ForeheadTuftLeft", (-0.23, 0.87, 2.58), (0.25, 0.10, 0.38), white,
                    rotation=(math.radians(-6), math.radians(-24), math.radians(180)), segments=12, rings=6)
    builder.feather("ForeheadTuftRight", (0.23, 0.87, 2.58), (0.25, 0.10, 0.38), white,
                    rotation=(math.radians(-6), math.radians(24), math.radians(180)), segments=12, rings=6)

    builder.feather("ChestRuffUpper", (0.0, 0.58, 1.60), (0.53, 0.24, 0.55), white,
                    rotation=(math.radians(180), 0.0, 0.0), segments=14, rings=7)
    builder.feather("ChestRuffLeft", (-0.29, 0.55, 1.37), (0.40, 0.23, 0.53), white,
                    rotation=(math.radians(180), math.radians(-20), 0.0), segments=12, rings=6)
    builder.feather("ChestRuffRight", (0.29, 0.55, 1.37), (0.40, 0.23, 0.53), white,
                    rotation=(math.radians(180), math.radians(20), 0.0), segments=12, rings=6)
    builder.feather("ChestRuffLower", (0.0, 0.51, 1.12), (0.44, 0.22, 0.48), white,
                    rotation=(math.radians(180), 0.0, 0.0), segments=12, rings=6)

    leg_positions = {
        "LeftFront": (-0.56, 0.15), "RightFront": (0.56, 0.15),
        "LeftRear": (-0.58, -0.73), "RightRear": (0.58, -0.73),
    }
    for label, (x, y) in leg_positions.items():
        builder.ellipsoid(f"{label}Leg", (x, y, 0.72), (0.29, 0.33, 0.49), cyan,
                          segments=12, rings=6)
        builder.ellipsoid(f"{label}Paw", (x, y + 0.10, 0.31), (0.34, 0.39, 0.25), blue,
                          segments=12, rings=6)

    builder.tube(
        "TailRoot",
        ((0.0, -1.08, 1.20), (0.38, -1.13, 1.34), (0.73, -1.08, 1.58)),
        (0.42, 0.39, 0.32),
        cyan,
        radial_segments=12,
    )
    builder.feather("TailPlume", (1.05, -0.96, 1.82), (0.66, 0.48, 1.12), white,
                    rotation=(math.radians(-8), math.radians(35), math.radians(-4)), segments=16, rings=8)
    builder.feather("TailTip", (1.57, -0.79, 2.49), (0.52, 0.40, 0.77), white,
                    rotation=(math.radians(-10), math.radians(29), math.radians(-3)), segments=14, rings=7)
    return body


def main() -> None:
    builder = PetMeshBuilder(PET_ID)
    builder.clean_scene()
    body = build(builder)
    builder.parent_to_body(body, {
        "PetId": PET_ID,
        "PetName": "Frost Fox",
        "Rarity": "Epic",
        "BaseRate": 50.0,
        "ModelVersion": "3.0.0",
        "ForwardAxis": "-Z",
        "Reference": REFERENCE,
    })
    builder.validate(
        body,
        EXPECTED_NAMES,
        {"FrostCyan", "FrostCyanLight", "FrostWhite", "FrostNavy", "FrostPawBlue", "EyeHighlight"},
        (3000, 6000),
        ((2.5, 3.7), (1.8, 2.8), (3.3, 4.0)),
    )
    builder.export(body)
    builder.diagnostics(REFERENCE)
    builder.render_preview()


if __name__ == "__main__":
    main()
