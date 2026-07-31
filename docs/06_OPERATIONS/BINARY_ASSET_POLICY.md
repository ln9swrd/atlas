# Binary Asset Policy (R6)

Related: D13 · ACTIVE_TARGET = platform

## Rule

| Size / Type | Policy |
|-------------|--------|
| Text / code / small config | Git normal |
| `.blend` / media / archives | **Do not commit raw** (see `.gitignore`) |
| Large binary needed in repo | **Git LFS** only |
| Very large / game assets | External store (S3, Drive, local asset root) + path note in docs |

## Defaults (repo root `.gitignore`)

이미 무시:
- `*.blend` `*.blend1`
- `*.mp3` `*.flac` `*.wav`
- `*.zip`

제품 트리에서 예외가 필요하면 **해당 프로젝트** `.gitignore` / LFS만 조정. 플랫폼 root 정책은 유지.

## LFS (when needed)

```bash
git lfs install
git lfs track "*.psd"
git lfs track "*.png"   # only if large atlases must live in git
# then commit .gitattributes
```

`.gitattributes`에 LFS 패턴을 넣을 때만 track. 기본은 ignore.

## History

과거 커밋에 바이너리가 있어도 **재작성하지 않음** (rewrite 비용 > 이득). 앞으로는 위 규칙만 적용.

## Checklist

- [ ] 새 바이너리 추가 전: ignore vs LFS vs external 결정
- [ ] 제품 에셋 경로를 `projects/<id>/` 문서에 한 줄 기록
- [ ] platform hardening 중에는 제품 바이너리 작업 금지
