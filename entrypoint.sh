#!/bin/bash
set -e
source /opt/ros/humble/setup.bash
source /ws/install/setup.bash
export LD_LIBRARY_PATH=/opt/stonefish/lib:${LD_LIBRARY_PATH}

# 디스플레이별 GPU 렌더 경로 자동 감지 → VGL_PREFIX 결정
if [ "$DISPLAY" = ":0" ]; then
    # 물리 GPU 디스플레이 → vglrun 불필요
    export VGL_PREFIX=""
elif vglrun -d egl glxinfo 2>/dev/null | grep -qi nvidia; then
    # 가상 디스플레이(:20 등)인데 EGL로 GPU 가능 → vglrun 사용
    export VGL_PREFIX="vglrun -d egl"
else
    echo "[entrypoint] WARN: GPU 가속 불가, SW 렌더로 폴백" >&2
    export VGL_PREFIX=""
fi

exec "$@"
