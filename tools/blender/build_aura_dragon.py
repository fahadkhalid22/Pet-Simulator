"""Build the reference-matched Auralit AuraDragon v3 mesh."""

from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pet_mesh_common import PetMeshBuilder


PET_ID = "AuraDragon"
REFERENCE = "assets/references/pets/ref_aura_dragon.png"
EXPECTED_NAMES = {
    "Body", "TorsoArmor", "Collar", "Head", "FaceMask", "LeftEye", "RightEye",
    "HelmetDome", "HelmetBand", "HelmetCrest", "LeftHelmetPillar", "RightHelmetPillar",
    "LeftHelmetRune", "RightHelmetRune", "LeftShoulder", "RightShoulder",
    "LeftArm", "RightArm", "LeftCuff", "RightCuff", "LeftHand", "RightHand",
    "LeftLeg", "RightLeg", "LeftBoot", "RightBoot", "LeftCoatPanel", "RightCoatPanel",
    "Belt", "ChestRune", "LeftSleeveRune", "RightSleeveRune", "LeftLegRune", "RightLegRune",
    "StaffShaft", "StaffLowerGrip", "StaffUpperGrip", "StaffCrown", "StaffLeftProng",
    "StaffRightProng", "StaffLeftClaw", "StaffRightClaw", "StaffFlameCore",
    "StaffFlameLeft", "StaffFlameRight", "StaffTip",
}


def build(builder: PetMeshBuilder):
    robe = builder.material("VoidRobe", (0.025, 0.04, 0.045, 1.0), 0.58)
    armor = builder.material("DragonArmor", (0.08, 0.13, 0.14, 1.0), 0.36, 0.08, 0.12)
    armor_light = builder.material("DragonArmorLight", (0.25, 0.39, 0.38, 1.0), 0.34, 0.06, 0.08)
    cyan = builder.material("AuraCyan", (0.01, 0.86, 0.84, 1.0), 0.22, 0.08, emission=1.5)
    cyan_soft = builder.material("AuraCyanSoft", (0.10, 0.96, 0.93, 1.0), 0.25, emission=0.8)
    staff_dark = builder.material("StaffDark", (0.025, 0.035, 0.035, 1.0), 0.40, metallic=0.18)

    body = builder.box("Body", (0.0, 0.0, 2.08), (1.42, 0.72, 1.48), robe, bevel=0.10)
    builder.box("TorsoArmor", (0.0, 0.39, 2.25), (1.14, 0.12, 1.05), armor, bevel=0.08)
    builder.box("Collar", (0.0, 0.43, 2.91), (0.72, 0.16, 0.22), armor_light, bevel=0.06)
    builder.ellipsoid("Head", (0.0, 0.03, 3.43), (0.59, 0.50, 0.59), cyan,
                      segments=20, rings=10)
    builder.feather("FaceMask", (0.0, 0.48, 3.48), (0.52, 0.10, 0.53), armor,
                    rotation=(math.radians(180), 0.0, 0.0), segments=14, rings=7)
    builder.feather("LeftEye", (-0.23, 0.59, 3.55), (0.19, 0.035, 0.075), cyan_soft,
                    rotation=(0.0, math.radians(-15), 0.0), segments=10, rings=5)
    builder.feather("RightEye", (0.23, 0.59, 3.55), (0.19, 0.035, 0.075), cyan_soft,
                    rotation=(0.0, math.radians(15), 0.0), segments=10, rings=5)

    builder.ellipsoid("HelmetDome", (0.0, -0.03, 3.88), (0.72, 0.55, 0.59), armor_light,
                      segments=20, rings=10)
    builder.torus("HelmetBand", (0.0, 0.03, 3.72), 0.60, 0.085, armor,
                  scale=(1.0, 1.0, 0.82), major_segments=16, minor_segments=6)
    builder.box("HelmetCrest", (0.0, -0.03, 4.20), (0.16, 0.64, 1.05), armor, bevel=0.05)
    for side, direction in (("Left", -1.0), ("Right", 1.0)):
        builder.tube(
            f"{side}HelmetPillar",
            ((direction * 0.61, -0.12, 3.78), (direction * 0.80, -0.11, 4.08),
             (direction * 0.83, -0.10, 4.78)),
            (0.21, 0.20, 0.16),
            armor,
            radial_segments=8,
        )
        builder.tube(
            f"{side}HelmetRune",
            ((direction * 0.69, 0.075, 3.87), (direction * 0.76, 0.08, 4.16),
             (direction * 0.77, 0.085, 4.58)),
            (0.025, 0.022, 0.020),
            cyan,
            radial_segments=5,
        )

    for side, direction in (("Left", -1.0), ("Right", 1.0)):
        builder.box(f"{side}Shoulder", (direction * 0.90, 0.0, 2.60), (0.40, 0.82, 0.72),
                    armor, bevel=0.08)
        builder.box(f"{side}Arm", (direction * 1.12, 0.0, 2.16), (0.50, 0.74, 1.18),
                    robe, bevel=0.09)
        builder.box(f"{side}Cuff", (direction * 1.12, 0.05, 1.61), (0.52, 0.76, 0.19),
                    cyan, bevel=0.055)
        builder.box(f"{side}Hand", (direction * 1.12, 0.03, 1.42), (0.44, 0.62, 0.32),
                    cyan, bevel=0.10)
        builder.box(f"{side}Leg", (direction * 0.38, 0.0, 0.78), (0.66, 0.69, 1.36),
                    robe, bevel=0.08)
        builder.box(f"{side}Boot", (direction * 0.38, 0.16, 0.17), (0.68, 0.98, 0.34),
                    armor, bevel=0.08)
        builder.feather(f"{side}CoatPanel", (direction * 0.39, 0.44, 1.53), (0.43, 0.09, 0.86),
                        armor, rotation=(math.radians(180), math.radians(direction * 5), 0.0),
                        segments=12, rings=6)

    builder.box("Belt", (0.0, 0.39, 1.44), (1.34, 0.15, 0.22), armor_light, bevel=0.05)

    builder.tube(
        "ChestRune",
        ((-0.42, 0.49, 2.70), (-0.18, 0.50, 2.42), (0.0, 0.51, 2.12),
         (0.18, 0.50, 2.42), (0.42, 0.49, 2.70)),
        (0.028, 0.025, 0.026, 0.025, 0.028),
        cyan,
        radial_segments=5,
    )
    for side, direction in (("Left", -1.0), ("Right", 1.0)):
        builder.tube(
            f"{side}SleeveRune",
            ((direction * 1.28, 0.385, 2.55), (direction * 1.02, 0.39, 2.30),
             (direction * 1.24, 0.395, 2.02), (direction * 1.00, 0.40, 1.78)),
            (0.023, 0.022, 0.022, 0.023),
            cyan,
            radial_segments=5,
        )
        builder.tube(
            f"{side}LegRune",
            ((direction * 0.55, 0.37, 1.22), (direction * 0.27, 0.375, 0.89),
             (direction * 0.53, 0.38, 0.54), (direction * 0.27, 0.385, 0.29)),
            (0.022, 0.020, 0.020, 0.022),
            cyan,
            radial_segments=5,
        )

    staff_x = -1.48
    builder.tube("StaffShaft", ((staff_x, 0.02, 0.30), (staff_x, 0.02, 3.93)),
                 (0.085, 0.085), staff_dark, radial_segments=10)
    builder.torus("StaffLowerGrip", (staff_x, 0.02, 1.05), 0.17, 0.06, armor_light,
                  rotation=(0.0, 0.0, 0.0), major_segments=12, minor_segments=5)
    builder.torus("StaffUpperGrip", (staff_x, 0.02, 2.57), 0.18, 0.065, armor_light,
                  rotation=(0.0, 0.0, 0.0), major_segments=12, minor_segments=5)
    builder.ellipsoid("StaffCrown", (staff_x, 0.02, 4.00), (0.34, 0.29, 0.34), armor,
                      segments=12, rings=6)
    builder.tube(
        "StaffLeftProng",
        ((staff_x - 0.14, 0.02, 4.10), (staff_x - 0.43, 0.02, 4.37), (staff_x - 0.47, 0.02, 4.76)),
        (0.10, 0.09, 0.055),
        armor,
        radial_segments=8,
    )
    builder.tube(
        "StaffRightProng",
        ((staff_x + 0.14, 0.02, 4.10), (staff_x + 0.43, 0.02, 4.37), (staff_x + 0.47, 0.02, 4.76)),
        (0.10, 0.09, 0.055),
        armor,
        radial_segments=8,
    )
    builder.tube("StaffLeftClaw", ((staff_x - 0.08, 0.02, 3.45), (staff_x - 0.40, 0.02, 3.65),
                                    (staff_x - 0.52, 0.02, 3.87)),
                 (0.075, 0.055, 0.025), staff_dark, radial_segments=7)
    builder.tube("StaffRightClaw", ((staff_x + 0.08, 0.02, 3.45), (staff_x + 0.40, 0.02, 3.65),
                                     (staff_x + 0.52, 0.02, 3.87)),
                 (0.075, 0.055, 0.025), staff_dark, radial_segments=7)
    builder.feather("StaffFlameCore", (staff_x, 0.02, 4.63), (0.25, 0.22, 0.61), cyan_soft,
                    segments=12, rings=6)
    builder.feather("StaffFlameLeft", (staff_x - 0.18, 0.01, 4.76), (0.16, 0.15, 0.46), cyan,
                    rotation=(0.0, math.radians(-15), 0.0), segments=10, rings=5)
    builder.feather("StaffFlameRight", (staff_x + 0.18, 0.01, 4.76), (0.16, 0.15, 0.46), cyan,
                    rotation=(0.0, math.radians(15), 0.0), segments=10, rings=5)
    builder.cone("StaffTip", (staff_x, 0.02, 0.12), 0.08, 0.0, 0.34, cyan,
                 rotation=(math.radians(180), 0.0, 0.0), vertices=10)
    return body


def main() -> None:
    builder = PetMeshBuilder(PET_ID)
    builder.clean_scene()
    body = build(builder)
    builder.parent_to_body(body, {
        "PetId": PET_ID,
        "PetName": "Aura Dragon",
        "Rarity": "Legendary",
        "BaseRate": 100.0,
        "ModelVersion": "3.0.0",
        "ForwardAxis": "-Z",
        "Reference": REFERENCE,
    })
    builder.validate(
        body,
        EXPECTED_NAMES,
        {"VoidRobe", "DragonArmor", "DragonArmorLight", "AuraCyan", "AuraCyanSoft", "StaffDark"},
        (4500, 9000),
        ((3.4, 4.3), (0.9, 1.5), (4.8, 5.5)),
    )
    builder.export(body)
    builder.diagnostics(REFERENCE)
    builder.render_preview()


if __name__ == "__main__":
    main()
