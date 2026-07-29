# 070. Blender AI 애드온 및 툴체인 조사

## 핵심

- `.blend` Git 관리 추천(100MB 이하 직접, 이상 LFS). `.blend1/2`, 렌더·캐시는 gitignore.
- 유사 프로젝트: BlenderForge, BlenderGPT, MB-Lab, HumGen3D, Blender Skills, ProcFunc.
- 차별점: 단순 AI 조작이 아니라 **파라미터→Python→.blend→수동수정→파라미터 저장** 반복 생성기.
- 우선순위: 문서 안정화 → Blender 자동화 → Exelion 전용 도구 → 게임 제작. "급할수록 돌아간다."
