"""
Excelion 3D Engine - Secondary Weapon 3D Mesh Generator
Generates actual 3D Wavefront OBJ mesh files for Heavy Rocket Launcher and Energy Shield.
"""
from typing import Dict, Any, List, Tuple, Optional
import os


class SecondaryWeaponGenerator:
    """
    3D Mesh Synthesis Engine for Excelion Secondary Weapons (Heavy Launcher & Energy Shield).
    """

    def __init__(self, output_dir: Optional[str] = None):
        self.output_dir = output_dir or os.getcwd()

    def generate_launcher_mesh(self) -> Tuple[List[Tuple[float, float, float]], List[Tuple[int, int, int]]]:
        """Generate 3D vertices and triangles for Heavy Rocket Launcher."""
        vertices = [
            (-0.3, -0.3, -1.0), (0.3, -0.3, -1.0), (0.3, 0.3, -1.0), (-0.3, 0.3, -1.0),
            (-0.3, -0.3, 1.0), (0.3, -0.3, 1.0), (0.3, 0.3, 1.0), (-0.3, 0.3, 1.0),
            (0.0, 0.0, 1.5)  # Launcher Barrel Tip
        ]
        faces = [
            (0, 2, 1), (0, 3, 2),
            (4, 5, 6), (4, 6, 7),
            (4, 5, 8), (5, 6, 8), (6, 7, 8), (7, 4, 8)
        ]
        return vertices, faces

    def generate_shield_mesh(self) -> Tuple[List[Tuple[float, float, float]], List[Tuple[int, int, int]]]:
        """Generate 3D vertices and triangles for Energy Shield."""
        vertices = [
            (0.0, -1.0, -1.0), (0.0, 1.0, -1.0), (0.0, 1.0, 1.0), (0.0, -1.0, 1.0),
            (0.2, 0.0, 0.0)  # Shield Emitter Center Node
        ]
        faces = [
            (0, 1, 4), (1, 2, 4), (2, 3, 4), (3, 0, 4)
        ]
        return vertices, faces

    def export_weapon_obj(self, filename: str, name: str, vertices: List[Tuple[float, float, float]], faces: List[Tuple[int, int, int]]) -> str:
        filepath = os.path.join(self.output_dir, filename)
        os.makedirs(os.path.dirname(os.path.abspath(filepath)), exist_ok=True)

        lines = [
            f"# Excelion Secondary Weapon 3D Mesh: {name}",
            f"o {name}",
        ]
        for v in vertices:
            lines.append(f"v {v[0]:.4f} {v[1]:.4f} {v[2]:.4f}")
        for f in faces:
            lines.append(f"f {f[0]+1} {f[1]+1} {f[2]+1}")

        with open(filepath, "w", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")

        return filepath

    def build_all_secondary_weapons(self) -> Dict[str, Any]:
        """Generate 3D OBJ mesh files for all secondary weapons."""
        launcher_v, launcher_f = self.generate_launcher_mesh()
        launcher_file = self.export_weapon_obj("HeavyLauncher.obj", "HeavyLauncher", launcher_v, launcher_f)

        shield_v, shield_f = self.generate_shield_mesh()
        shield_file = self.export_weapon_obj("EnergyShield.obj", "EnergyShield", shield_v, shield_f)

        return {
            "launcher_path": launcher_file,
            "shield_path": shield_file,
            "launcher_file_size": os.path.getsize(launcher_file),
            "shield_file_size": os.path.getsize(shield_file),
            "status": "SUCCESS",
        }
