"""Build the Auralit FrostBunny v3 mesh candidate with Blender 5.2 LTS.

The reference contract is assets/references/pets/ref_bunny.png. Blender uses
Z-up internally, so the character faces +Y here; glTF's Y-up conversion maps
that direction to the Auralit/Roblox -Z forward axis.
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector


REPO_ROOT = Path(__file__).resolve().parents[2]
GLB_PATH = REPO_ROOT / "assets" / "models" / "pets" / "FrostBunny.glb"
PREVIEW_PATH = REPO_ROOT / "assets" / "models" / "pets" / "FrostBunny_preview.png"
SCRIPT_ARGS = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
PREVIEW_ONLY = "--preview-only" in SCRIPT_ARGS

CHARACTER_COLLECTION: bpy.types.Collection
CHARACTER_OBJECTS: list[bpy.types.Object] = []
MATERIALS: dict[str, bpy.types.Material] = {}

PET_ID = "FrostBunny"
REFERENCE = "assets/references/pets/ref_bunny.png"
EXPECTED_NAMES = {
    "Body", "Head", "LeftEar", "RightEar", "LeftInnerEar", "RightInnerEar",
    "LeftEye", "RightEye", "LeftEyeHighlight", "RightEyeHighlight", "Nose",
    "LeftMuzzle", "RightMuzzle", "LeftCheek", "RightCheek", "Mouth",
    "LeftArm", "RightArm", "LeftLeg", "RightLeg", "LeftFoot", "RightFoot",
    "LeftPawPad", "RightPawPad", "LeftToePad1", "LeftToePad2", "LeftToePad3",
    "RightToePad1", "RightToePad2", "RightToePad3", "Tail",
}


def clean_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for datablocks in (bpy.data.meshes, bpy.data.curves, bpy.data.materials, bpy.data.cameras, bpy.data.lights):
        for datablock in list(datablocks):
            if datablock.users == 0:
                datablocks.remove(datablock)


def make_material(
    name: str,
    rgba: tuple[float, float, float, float],
    roughness: float,
    coat: float = 0.0,
) -> bpy.types.Material:
    material = bpy.data.materials.new(name)
    material.diffuse_color = rgba
    material.use_nodes = True
    principled = material.node_tree.nodes.get("Principled BSDF")
    if principled:
        principled.inputs["Base Color"].default_value = rgba
        principled.inputs["Roughness"].default_value = roughness
        if "Coat Weight" in principled.inputs:
            principled.inputs["Coat Weight"].default_value = coat
    MATERIALS[name] = material
    return material


def register_object(obj: bpy.types.Object, material: bpy.types.Material | None = None) -> bpy.types.Object:
    for collection in list(obj.users_collection):
        collection.objects.unlink(obj)
    CHARACTER_COLLECTION.objects.link(obj)
    if material and hasattr(obj.data, "materials"):
        obj.data.materials.append(material)
    CHARACTER_OBJECTS.append(obj)
    return obj


def apply_rotation_scale(obj: bpy.types.Object) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)


def smooth_mesh(obj: bpy.types.Object) -> None:
    for polygon in obj.data.polygons:
        polygon.use_smooth = True


def add_ellipsoid(
    name: str,
    location: tuple[float, float, float],
    scale: tuple[float, float, float],
    material: bpy.types.Material,
    *,
    rotation: tuple[float, float, float] = (0.0, 0.0, 0.0),
    segments: int = 16,
    rings: int = 8,
    deform=None,
) -> bpy.types.Object:
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=segments,
        ring_count=rings,
        radius=1.0,
        location=location,
        rotation=rotation,
    )
    obj = bpy.context.object
    obj.name = name
    obj.data.name = f"{name}_Mesh"
    if deform:
        for vertex in obj.data.vertices:
            deform(vertex.co)
    obj.scale = scale
    apply_rotation_scale(obj)
    smooth_mesh(obj)
    return register_object(obj, material)


def add_tapered_ear(
    name: str,
    location: tuple[float, float, float],
    width: float,
    depth: float,
    height: float,
    tilt_degrees: float,
    material: bpy.types.Material,
    *,
    length_segments: int = 14,
    radial_segments: int = 12,
) -> bpy.types.Object:
    vertices: list[tuple[float, float, float]] = [(0.0, 0.0, -height * 0.5)]
    for ring in range(1, length_segments):
        t = ring / length_segments
        profile = math.sin(math.pi * t) ** 0.48
        # The slightly fuller upper half follows the reference's spoon-like tip.
        profile *= 0.94 + 0.10 * t
        z = -height * 0.5 + height * t
        for side in range(radial_segments):
            angle = math.tau * side / radial_segments
            vertices.append(
                (
                    math.cos(angle) * width * 0.5 * profile,
                    math.sin(angle) * depth * 0.5 * profile,
                    z,
                )
            )
    top_index = len(vertices)
    vertices.append((0.0, 0.0, height * 0.5))

    faces: list[tuple[int, ...]] = []
    first_ring = 1
    for side in range(radial_segments):
        nxt = (side + 1) % radial_segments
        faces.append((0, first_ring + nxt, first_ring + side))
    for ring in range(length_segments - 2):
        lower = 1 + ring * radial_segments
        upper = lower + radial_segments
        for side in range(radial_segments):
            nxt = (side + 1) % radial_segments
            faces.append((lower + side, lower + nxt, upper + nxt, upper + side))
    last_ring = 1 + (length_segments - 2) * radial_segments
    for side in range(radial_segments):
        nxt = (side + 1) % radial_segments
        faces.append((last_ring + side, last_ring + nxt, top_index))

    mesh = bpy.data.meshes.new(f"{name}_Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    obj.location = location
    obj.rotation_euler = (0.0, math.radians(tilt_degrees), 0.0)
    CHARACTER_COLLECTION.objects.link(obj)
    CHARACTER_OBJECTS.append(obj)
    obj.data.materials.append(material)
    apply_rotation_scale(obj)
    smooth_mesh(obj)
    return obj


def add_tube_curves(
    name: str,
    paths: list[list[tuple[float, float, float]]],
    radius: float,
    material: bpy.types.Material,
) -> bpy.types.Object:
    curve = bpy.data.curves.new(f"{name}_Curve", type="CURVE")
    curve.dimensions = "3D"
    curve.bevel_depth = radius
    curve.bevel_resolution = 2
    curve.resolution_u = 3
    for points in paths:
        spline = curve.splines.new("BEZIER")
        spline.bezier_points.add(len(points) - 1)
        for bezier_point, point in zip(spline.bezier_points, points):
            bezier_point.co = point
            bezier_point.handle_left_type = "AUTO"
            bezier_point.handle_right_type = "AUTO"
    obj = bpy.data.objects.new(name, curve)
    CHARACTER_COLLECTION.objects.link(obj)
    curve.materials.append(material)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.convert(target="MESH")
    obj = bpy.context.object
    obj.name = name
    obj.data.name = f"{name}_Mesh"
    smooth_mesh(obj)
    CHARACTER_OBJECTS.append(obj)
    return obj


def deform_head(co: Vector) -> None:
    # Broaden the lower face without changing the rounded crown.
    lower_cheek = max(0.0, 1.0 - abs((co.z + 0.28) * 1.55))
    co.x *= 1.0 + 0.10 * lower_cheek
    if co.y > 0.0 and co.z < 0.15:
        co.y *= 0.94


def deform_body(co: Vector) -> None:
    # Compact shoulders and a softly fuller lower torso match the turntable.
    vertical = max(-1.0, min(1.0, co.z))
    co.x *= 1.0 - 0.07 * vertical
    co.y *= 1.0 - 0.035 * vertical


def deform_nose(co: Vector) -> None:
    # A rounded inverted-triangle profile rather than a generic oval nose.
    co.x *= 1.0 + 0.28 * max(-0.6, min(0.8, co.z))
    if co.z < -0.45:
        co.x *= 0.82


def deform_ear(co: Vector) -> None:
    # A UV sphere supplies smooth cap topology, then this narrows the embedded
    # base and slightly fills the upper lobe to match the reference ear.
    if co.z < 0.0:
        co.x *= 0.72 + 0.28 * (co.z + 1.0)
        co.y *= 0.82 + 0.18 * (co.z + 1.0)
    elif co.z > 0.35:
        co.x *= 1.0 + 0.05 * (1.0 - co.z)


def add_cheek_patch(name: str, side: float, material: bpy.types.Material) -> bpy.types.Object:
    segments = 16
    rings = 3
    center_x = 0.64 * side
    center_z = 2.59

    def surface_point(x: float, z: float) -> tuple[float, float, float]:
        normalized_x = x / 1.07
        normalized_z = (z - 2.82) / 0.88
        front = math.sqrt(max(0.0, 1.0 - normalized_x * normalized_x - normalized_z * normalized_z))
        y = 0.03 + 0.80 * front * 0.94 + 0.008
        return (x, y, z)

    vertices = [surface_point(center_x, center_z)]
    for ring in range(1, rings + 1):
        radius = ring / rings
        for index in range(segments):
            angle = math.tau * index / segments
            x = center_x + math.cos(angle) * 0.17 * radius
            z = center_z + math.sin(angle) * 0.105 * radius
            vertices.append(surface_point(x, z))

    faces: list[tuple[int, ...]] = []
    for index in range(segments):
        nxt = (index + 1) % segments
        faces.append((0, 1 + nxt, 1 + index))
    for ring in range(rings - 1):
        inner = 1 + ring * segments
        outer = inner + segments
        for index in range(segments):
            nxt = (index + 1) % segments
            faces.append((inner + index, inner + nxt, outer + nxt, outer + index))

    mesh = bpy.data.meshes.new(f"{name}_Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    CHARACTER_COLLECTION.objects.link(obj)
    obj.data.materials.append(material)
    CHARACTER_OBJECTS.append(obj)
    smooth_mesh(obj)
    return obj


def create_materials() -> None:
    make_material("BunnyWhite", (0.975, 0.955, 0.965, 1.0), 0.34, 0.08)
    make_material("InnerEarPink", (1.0, 0.255, 0.36, 1.0), 0.38, 0.05)
    make_material("EyeBlack", (0.006, 0.004, 0.006, 1.0), 0.09, 0.32)
    make_material("EyeHighlight", (1.0, 1.0, 1.0, 1.0), 0.12, 0.18)
    make_material("NosePink", (1.0, 0.20, 0.30, 1.0), 0.25, 0.16)
    make_material("CheekPink", (1.0, 0.58, 0.66, 1.0), 0.48, 0.0)
    make_material("PawPink", (1.0, 0.31, 0.43, 1.0), 0.4, 0.02)
    make_material("MouthBlack", (0.025, 0.012, 0.018, 1.0), 0.3, 0.0)


def build_character() -> bpy.types.Object:
    white = MATERIALS["BunnyWhite"]
    inner_pink = MATERIALS["InnerEarPink"]
    eye_black = MATERIALS["EyeBlack"]
    highlight = MATERIALS["EyeHighlight"]
    nose_pink = MATERIALS["NosePink"]
    cheek_pink = MATERIALS["CheekPink"]

    body = add_ellipsoid(
        "Body",
        (0.0, -0.02, 1.42),
        (0.75, 0.65, 1.14),
        white,
        segments=20,
        rings=10,
        deform=deform_body,
    )
    head = add_ellipsoid(
        "Head",
        (0.0, 0.03, 2.82),
        (1.0, 0.80, 0.88),
        white,
        segments=24,
        rings=12,
        deform=deform_head,
    )

    add_ellipsoid(
        "LeftInnerEar",
        (-0.50, 0.205, 3.74),
        (0.195, 0.0375, 0.60),
        inner_pink,
        rotation=(0.0, math.radians(-13.0), 0.0),
        segments=14,
        rings=9,
        deform=deform_ear,
    )
    add_ellipsoid(
        "RightInnerEar",
        (0.50, 0.205, 3.74),
        (0.195, 0.0375, 0.60),
        inner_pink,
        rotation=(0.0, math.radians(13.0), 0.0),
        segments=14,
        rings=9,
        deform=deform_ear,
    )
    add_ellipsoid("LeftEar", (-0.50, -0.04, 3.73), (0.31, 0.24, 0.79), white, rotation=(0.0, math.radians(-13.0), 0.0), segments=16, rings=12, deform=deform_ear)
    add_ellipsoid("RightEar", (0.50, -0.04, 3.73), (0.31, 0.24, 0.79), white, rotation=(0.0, math.radians(13.0), 0.0), segments=16, rings=12, deform=deform_ear)

    add_ellipsoid("LeftMuzzle", (-0.22, 0.79, 2.56), (0.35, 0.19, 0.26), white, segments=14, rings=7)
    add_ellipsoid("RightMuzzle", (0.22, 0.79, 2.56), (0.35, 0.19, 0.26), white, segments=14, rings=7)
    add_ellipsoid("LeftEye", (-0.40, 0.775, 2.93), (0.17, 0.085, 0.285), eye_black, segments=18, rings=9)
    add_ellipsoid("RightEye", (0.40, 0.775, 2.93), (0.17, 0.085, 0.285), eye_black, segments=18, rings=9)
    add_ellipsoid("LeftEyeHighlight", (-0.445, 0.858, 3.045), (0.043, 0.022, 0.062), highlight, segments=8, rings=4)
    add_ellipsoid("RightEyeHighlight", (0.355, 0.858, 3.045), (0.043, 0.022, 0.062), highlight, segments=8, rings=4)
    add_ellipsoid("Nose", (0.0, 1.025, 2.625), (0.145, 0.095, 0.105), nose_pink, segments=14, rings=7, deform=deform_nose)
    add_cheek_patch("LeftCheek", -1.0, cheek_pink)
    add_cheek_patch("RightCheek", 1.0, cheek_pink)

    add_tube_curves(
        "Mouth",
        [
            [(0.0, 1.042, 2.54), (0.0, 1.047, 2.47)],
            [(0.0, 1.047, 2.47), (-0.075, 1.045, 2.435), (-0.15, 1.035, 2.47)],
            [(0.0, 1.047, 2.47), (0.075, 1.045, 2.435), (0.15, 1.035, 2.47)],
        ],
        0.012,
        MATERIALS["MouthBlack"],
    )

    # Short, tapered limbs overlap the torso so the silhouette reads as one
    # soft character rather than a set of disconnected shapes.
    add_ellipsoid(
        "LeftArm",
        (-0.86, 0.01, 1.58),
        (0.285, 0.30, 0.69),
        white,
        rotation=(0.0, math.radians(18.0), 0.0),
        segments=14,
        rings=7,
    )
    add_ellipsoid(
        "RightArm",
        (0.86, 0.01, 1.58),
        (0.285, 0.30, 0.69),
        white,
        rotation=(0.0, math.radians(-18.0), 0.0),
        segments=14,
        rings=7,
    )
    add_ellipsoid("LeftLeg", (-0.39, -0.02, 0.60), (0.35, 0.36, 0.58), white, segments=14, rings=7)
    add_ellipsoid("RightLeg", (0.39, -0.02, 0.60), (0.35, 0.36, 0.58), white, segments=14, rings=7)
    add_ellipsoid("LeftFoot", (-0.40, 0.20, 0.27), (0.43, 0.56, 0.27), white, segments=14, rings=7)
    add_ellipsoid("RightFoot", (0.40, 0.20, 0.27), (0.43, 0.56, 0.27), white, segments=14, rings=7)

    paw_pink = MATERIALS["PawPink"]
    add_ellipsoid("LeftPawPad", (-0.40, 0.25, 0.003), (0.22, 0.28, 0.004), paw_pink, segments=8, rings=4)
    add_ellipsoid("RightPawPad", (0.40, 0.25, 0.003), (0.22, 0.28, 0.004), paw_pink, segments=8, rings=4)
    for side_name, center_x in (("Left", -0.40), ("Right", 0.40)):
        for index, x_offset in enumerate((-0.15, 0.0, 0.15), start=1):
            add_ellipsoid(
                f"{side_name}ToePad{index}",
                (center_x + x_offset, 0.48, 0.003),
                (0.075, 0.095, 0.004),
                paw_pink,
                segments=6,
                rings=4,
            )

    add_ellipsoid("Tail", (0.0, -0.73, 1.18), (0.34, 0.34, 0.34), white, segments=12, rings=6)

    # Body is the canonical GLB root and carries the import metadata as extras.
    for obj in CHARACTER_OBJECTS:
        if obj is body:
            continue
        world_matrix = obj.matrix_world.copy()
        obj.parent = body
        obj.matrix_world = world_matrix

    body["PetId"] = "FrostBunny"
    body["PetName"] = "Frost Bunny"
    body["Rarity"] = "Rare"
    body["BaseRate"] = 25.0
    body["ModelVersion"] = "3.0.0"
    body["ForwardAxis"] = "-Z"
    body["Reference"] = "assets/references/pets/ref_bunny.png"
    body["ReviewStatus"] = "CANDIDATE_AWAITING_DIRECTOR_REVIEW"
    return body


def mesh_triangle_count() -> int:
    total = 0
    for obj in CHARACTER_OBJECTS:
        if obj.type == "MESH":
            obj.data.calc_loop_triangles()
            total += len(obj.data.loop_triangles)
    return total


def character_bounds() -> tuple[Vector, Vector, Vector]:
    minimum = Vector((math.inf, math.inf, math.inf))
    maximum = Vector((-math.inf, -math.inf, -math.inf))
    for obj in CHARACTER_OBJECTS:
        if obj.type != "MESH":
            continue
        for corner in obj.bound_box:
            world_corner = obj.matrix_world @ Vector(corner)
            minimum.x = min(minimum.x, world_corner.x)
            minimum.y = min(minimum.y, world_corner.y)
            minimum.z = min(minimum.z, world_corner.z)
            maximum.x = max(maximum.x, world_corner.x)
            maximum.y = max(maximum.y, world_corner.y)
            maximum.z = max(maximum.z, world_corner.z)
    return minimum, maximum, maximum - minimum


def print_diagnostics() -> None:
    minimum, maximum, dimensions = character_bounds()
    meshes = [obj for obj in CHARACTER_OBJECTS if obj.type == "MESH"]
    material_names = sorted({slot.material.name for obj in meshes for slot in obj.material_slots if slot.material})
    print("[FrostBunny] Reference: assets/references/pets/ref_bunny.png")
    print(f"[FrostBunny] Objects: {len(CHARACTER_OBJECTS)}")
    print(f"[FrostBunny] Meshes: {len(meshes)}")
    print(f"[FrostBunny] Triangles: {mesh_triangle_count()}")
    print(
        "[FrostBunny] Bounds XYZ: "
        f"min=({minimum.x:.4f}, {minimum.y:.4f}, {minimum.z:.4f}) "
        f"max=({maximum.x:.4f}, {maximum.y:.4f}, {maximum.z:.4f})"
    )
    print(
        "[FrostBunny] Dimensions XYZ (Blender): "
        f"({dimensions.x:.4f}, {dimensions.y:.4f}, {dimensions.z:.4f})"
    )
    print("[FrostBunny] Orientation: Blender +Y front / GLB -Z front; Blender +Z up / GLB +Y up")
    print(f"[FrostBunny] Materials ({len(material_names)}): {', '.join(material_names)}")
    print("[FrostBunny] Hierarchy: Body -> " + ", ".join(sorted(obj.name for obj in meshes if obj.name != "Body")))


def validate_candidate(body: bpy.types.Object) -> None:
    meshes = [obj for obj in CHARACTER_OBJECTS if obj.type == "MESH"]
    names = [obj.name for obj in CHARACTER_OBJECTS]
    required_materials = {
        "BunnyWhite",
        "InnerEarPink",
        "EyeBlack",
        "EyeHighlight",
        "NosePink",
        "CheekPink",
        "PawPink",
    }
    used_materials = {slot.material.name for obj in meshes for slot in obj.material_slots if slot.material}
    _, _, dimensions = character_bounds()
    triangles = mesh_triangle_count()

    assert body.name == "Body", "Canonical root object must be Body."
    assert body.parent is None, "Body must be the hierarchy root."
    assert len(names) == len(set(names)), "Character object names must be unique."
    assert all(obj.type == "MESH" for obj in CHARACTER_OBJECTS), "Only polygon mesh character objects may export."
    assert all(obj.parent is body for obj in CHARACTER_OBJECTS if obj is not body), "Every component must be parented to Body."
    assert required_materials.issubset(used_materials), "Required reference materials are missing."
    assert 2_000 <= triangles <= 6_000, f"Triangle count {triangles} is outside the mobile target."
    assert 2.30 <= dimensions.x <= 2.90, f"Width {dimensions.x:.3f} is outside the FrostBunny guide."
    assert 1.80 <= dimensions.y <= 2.25, f"Depth {dimensions.y:.3f} is outside the FrostBunny guide."
    assert 4.00 <= dimensions.z <= 4.60, f"Height {dimensions.z:.3f} is outside the FrostBunny guide."
    for obj in meshes:
        assert all(abs(value - 1.0) < 1e-5 for value in obj.scale), f"{obj.name} has unapplied scale."
        assert all(math.isfinite(value) for value in obj.location), f"{obj.name} has non-finite location."
    print("[FrostBunny] Static candidate checks: PASS")


def export_glb() -> None:
    GLB_PATH.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    for obj in CHARACTER_OBJECTS:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = next(obj for obj in CHARACTER_OBJECTS if obj.name == "Body")
    bpy.ops.export_scene.gltf(
        filepath=str(GLB_PATH),
        export_format="GLB",
        use_selection=True,
        export_yup=True,
        export_apply=True,
        export_extras=True,
        export_cameras=False,
        export_lights=False,
        export_materials="EXPORT",
    )
    assert GLB_PATH.is_file() and GLB_PATH.stat().st_size > 0, "GLB export is missing or empty."
    print(f"[FrostBunny] GLB: {GLB_PATH}")
    print(f"[FrostBunny] GLB bytes: {GLB_PATH.stat().st_size}")


def point_at(obj: bpy.types.Object, target: tuple[float, float, float]) -> None:
    direction = Vector(target) - obj.location
    obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()


def add_area_light(name: str, location: tuple[float, float, float], energy: float, size: float) -> None:
    light_data = bpy.data.lights.new(name, type="AREA")
    light_data.energy = energy
    light_data.shape = "DISK"
    light_data.size = size
    light = bpy.data.objects.new(name, light_data)
    bpy.context.scene.collection.objects.link(light)
    light.location = location
    point_at(light, (0.0, 0.0, 2.0))


def render_preview(body: bpy.types.Object) -> None:
    # Render four collection instances after the production model is built;
    # preview cameras, lights, floor, and duplicates never enter the GLB.
    scene = bpy.context.scene
    if CHARACTER_COLLECTION.name in scene.collection.children:
        scene.collection.children.unlink(CHARACTER_COLLECTION)

    for x_position, angle in zip((4.8, 1.6, -1.6, -4.8), (0.0, -45.0, -90.0, -180.0)):
        instance = bpy.data.objects.new(f"Preview_{int(abs(angle))}", None)
        instance.instance_type = "COLLECTION"
        instance.instance_collection = CHARACTER_COLLECTION
        instance.location = (x_position, 0.0, 0.0)
        instance.rotation_euler[2] = math.radians(angle)
        scene.collection.objects.link(instance)

    ground_material = make_material("PreviewGround", (0.12, 0.135, 0.16, 1.0), 0.62)
    bpy.ops.mesh.primitive_plane_add(size=2.0, location=(0.0, 0.0, -0.035))
    ground = bpy.context.object
    ground.name = "PreviewGround"
    ground.scale = (7.2, 3.0, 1.0)
    ground.data.materials.append(ground_material)

    camera_data = bpy.data.cameras.new("PreviewCamera")
    camera = bpy.data.objects.new("PreviewCamera", camera_data)
    scene.collection.objects.link(camera)
    camera.location = (0.0, 14.0, 2.30)
    camera.data.type = "ORTHO"
    camera.data.ortho_scale = 13.40
    point_at(camera, (0.0, 0.0, 2.25))
    scene.camera = camera

    add_area_light("KeyLight", (-5.0, 6.0, 8.0), 1250.0, 5.0)
    add_area_light("FillLight", (5.0, 4.0, 5.0), 850.0, 4.0)
    add_area_light("RimLight", (0.0, -4.0, 6.0), 1100.0, 4.0)

    scene.render.engine = "BLENDER_EEVEE"
    scene.render.resolution_x = 1600
    scene.render.resolution_y = 650
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.filepath = str(PREVIEW_PATH)
    scene.render.film_transparent = False
    scene.world.color = (0.055, 0.065, 0.085)
    try:
        scene.view_settings.look = "AgX - Medium High Contrast"
    except TypeError:
        pass
    PREVIEW_PATH.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.render.render(write_still=True)
    assert PREVIEW_PATH.is_file() and PREVIEW_PATH.stat().st_size > 0, "Preview render is missing or empty."
    print(f"[FrostBunny] Preview: {PREVIEW_PATH}")
    print("[FrostBunny] Preview order: front, 45 degrees, side, back")


def main() -> None:
    global CHARACTER_COLLECTION
    clean_scene()
    CHARACTER_COLLECTION = bpy.data.collections.new("FrostBunnyCharacter")
    bpy.context.scene.collection.children.link(CHARACTER_COLLECTION)
    create_materials()
    body = build_character()
    print_diagnostics()
    validate_candidate(body)
    if PREVIEW_ONLY:
        render_preview(body)
    else:
        export_glb()


if __name__ == "__main__":
    main()
