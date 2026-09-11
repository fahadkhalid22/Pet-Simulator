"""Build the reference-matched Auralit ChibiCat v3 mesh."""

from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pet_mesh_common import PetMeshBuilder


PET_ID = "ChibiCat"
REFERENCE = "assets/references/pets/ref_cat.png"
EXPECTED_NAMES = {
    "Body", "Head", "LeftOuterEar", "RightOuterEar", "LeftInnerEar", "RightInnerEar",
    "LeftMuzzle", "RightMuzzle", "ForeheadBlaze", "LeftEye", "RightEye",
    "LeftEyeRing", "RightEyeRing", "LeftEyeHighlight", "RightEyeHighlight", "Nose",
    "Mouth", "Chest", "LeftFrontLeg", "RightFrontLeg", "LeftFrontPaw", "RightFrontPaw",
    "LeftHaunch", "RightHaunch", "LeftToe1", "LeftToe2", "LeftToe3",
    "RightToe1", "RightToe2", "RightToe3", "Tail",
}


def build(builder: PetMeshBuilder):
    charcoal = builder.material("CatCharcoal", (0.105, 0.09, 0.10, 1.0), 0.31, 0.08)
    white = builder.material("CatWhite", (0.96, 0.94, 0.90, 1.0), 0.42, 0.04)
    pink = builder.material("InnerEarPink", (0.92, 0.48, 0.49, 1.0), 0.43)
    black = builder.material("EyeBlack", (0.004, 0.003, 0.004, 1.0), 0.08, 0.38)
    lime = builder.material("EyeLime", (0.67, 0.93, 0.02, 1.0), 0.25, 0.12)
    highlight = builder.material("EyeHighlight", (1.0, 1.0, 1.0, 1.0), 0.12, 0.2)
    nose_dark = builder.material("NoseDark", (0.055, 0.045, 0.05, 1.0), 0.2, 0.15)

    body = builder.ellipsoid("Body", (0.0, -0.10, 1.18), (0.77, 0.69, 1.05), charcoal, segments=22, rings=11)
    builder.ellipsoid("Head", (0.0, 0.02, 2.52), (1.06, 0.79, 0.86), charcoal, segments=22, rings=11)
    builder.feather("LeftOuterEar", (-0.55, -0.02, 3.15), (0.39, 0.26, 0.58), charcoal, rotation=(0.0, math.radians(-16), 0.0))
    builder.feather("RightOuterEar", (0.55, -0.02, 3.15), (0.39, 0.26, 0.58), charcoal, rotation=(0.0, math.radians(16), 0.0))
    builder.feather("LeftInnerEar", (-0.55, 0.20, 3.16), (0.21, 0.045, 0.38), pink, rotation=(0.0, math.radians(-16), 0.0))
    builder.feather("RightInnerEar", (0.55, 0.20, 3.16), (0.21, 0.045, 0.38), pink, rotation=(0.0, math.radians(16), 0.0))

    builder.ellipsoid("LeftMuzzle", (-0.34, 0.69, 2.28), (0.61, 0.20, 0.46), white, segments=16, rings=8)
    builder.ellipsoid("RightMuzzle", (0.34, 0.69, 2.28), (0.61, 0.20, 0.46), white, segments=16, rings=8)
    builder.feather("ForeheadBlaze", (0.0, 0.79, 2.77), (0.31, 0.045, 0.58), white, segments=12, rings=6)

    for side, x in (("Left", -0.40), ("Right", 0.40)):
        builder.ellipsoid(f"{side}Eye", (x, 0.90, 2.55), (0.235, 0.085, 0.285), black, segments=16, rings=8)
        builder.torus(f"{side}EyeRing", (x, 0.99, 2.55), 0.235, 0.032, lime, scale=(1.0, 1.0, 1.18))
        builder.ellipsoid(f"{side}EyeHighlight", (x - 0.045, 1.01, 2.65), (0.045, 0.025, 0.06), highlight, segments=8, rings=4)

    builder.ellipsoid("Nose", (0.0, 0.93, 2.25), (0.13, 0.075, 0.09), nose_dark, segments=10, rings=5)
    builder.tube(
        "Mouth",
        ((-0.16, 0.965, 2.16), (0.0, 0.98, 2.08), (0.16, 0.965, 2.16)),
        (0.018, 0.018, 0.018),
        nose_dark,
        radial_segments=6,
    )
    builder.feather("Chest", (0.0, 0.55, 1.28), (0.55, 0.22, 0.88), white, segments=14, rings=7)

    for side, x in (("Left", -0.36), ("Right", 0.36)):
        builder.ellipsoid(f"{side}FrontLeg", (x, 0.42, 0.64), (0.25, 0.27, 0.60), charcoal, segments=12, rings=6)
        builder.ellipsoid(f"{side}FrontPaw", (x, 0.58, 0.22), (0.34, 0.39, 0.22), white, segments=12, rings=6)
        for toe_index, toe_x in enumerate((-0.10, 0.0, 0.10), start=1):
            builder.tube(
                f"{side}Toe{toe_index}",
                ((x + toe_x, 0.955, 0.16), (x + toe_x, 0.96, 0.27)),
                (0.011, 0.011),
                nose_dark,
                radial_segments=5,
            )

    builder.ellipsoid("LeftHaunch", (-0.67, -0.20, 0.70), (0.53, 0.63, 0.66), charcoal, segments=14, rings=7)
    builder.ellipsoid("RightHaunch", (0.67, -0.20, 0.70), (0.53, 0.63, 0.66), charcoal, segments=14, rings=7)
    builder.tube(
        "Tail",
        (
            (0.62, -0.48, 0.78), (0.94, -0.43, 0.88), (1.15, -0.25, 0.73),
            (1.20, -0.08, 0.48), (1.08, 0.02, 0.27), (0.86, 0.05, 0.22),
            (0.68, 0.07, 0.36),
        ),
        (0.25, 0.25, 0.24, 0.22, 0.19, 0.15, 0.08),
        charcoal,
        radial_segments=10,
    )
    return body


def main() -> None:
    builder = PetMeshBuilder(PET_ID)
    builder.clean_scene()
    body = build(builder)
    builder.parent_to_body(body, {
        "PetId": PET_ID,
        "PetName": "Chibi Cat",
        "Rarity": "Common",
        "BaseRate": 10.0,
        "ModelVersion": "3.0.0",
        "ForwardAxis": "-Z",
        "Reference": REFERENCE,
    })
    builder.validate(
        body,
        EXPECTED_NAMES,
        {"CatCharcoal", "CatWhite", "InnerEarPink", "EyeBlack", "EyeLime", "EyeHighlight", "NoseDark"},
        (2500, 5000),
        ((2.2, 2.8), (1.6, 2.4), (3.2, 3.9)),
    )
    builder.export(body)
    builder.diagnostics(REFERENCE)
    builder.render_preview()


if __name__ == "__main__":
    main()
