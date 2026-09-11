"""Build the reference-matched Auralit FluffDog v3 mesh."""

from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pet_mesh_common import PetMeshBuilder


PET_ID = "FluffDog"
REFERENCE = "assets/references/pets/ref_dog.png"
EXPECTED_NAMES = {
    "Body", "Head", "LeftEar", "RightEar", "FaceBlaze", "LeftMuzzle", "RightMuzzle",
    "LeftEye", "RightEye", "LeftIris", "RightIris", "LeftEyeHighlight", "RightEyeHighlight",
    "LeftBrow", "RightBrow", "LeftCheek", "RightCheek", "Nose", "Mouth", "Tongue", "Chest",
    "LeftFrontLeg", "RightFrontLeg", "LeftFrontPaw", "RightFrontPaw",
    "LeftRearLeg", "RightRearLeg", "LeftRearPaw", "RightRearPaw", "Tail", "TailTip",
}


def build(builder: PetMeshBuilder):
    slate = builder.material("DogSlate", (0.18, 0.24, 0.28, 1.0), 0.55)
    white = builder.material("DogWhite", (0.91, 0.91, 0.86, 1.0), 0.58)
    caramel = builder.material("DogCaramel", (0.66, 0.31, 0.11, 1.0), 0.52)
    black = builder.material("EyeBlack", (0.008, 0.006, 0.005, 1.0), 0.14, 0.22)
    amber = builder.material("EyeAmber", (0.89, 0.48, 0.07, 1.0), 0.24, 0.12)
    highlight = builder.material("EyeHighlight", (1.0, 0.98, 0.90, 1.0), 0.14)
    mouth_dark = builder.material("MouthDark", (0.06, 0.025, 0.02, 1.0), 0.3)
    tongue = builder.material("TonguePink", (0.86, 0.24, 0.26, 1.0), 0.42)

    body = builder.ellipsoid("Body", (0.0, -0.10, 1.15), (0.80, 0.69, 1.04), slate, segments=18, rings=9)
    builder.ellipsoid("Head", (0.0, 0.02, 2.46), (1.12, 0.78, 0.88), slate, segments=18, rings=9)
    builder.feather("LeftEar", (-0.94, -0.02, 2.54), (0.48, 0.30, 0.75), slate,
                    rotation=(math.radians(6), math.radians(-58), math.radians(-8)), segments=14, rings=7)
    builder.feather("RightEar", (0.94, -0.02, 2.54), (0.48, 0.30, 0.75), slate,
                    rotation=(math.radians(6), math.radians(58), math.radians(8)), segments=14, rings=7)
    builder.feather("FaceBlaze", (0.0, 0.77, 2.64), (0.31, 0.06, 0.70), white, segments=12, rings=6)
    builder.ellipsoid("LeftMuzzle", (-0.30, 0.73, 2.23), (0.52, 0.22, 0.39), white, segments=14, rings=7)
    builder.ellipsoid("RightMuzzle", (0.30, 0.73, 2.23), (0.52, 0.22, 0.39), white, segments=14, rings=7)

    for side, x in (("Left", -0.40), ("Right", 0.40)):
        builder.ellipsoid(f"{side}Eye", (x, 0.79, 2.56), (0.24, 0.09, 0.27), black, segments=14, rings=7)
        builder.ellipsoid(f"{side}Iris", (x, 0.88, 2.55), (0.14, 0.035, 0.17), amber, segments=12, rings=6)
        builder.ellipsoid(f"{side}EyeHighlight", (x - 0.045, 0.915, 2.65), (0.045, 0.018, 0.055),
                          highlight, segments=8, rings=4)
        builder.feather(f"{side}Brow", (x, 0.79, 2.89), (0.25, 0.055, 0.12), caramel,
                        rotation=(math.radians(90), 0.0, 0.0), segments=10, rings=5)
        builder.ellipsoid(f"{side}Cheek", (x * 1.55, 0.70, 2.29), (0.28, 0.11, 0.23), caramel,
                          segments=12, rings=6)

    builder.ellipsoid("Nose", (0.0, 0.97, 2.28), (0.17, 0.10, 0.12), mouth_dark, segments=12, rings=6)
    builder.tube(
        "Mouth",
        ((-0.28, 0.965, 2.14), (-0.13, 1.00, 2.04), (0.0, 1.01, 2.01),
         (0.13, 1.00, 2.04), (0.28, 0.965, 2.14)),
        (0.018, 0.018, 0.018, 0.018, 0.018),
        mouth_dark,
        radial_segments=6,
    )
    builder.feather("Tongue", (0.0, 1.00, 1.99), (0.15, 0.045, 0.20), tongue,
                    rotation=(math.radians(180), 0.0, 0.0), segments=10, rings=5)
    builder.feather("Chest", (0.0, 0.56, 1.23), (0.58, 0.22, 0.91), white, segments=14, rings=7)

    for side, x in (("Left", -0.38), ("Right", 0.38)):
        builder.ellipsoid(f"{side}FrontLeg", (x, 0.38, 0.68), (0.27, 0.28, 0.61), caramel,
                          segments=12, rings=6)
        builder.ellipsoid(f"{side}FrontPaw", (x, 0.58, 0.24), (0.36, 0.38, 0.24), white,
                          segments=12, rings=6)
        builder.ellipsoid(f"{side}RearLeg", (x * 1.72, -0.24, 0.67), (0.49, 0.57, 0.63), caramel,
                          segments=12, rings=6)
        builder.ellipsoid(f"{side}RearPaw", (x * 1.72, 0.32, 0.23), (0.43, 0.47, 0.25), white,
                          segments=12, rings=6)

    builder.tube(
        "Tail",
        ((0.62, -0.42, 0.76), (0.91, -0.43, 0.93), (1.13, -0.30, 1.12), (1.24, -0.06, 1.20)),
        (0.27, 0.25, 0.21, 0.15),
        slate,
        radial_segments=10,
    )
    builder.feather("TailTip", (1.23, -0.01, 1.30), (0.25, 0.22, 0.37), white,
                    rotation=(math.radians(-22), math.radians(18), 0.0), segments=12, rings=6)
    return body


def main() -> None:
    builder = PetMeshBuilder(PET_ID)
    builder.clean_scene()
    body = build(builder)
    builder.parent_to_body(body, {
        "PetId": PET_ID,
        "PetName": "Fluff Dog",
        "Rarity": "Common",
        "BaseRate": 10.0,
        "ModelVersion": "3.0.0",
        "ForwardAxis": "-Z",
        "Reference": REFERENCE,
    })
    builder.validate(
        body,
        EXPECTED_NAMES,
        {"DogSlate", "DogWhite", "DogCaramel", "EyeBlack", "EyeAmber", "EyeHighlight", "MouthDark", "TonguePink"},
        (2500, 5500),
        ((2.7, 3.3), (1.5, 2.3), (3.1, 3.8)),
    )
    builder.export(body)
    builder.diagnostics(REFERENCE)
    builder.render_preview()


if __name__ == "__main__":
    main()
