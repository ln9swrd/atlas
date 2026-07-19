#!/bin/bash

# Atlas 저장소 상태 확인 스크립트

echo "=== Atlas 저장소 상태 확인 ==="
echo "현재 디렉터리: $(pwd)"
echo "Git branch:"
git branch --show-current
echo "Git status:"
git status --short
echo "최근 커밋 5개:"
git log --oneline -5

