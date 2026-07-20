import bpy
import math

def create_stoner_sunshine_anim():
    obj = bpy.context.active_object
    if not obj or obj.type != 'ARMATURE':
        print("경고: 슈퍼 로봇 리그(Armature)를 선택해 주세요.")
        return

    # 애니메이션 데이터 초기화 및 쿼터니언 안전화
    if not obj.animation_data:
        obj.animation_data_create()
        
    scene = bpy.context.scene
    scene.frame_start = 1
    scene.frame_end = 100
    
    p_bones = obj.pose.bones
    
    # ---------------------------------------------------------
    # 0프레임: Rest 포즈 기본값 (모든 관절 초기화 키)
    # ---------------------------------------------------------
    scene.frame_set(1)
    for pb in p_bones:
        pb.rotation_quaternion = (1, 0, 0, 0)
        if pb.rotation_mode == 'XYZ':
            pb.rotation_euler = (0, 0, 0)
        pb.keyframe_insert(data_path="rotation_quaternion", index=-1)
        pb.keyframe_insert(data_path="rotation_euler", index=-1)

    # ---------------------------------------------------------
    # 20프레임: 기 모으기 (하늘을 향해 상체와 팔을 크게 벌림)
    # ---------------------------------------------------------
    scene.frame_set(20)
    
    # 가슴과 허리를 뒤로 젖힘 (X축 회전)
    if "Chest" in p_bones:
        p_bones["Chest"].rotation_quaternion = (0.958, -0.287, 0, 0) # 약 -30도 젖힘
        p_bones["Chest"].keyframe_insert(data_path="rotation_quaternion")
        
    # 양 어깨(볼조인트)를 바깥 및 위쪽으로 크게 오픈
    if "shoulder.L" in p_bones:
        p_bones["shoulder.L"].rotation_quaternion = (0.866, 0, 0.5, 0)
        p_bones["shoulder.L"].keyframe_insert(data_path="rotation_quaternion")
    if "shoulder.R" in p_bones:
        p_bones["shoulder.R"].rotation_quaternion = (0.866, 0, -0.5, 0)
        p_bones["shoulder.R"].keyframe_insert(data_path="rotation_quaternion")

    # ---------------------------------------------------------
    # 50프레임: 구체 형성 (머리 위나 가슴 앞으로 양손을 모음)
    # ---------------------------------------------------------
    scene.frame_set(50)
    
    # 상체를 약간 숙이면서 에너지를 압축
    if "Chest" in p_bones:
        p_bones["Chest"].rotation_quaternion = (0.985, 0.174, 0, 0) # 앞쪽으로 숙임
        p_bones["Chest"].keyframe_insert(data_path="rotation_quaternion")
        
    # 어깨를 안쪽으로 모아서 양손이 중앙에 위치하도록 제어
    if "shoulder.L" in p_bones:
        p_bones["shoulder.L"].rotation_quaternion = (0.707, 0.5, 0.5, -0.0)
        p_bones["shoulder.L"].keyframe_insert(data_path="rotation_quaternion")
    if "shoulder.R" in p_bones:
        p_bones["shoulder.R"].rotation_quaternion = (0.707, -0.5, -0.5, -0.0)
        p_bones["shoulder.R"].keyframe_insert(data_path="rotation_quaternion")
        
    # 팔꿈치 더블 조인트를 구부려 구체를 감싸는 포즈
    if "upper_arm.L" in p_bones:
        p_bones["upper_arm.L"].rotation_quaternion = (0.924, 0, 0.383, 0)
        p_bones["upper_arm.L"].keyframe_insert(data_path="rotation_quaternion")
    if "upper_arm.R" in p_bones:
        p_bones["upper_arm.R"].rotation_quaternion = (0.924, 0, -0.383, 0)
        p_bones["upper_arm.R"].keyframe_insert(data_path="rotation_quaternion")

    # ---------------------------------------------------------
    # 70프레임: 투척 직전 반동 (오른쪽이나 왼쪽으로 몸을 확 틀어 밀어낼 준비)
    # ---------------------------------------------------------
    scene.frame_set(70)
    
    # 고관절(pelvis) 축 관절을 비틀어 역동성 확보 (XYZ 오일러 대응)
    if "pelvis.L" in p_bones:
        p_bones["pelvis.L"].rotation_euler = (math.radians(15), 0, math.radians(-10))
        p_bones["pelvis.L"].keyframe_insert(data_path="rotation_euler")
        
    if "Chest" in p_bones:
        p_bones["Chest"].rotation_quaternion = (0.866, -0.383, 0.258, 0.222) # 비틀며 뒤로 장전
        p_bones["Chest"].keyframe_insert(data_path="rotation_quaternion")

    # ---------------------------------------------------------
    # 80프레임: Stoner Sunshine 발사!! (정면으로 양손 폭발적 스트레이트)
    # ---------------------------------------------------------
    scene.frame_set(80)
    
    # 상체를 정면으로 강하게 튕김
    if "Chest" in p_bones:
        p_bones["Chest"].rotation_quaternion = (0.866, 0.5, 0, 0) # 앞으로 팍 꺾임
        p_bones["Chest"].keyframe_insert(data_path="rotation_quaternion")
        
    # 어깨와 팔을 정면(Y축 혹은 Z축 뻗기 방향)으로 100% 전개
    if "shoulder.L" in p_bones:
        p_bones["shoulder.L"].rotation_quaternion = (0.5, 0.5, 0.5, 0.5) # 정면 지향
        p_bones["shoulder.L"].keyframe_insert(data_path="rotation_quaternion")
    if "shoulder.R" in p_bones:
        p_bones["shoulder.R"].rotation_quaternion = (0.5, -0.5, -0.5, 0.5)
        p_bones["shoulder.R"].keyframe_insert(data_path="rotation_quaternion")
        
    # 팔꿈치를 완전히 일자로 쭉 편 상태
    if "upper_arm.L" in p_bones:
        p_bones["upper_arm.L"].rotation_quaternion = (1, 0, 0, 0)
        p_bones["upper_arm.L"].keyframe_insert(data_path="rotation_quaternion")
    if "upper_arm.R" in p_bones:
        p_bones["upper_arm.R"].rotation_quaternion = (1, 0, 0, 0)
        p_bones["upper_arm.R"].keyframe_insert(data_path="rotation_quaternion")

    # ---------------------------------------------------------
    # 100프레임: 발사 후 밀려나는 잔동작 (Follow Through)
    # ---------------------------------------------------------
    scene.frame_set(100)
    if "Chest" in p_bones:
        p_bones["Chest"].rotation_quaternion = (0.906, 0.423, 0, 0) # 반동으로 살짝 들림
        p_bones["Chest"].keyframe_insert(data_path="rotation_quaternion")

    # 타임라인 첫 프레임으로 리셋 및 화면 리프레시
    scene.frame_set(1)
    bpy.ops.wm.redraw_timer(type='DRAW_WIN_SWAP', iterations=1)
    print("🔥 스토너 선샤인 매크로 애니메이션 키프레임 생성 완료! 스페이스바를 눌러 확인하세요.")

create_stoner_sunshine_anim()