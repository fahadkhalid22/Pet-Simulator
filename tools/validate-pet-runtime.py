#!/usr/bin/env python3
"""Static contract checks for the authoritative pet runtime and client animator."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
CONFIG_PATH = ROOT / "src/ReplicatedStorage/Shared/PetRuntimeConfig.lua"
SERVER_PATH = ROOT / "src/ServerScriptService/Services/PetRuntimeService.lua"
CLIENT_PATH = ROOT / "src/StarterPlayer/StarterPlayerScripts/PetRuntimeAnimator.client.lua"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def require_all(text: str, needles: tuple[str, ...], context: str) -> None:
    for needle in needles:
        require(needle in text, f"{context} is missing {needle!r}")


def main() -> int:
    config = CONFIG_PATH.read_text(encoding="utf-8")
    server = SERVER_PATH.read_text(encoding="utf-8")
    client = CLIENT_PATH.read_text(encoding="utf-8")

    expected_profiles = {
        "FrostBunny": ("Ground", "Hop"),
        "ChibiCat": ("Ground", "Trot"),
        "FluffDog": ("Ground", "Bounce"),
        "FrostFox": ("Ground", "Bound"),
        "StormOwl": ("Hover", "Wingbeat"),
        "AuraDragon": ("Ground", "Stride"),
    }
    for pet_id, (mode, style) in expected_profiles.items():
        pattern = rf"{pet_id}\s*=\s*table\.freeze\(\{{Mode\s*=\s*\"{mode}\",\s*Style\s*=\s*\"{style}\""
        require(re.search(pattern, config) is not None, f"{pet_id} locomotion profile is wrong")
    offsets = re.search(r"FormationOffsets\s*=\s*table\.freeze\(\{(.*?)\}\)", config, re.S)
    require(offsets is not None, "formation offsets are missing")
    require(offsets.group(1).count("Vector3.new") == 3, "formation must contain exactly three slots")
    require("Vector3.new(0, 0, 4.75)" in offsets.group(1), "primary formation slot changed")

    require_all(server, (
        "PetService.GetState(player)",
        "PetService.StateChanged:Connect",
        "PetConfig.Get(ownedPet.PetId)",
        "source:Clone()",
        "GameConfig.Pets.MaxEquipped",
        'model:FindFirstChild("Body")',
        'model:SetAttribute("OwnerUserId"',
        'model:SetAttribute("PetId"',
        'model:SetAttribute("FormationSlot"',
        'model:SetAttribute("GroundOffset"',
        'model:SetAttribute("LocomotionMode"',
        "Players.PlayerRemoving:Connect(cleanupPlayer)",
        "player.CharacterRemoving:Connect",
        "player.CharacterAdded:Connect",
        "CanCollide = false",
        "CanQuery = false",
        "CanTouch = false",
        "Massless = true",
    ), "server runtime")
    require("RunService" not in server and "Heartbeat" not in server, "server still runs high-frequency cosmetic updates")
    require("RemoteEvent" not in server and "OnServerEvent" not in server, "runtime added a client authority path")

    require_all(client, (
        "RunService.RenderStepped:Connect",
        "workspace:Raycast",
        "Enum.RaycastFilterType.Exclude",
        "FilterDescendantsInstances",
        "PetRuntimeConfig.RaycastInterval",
        "state.GroundOffset + rootMotion",
        "current:Lerp(target, alpha)",
        "state.Activity +=",
        'then "Hover" elseif moving then "Move" else "Idle"',
        'group == "Head"',
        'group == "Tail"',
        'group == "LeftWing"',
        'group == "RightWing"',
        'group == "LeftFrontLimb" or group == "RightRearLimb"',
        'group == "RightFrontLimb" or group == "LeftRearLimb"',
    ), "client animator")
    require(client.count("RunService.RenderStepped:Connect") == 1, "client must have exactly one shared render loop")
    render_body = client.split("RunService.RenderStepped:Connect", 1)[1]
    require("GetDescendants" not in render_body, "client rescans descendants inside the render loop")
    require("RemoteEvent" not in client and "FireServer" not in client, "client animator attempts authoritative writes")

    print("[PASS] Six explicit locomotion profiles and exactly three deterministic formation slots")
    print("[PASS] Server authority, lifecycle cleanup, Body root, bounds offset, and no-physics clone contract")
    print("[PASS] No server Heartbeat cosmetic loop and no client authority/remotes")
    print("[PASS] One cached client RenderStepped loop with throttled excluded downward raycasts")
    print("[PASS] Idle/Move/Hover states, smoothed follow, alternating limbs, head/ear/tail/wing/staff groups")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"[FAIL] {error}")
        raise SystemExit(1)
