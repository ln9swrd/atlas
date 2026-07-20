import bpy
import math

def get_selected_armature_bone_info():
    # 1. 현재 선택한 오브젝트 가져오기
    obj = bpy.context.active_object
    
    # 2. 선택된 오브젝트가 아머처(리깅)인지 확인
    if not obj or obj.type != 'ARMATURE':
        print("[오류] 아머처(Armature) 오브젝트를 선택해 주세요.")
        return

    print(f"\n" + "="*50)
    print(f" 🤖 리그 이름: {obj.name}")
    print(f" Total Bones: {len(obj.pose.bones)}")
    print("="*50)

    # 3. 포즈 본 정보를 순회하며 데이터 추출
    for p_bone in obj.pose.bones:
        # 에디트 본 데이터 매칭 (기준 위치 파악용)
        e_bone = obj.data.bones[p_bone.name]
        
        # 부모 본 이름 (없으면 None)
        parent_name = p_bone.parent.name if p_bone.parent else "None"
        
        # 회전 값 변환 (쿼터니언 또는 오일러 대응)
        if p_bone.rotation_mode == 'QUATERNION':
            rot = p_bone.rotation_quaternion
            rot_str = f"W: {rot.w:.3f}, X: {rot.x:.3f}, Y: {rot.y:.3f}, Z: {rot.z:.3f} (Quaternion)"
        else:
            # 라디안을 도(Degree) 단위로 변환
            rot = p_bone.rotation_euler
            rot_str = f"X: {math.degrees(rot.x):.1f}°, Y: {math.degrees(rot.y):.1f}°, Z: {math.degrees(rot.z):.1f}° (Euler)"

        # 콘솔 출력 format
        print(f"🦴 본 이름: '{p_bone.name}'")
        print(f"   - 부모 본  : {parent_name}")
        print(f"   - 로컬 위치: X: {p_bone.location.x:.3f}, Y: {p_bone.location.y:.3f}, Z: {p_bone.location.z:.3f}")
        print(f"   - 로컬 회전: {rot_str}")
        print(f"   - 로컬 스케일: X: {p_bone.scale.x:.3f}, Y: {p_bone.scale.y:.3f}, Z: {p_bone.scale.z:.3f}")
        print(f"   - 레이어(컬렉션): {list(e_bone.collections) if hasattr(e_bone, 'collections') else 'N/A'}")
        print("-" * 40)

# 스크립트 실행
if __name__ == "__main__":
    get_selected_armature_bone_info()