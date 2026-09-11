"""Shared Blender 5.2 helpers for Auralit's final pet mesh generators."""

from __future__ import annotations

import math
from pathlib import Path
from typing import Callable, Sequence

import bpy
from mathutils import Vector


REPO_ROOT = Path(__file__).resolve().parents[2]


class PetMeshBuilder:
    def __init__(self, pet_id: str) -> None:
        self.pet_id = pet_id
        self.glb_path = REPO_ROOT / "assets" / "models" / "pets" / f"{pet_id}.glb"
        self.preview_path = REPO_ROOT / "assets" / "models" / "pets" / f"{pet_id}_preview.png"
        self.objects: list[bpy.types.Object] = []
        self.materials: dict[str, bpy.types.Material] = {}
        self.collection: bpy.types.Collection

    def clean_scene(self) -> None:
        bpy.ops.object.select_all(action="SELECT")
        bpy.ops.object.delete(use_global=False)
        datablock_groups = (
            bpy.data.meshes,
            bpy.data.curves,
            bpy.data.materials,
            bpy.data.cameras,
            bpy.data.lights,
        )
        for datablocks in datablock_groups:
            for datablock in list(datablocks):
                if datablock.users == 0:
                    datablocks.remove(datablock)
        self.collection = bpy.data.collections.new(f"{self.pet_id}Character")
        bpy.context.scene.collection.children.link(self.collection)

    def material(
        self,
        name: str,
        rgba: tuple[float, float, float, float],
        roughness: float = 0.36,
        coat: float = 0.0,
        metallic: float = 0.0,
        emission: float = 0.0,
    ) -> bpy.types.Material:
        material = bpy.data.materials.new(name)
        material.diffuse_color = rgba
        material.use_nodes = True
        principled = material.node_tree.nodes.get("Principled BSDF")
        if principled:
            principled.inputs["Base Color"].default_value = rgba
            principled.inputs["Roughness"].default_value = roughness
            principled.inputs["Metallic"].default_value = metallic
            if "Coat Weight" in principled.inputs:
                principled.inputs["Coat Weight"].default_value = coat
            if emission > 0.0:
                principled.inputs["Emission Color"].default_value = rgba
                principled.inputs["Emission Strength"].default_value = emission
        self.materials[name] = material
        return material

    def _register(
        self,
        obj: bpy.types.Object,
        material: bpy.types.Material,
        smooth: bool = True,
    ) -> bpy.types.Object:
        for collection in list(obj.users_collection):
            collection.objects.unlink(obj)
        self.collection.objects.link(obj)
        if hasattr(obj.data, "materials"):
            obj.data.materials.append(material)
        if smooth and obj.type == "MESH":
            for polygon in obj.data.polygons:
                polygon.use_smooth = True
        self.objects.append(obj)
        return obj

    @staticmethod
    def _apply_rotation_scale(obj: bpy.types.Object) -> None:
        bpy.ops.object.select_all(action="DESELECT")
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)

    def ellipsoid(
        self,
        name: str,
        location: tuple[float, float, float],
        scale: tuple[float, float, float],
        material: bpy.types.Material,
        *,
        rotation: tuple[float, float, float] = (0.0, 0.0, 0.0),
        segments: int = 16,
        rings: int = 8,
        deform: Callable[[Vector], None] | None = None,
        smooth: bool = True,
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
        self._apply_rotation_scale(obj)
        return self._register(obj, material, smooth)

    def box(
        self,
        name: str,
        location: tuple[float, float, float],
        dimensions: tuple[float, float, float],
        material: bpy.types.Material,
        *,
        rotation: tuple[float, float, float] = (0.0, 0.0, 0.0),
        bevel: float = 0.08,
    ) -> bpy.types.Object:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=location, rotation=rotation)
        obj = bpy.context.object
        obj.name = name
        obj.data.name = f"{name}_Mesh"
        obj.dimensions = dimensions
        self._apply_rotation_scale(obj)
        if bevel > 0.0:
            modifier = obj.modifiers.new("SoftEdges", "BEVEL")
            modifier.width = bevel
            modifier.segments = 2
            bpy.context.view_layer.objects.active = obj
            bpy.ops.object.modifier_apply(modifier=modifier.name)
        return self._register(obj, material, True)

    def cone(
        self,
        name: str,
        location: tuple[float, float, float],
        radius1: float,
        radius2: float,
        depth: float,
        material: bpy.types.Material,
        *,
        rotation: tuple[float, float, float] = (0.0, 0.0, 0.0),
        vertices: int = 12,
        scale: tuple[float, float, float] = (1.0, 1.0, 1.0),
        smooth: bool = True,
    ) -> bpy.types.Object:
        bpy.ops.mesh.primitive_cone_add(
            vertices=vertices,
            radius1=radius1,
            radius2=radius2,
            depth=depth,
            location=location,
            rotation=rotation,
        )
        obj = bpy.context.object
        obj.name = name
        obj.data.name = f"{name}_Mesh"
        obj.scale = scale
        self._apply_rotation_scale(obj)
        return self._register(obj, material, smooth)

    def torus(
        self,
        name: str,
        location: tuple[float, float, float],
        major_radius: float,
        minor_radius: float,
        material: bpy.types.Material,
        *,
        rotation: tuple[float, float, float] = (math.pi / 2.0, 0.0, 0.0),
        scale: tuple[float, float, float] = (1.0, 1.0, 1.0),
        major_segments: int = 16,
        minor_segments: int = 6,
    ) -> bpy.types.Object:
        bpy.ops.mesh.primitive_torus_add(
            major_radius=major_radius,
            minor_radius=minor_radius,
            major_segments=major_segments,
            minor_segments=minor_segments,
            location=location,
            rotation=rotation,
        )
        obj = bpy.context.object
        obj.name = name
        obj.data.name = f"{name}_Mesh"
        obj.scale = scale
        self._apply_rotation_scale(obj)
        return self._register(obj, material, True)

    def tube(
        self,
        name: str,
        points: Sequence[tuple[float, float, float]],
        radii: Sequence[float],
        material: bpy.types.Material,
        *,
        radial_segments: int = 8,
        smooth: bool = True,
    ) -> bpy.types.Object:
        if len(points) < 2 or len(points) != len(radii):
            raise ValueError(f"{name} needs matching point/radius sequences")
        centers = [Vector(point) for point in points]
        vertices: list[tuple[float, float, float]] = []
        for index, center in enumerate(centers):
            if index == 0:
                tangent = (centers[1] - center).normalized()
            elif index == len(centers) - 1:
                tangent = (center - centers[index - 1]).normalized()
            else:
                tangent = (centers[index + 1] - centers[index - 1]).normalized()
            reference = Vector((0.0, 0.0, 1.0))
            if abs(tangent.dot(reference)) > 0.92:
                reference = Vector((1.0, 0.0, 0.0))
            side = tangent.cross(reference).normalized()
            up = side.cross(tangent).normalized()
            for segment in range(radial_segments):
                angle = math.tau * segment / radial_segments
                offset = side * math.cos(angle) + up * math.sin(angle)
                vertices.append(tuple(center + offset * radii[index]))
        faces: list[tuple[int, ...]] = []
        for ring in range(len(centers) - 1):
            lower = ring * radial_segments
            upper = (ring + 1) * radial_segments
            for segment in range(radial_segments):
                nxt = (segment + 1) % radial_segments
                faces.append((lower + segment, lower + nxt, upper + nxt, upper + segment))
        faces.append(tuple(reversed(range(radial_segments))))
        last = (len(centers) - 1) * radial_segments
        faces.append(tuple(last + segment for segment in range(radial_segments)))
        mesh = bpy.data.meshes.new(f"{name}_Mesh")
        mesh.from_pydata(vertices, [], faces)
        mesh.update()
        obj = bpy.data.objects.new(name, mesh)
        self.collection.objects.link(obj)
        mesh.materials.append(material)
        if smooth:
            for polygon in mesh.polygons:
                polygon.use_smooth = True
        self.objects.append(obj)
        return obj

    def feather(
        self,
        name: str,
        location: tuple[float, float, float],
        scale: tuple[float, float, float],
        material: bpy.types.Material,
        *,
        rotation: tuple[float, float, float] = (0.0, 0.0, 0.0),
        segments: int = 12,
        rings: int = 6,
        smooth: bool = True,
    ) -> bpy.types.Object:
        def taper(co: Vector) -> None:
            normalized = max(-1.0, min(1.0, co.z))
            if normalized < -0.15:
                factor = 0.72 + 0.28 * (normalized + 1.0) / 0.85
                co.x *= factor
                co.y *= factor
            elif normalized > 0.35:
                factor = max(0.32, (1.0 - normalized) / 0.65)
                co.x *= factor
                co.y *= 0.72 + 0.28 * factor
        return self.ellipsoid(
            name,
            location,
            scale,
            material,
            rotation=rotation,
            segments=segments,
            rings=rings,
            deform=taper,
            smooth=smooth,
        )

    def parent_to_body(
        self,
        body: bpy.types.Object,
        metadata: dict[str, str | float],
    ) -> None:
        for obj in self.objects:
            if obj is body:
                continue
            world_matrix = obj.matrix_world.copy()
            obj.parent = body
            obj.matrix_world = world_matrix
        for key, value in metadata.items():
            body[key] = value

    def bounds(self) -> tuple[Vector, Vector, Vector]:
        minimum = Vector((math.inf, math.inf, math.inf))
        maximum = Vector((-math.inf, -math.inf, -math.inf))
        for obj in self.objects:
            for corner in obj.bound_box:
                world_corner = obj.matrix_world @ Vector(corner)
                for axis in range(3):
                    minimum[axis] = min(minimum[axis], world_corner[axis])
                    maximum[axis] = max(maximum[axis], world_corner[axis])
        return minimum, maximum, maximum - minimum

    def triangle_count(self) -> int:
        total = 0
        for obj in self.objects:
            obj.data.calc_loop_triangles()
            total += len(obj.data.loop_triangles)
        return total

    def validate(
        self,
        body: bpy.types.Object,
        expected_names: set[str],
        required_materials: set[str],
        triangle_range: tuple[int, int],
        dimension_ranges: tuple[tuple[float, float], tuple[float, float], tuple[float, float]],
    ) -> tuple[int, Vector]:
        names = [obj.name for obj in self.objects]
        actual_names = set(names)
        used_materials = {
            slot.material.name
            for obj in self.objects
            for slot in obj.material_slots
            if slot.material
        }
        triangles = self.triangle_count()
        _, _, dimensions = self.bounds()
        assert body.name == "Body" and body.parent is None, "Body must be the root object."
        assert len(names) == len(actual_names), "Character object names must be unique."
        assert actual_names == expected_names, (
            f"Object contract mismatch; missing={sorted(expected_names - actual_names)}, "
            f"unexpected={sorted(actual_names - expected_names)}"
        )
        assert all(obj.type == "MESH" for obj in self.objects), "Only polygon meshes may export."
        assert all(obj.parent is body for obj in self.objects if obj is not body), "Every component must be parented to Body."
        assert required_materials.issubset(used_materials), "Required materials are missing."
        assert triangle_range[0] <= triangles <= triangle_range[1], f"Triangle count {triangles} is outside target."
        for value, bounds, label in zip(dimensions, dimension_ranges, ("width", "depth", "height")):
            assert bounds[0] <= value <= bounds[1], f"{label} {value:.3f} is outside target {bounds}."
        for obj in self.objects:
            assert all(abs(value - 1.0) < 1e-5 for value in obj.scale), f"{obj.name} has unapplied scale."
            assert all(math.isfinite(value) for value in obj.location), f"{obj.name} has non-finite location."
        print(f"[{self.pet_id}] Static candidate checks: PASS")
        return triangles, dimensions

    def export(self, body: bpy.types.Object) -> None:
        self.glb_path.parent.mkdir(parents=True, exist_ok=True)
        bpy.ops.object.select_all(action="DESELECT")
        for obj in self.objects:
            obj.select_set(True)
        bpy.context.view_layer.objects.active = body
        bpy.ops.export_scene.gltf(
            filepath=str(self.glb_path),
            export_format="GLB",
            use_selection=True,
            export_yup=True,
            export_apply=True,
            export_extras=True,
            export_cameras=False,
            export_lights=False,
            export_materials="EXPORT",
        )
        assert self.glb_path.is_file() and self.glb_path.stat().st_size > 0

    def diagnostics(self, reference: str) -> None:
        minimum, maximum, dimensions = self.bounds()
        materials = sorted({slot.material.name for obj in self.objects for slot in obj.material_slots if slot.material})
        print(f"[{self.pet_id}] Reference: {reference}")
        print(f"[{self.pet_id}] Objects/Meshes: {len(self.objects)}/{len(self.objects)}")
        print(f"[{self.pet_id}] Triangles: {self.triangle_count()}")
        print(
            f"[{self.pet_id}] Bounds XYZ: "
            f"min=({minimum.x:.4f}, {minimum.y:.4f}, {minimum.z:.4f}) "
            f"max=({maximum.x:.4f}, {maximum.y:.4f}, {maximum.z:.4f})"
        )
        print(
            f"[{self.pet_id}] Dimensions XYZ (Blender): "
            f"({dimensions.x:.4f}, {dimensions.y:.4f}, {dimensions.z:.4f})"
        )
        print(f"[{self.pet_id}] Orientation: Blender +Y front/+Z up; GLB -Z front/+Y up")
        print(f"[{self.pet_id}] Materials ({len(materials)}): {', '.join(materials)}")
        print(f"[{self.pet_id}] Hierarchy: Body -> " + ", ".join(sorted(obj.name for obj in self.objects if obj.name != "Body")))
        print(f"[{self.pet_id}] GLB: {self.glb_path} ({self.glb_path.stat().st_size} bytes)")

    @staticmethod
    def _point_at(obj: bpy.types.Object, target: tuple[float, float, float]) -> None:
        direction = Vector(target) - obj.location
        obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()

    def _area_light(
        self,
        name: str,
        location: tuple[float, float, float],
        energy: float,
        size: float,
        target: tuple[float, float, float],
    ) -> None:
        data = bpy.data.lights.new(name, type="AREA")
        data.energy = energy
        data.shape = "DISK"
        data.size = size
        light = bpy.data.objects.new(name, data)
        bpy.context.scene.collection.objects.link(light)
        light.location = location
        self._point_at(light, target)

    def render_preview(self) -> None:
        scene = bpy.context.scene
        minimum, _, dimensions = self.bounds()
        if self.collection.name in scene.collection.children:
            scene.collection.children.unlink(self.collection)
        spacing = max(dimensions.x, dimensions.y) + 0.85
        for index, angle in enumerate((0.0, -45.0, -90.0, -180.0)):
            instance = bpy.data.objects.new(f"Preview_{index}", None)
            instance.instance_type = "COLLECTION"
            instance.instance_collection = self.collection
            instance.location = ((1.5 - index) * spacing, 0.0, -minimum.z)
            instance.rotation_euler[2] = math.radians(angle)
            scene.collection.objects.link(instance)

        ground_material = self.material("PreviewGround", (0.105, 0.12, 0.15, 1.0), 0.68)
        bpy.ops.mesh.primitive_plane_add(size=2.0, location=(0.0, 0.0, -0.035))
        ground = bpy.context.object
        ground.name = "PreviewGround"
        ground.scale = (spacing * 2.4, max(2.8, dimensions.y * 1.3), 1.0)
        ground.data.materials.append(ground_material)

        target = (0.0, 0.0, dimensions.z * 0.5)
        camera_data = bpy.data.cameras.new("PreviewCamera")
        camera = bpy.data.objects.new("PreviewCamera", camera_data)
        scene.collection.objects.link(camera)
        camera.location = (0.0, max(12.0, dimensions.y * 5.0), target[2])
        camera.data.type = "ORTHO"
        camera.data.ortho_scale = max(spacing * 4.0, dimensions.z * 1.28 * 2.18)
        self._point_at(camera, target)
        scene.camera = camera

        self._area_light("KeyLight", (-5.0, 6.0, 8.0), 1200.0, 5.0, target)
        self._area_light("FillLight", (5.0, 4.0, 5.0), 750.0, 4.0, target)
        self._area_light("RimLight", (0.0, -4.0, 6.0), 1000.0, 4.0, target)
        scene.render.engine = "BLENDER_WORKBENCH"
        scene.display.shading.light = "STUDIO"
        scene.display.shading.color_type = "MATERIAL"
        scene.display.shading.show_shadows = True
        scene.display.shading.show_cavity = True
        scene.render.resolution_x = 1600
        scene.render.resolution_y = 700
        scene.render.resolution_percentage = 100
        scene.render.image_settings.file_format = "PNG"
        scene.render.filepath = str(self.preview_path)
        scene.world.color = (0.05, 0.06, 0.08)
        try:
            scene.view_settings.look = "AgX - Medium High Contrast"
        except TypeError:
            pass
        self.preview_path.parent.mkdir(parents=True, exist_ok=True)
        bpy.ops.render.render(write_still=True)
        assert self.preview_path.is_file() and self.preview_path.stat().st_size > 0
        print(f"[{self.pet_id}] Preview: {self.preview_path}")
