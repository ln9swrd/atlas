# Walk Animation Manual Setup Instructions for Blender 5.2
# 블렌더 UI에서 직접 실행

이 가이드는 RIG-Axion_Rigify_Metarig에서 수동으로 walk 애니메이션을 만드는 방법입니다.

## 단계:

### 1. Blender 열기
- d:\Atlas\projects\blender\axion_proto.blend 파일을 Blender로 엽니다

### 2. Rig 선택
- Outliner에서 "RIG-Axion_Rigify_Metarig" 선택
- Spacebar로 Pose Mode 진입

### 3. 새 Action 생성
- Properties Panel (N키) → Animtion 탭
- "+" 버튼으로 새 action 추가
- 이름: "Walk_Cycle_Rigify"

### 4. Timeline 설정
- Timeline 보기 (Window → Toggle Timeline)
- Start frame: 0
- End frame: 47

### 5. 키프레임 삽입 (Frame 0)
- Timeline에서 Frame 0 선택 (Click)
- Outliner 또는 Armature로부터 아래 본들 선택:
  * root
  * foot_ik.L
  * foot_ik.R
  * chest
- Pose Mode에서:
  * root: Y = -2.0, i키 → "Location"
  * foot_ik.R: Location = (0, 1.5, 0), i키 → "Location"
  * foot_ik.L: Location = (0, -1.5, 0), i키 → "Location"
  * chest: Rotation X = 5°, i키 → "Rotation"

### 6. 키프레임 삽입 (Frame 12)
- Timeline에서 Frame 12 선택
- root: Y = -1.0, 키프레임
- foot_ik.R: (0, 0, 0), 키프레임
- foot_ik.L: (0, -2.0, 0), 키프레임
- chest: X = 0°, 키프레임

### 7. 키프레임 삽입 (Frame 24)
- Frame 24 선택
- root: Y = 0.0
- foot_ik.L: (0, 1.5, 0)
- foot_ik.R: (0, -1.5, 0)
- chest: X = -5°

### 8. 키프레임 삽입 (Frame 36)
- Frame 36 선택
- root: Y = 1.0
- foot_ik.L: (0, 0, 0)
- foot_ik.R: (0, -2.0, 0)
- chest: X = 0°

### 9. 키프레임 삽입 (Frame 48)
- Frame 48 선택
- root: Y = -2.0
- foot_ik.R: (0, 1.5, 0)
- foot_ik.L: (0, -1.5, 0)
- chest: X = 5°

### 10. 저장
- Ctrl+S로 파일 저장

### 11. 재생
- Spacebar로 애니메이션 재생

## 명확한 키프레임 데이터:

Frame 0: root_y=-2.0, foot_ik_r_y=1.5, foot_ik_l_y=-1.5, chest_x=5°
Frame 12: root_y=-1.0, foot_ik_r_y=0.0, foot_ik_l_y=-2.0, chest_x=0°
Frame 24: root_y=0.0, foot_ik_r_y=-1.5, foot_ik_l_y=1.5, chest_x=-5°
Frame 36: root_y=1.0, foot_ik_r_y=-2.0, foot_ik_l_y=0.0, chest_x=0°
Frame 48: root_y=-2.0, foot_ik_r_y=1.5, foot_ik_l_y=-1.5, chest_x=5°
