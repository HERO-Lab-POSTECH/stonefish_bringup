# syntax=docker/dockerfile:1.6
# ── stage: builder ──────────────────────────────────────────
FROM ros:humble-ros-base AS builder

# stonefish 빌드 의존성 (실측: README Dependencies + CMakeLists find_package)
#   OpenGL·SDL2·Freetype·OpenMP(REQUIRED) + glm(>=0.9.9). glew는 불필요.
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
      build-essential cmake git \
      libgl1-mesa-dev libsdl2-dev libfreetype-dev libglm-dev libomp-dev \
      python3-vcstool python3-colcon-common-extensions

# SDL2 함정 (실측: stonefish README) — sdl2-config.cmake의 "-lSDL2 " 뒤 공백 제거.
RUN sed -i 's/-lSDL2 /-lSDL2/' /usr/lib/x86_64-linux-gnu/cmake/SDL2/sdl2-config.cmake

# 소스 가져오기 (vcstool)
WORKDIR /ws
COPY stonefish.repos .
RUN mkdir -p src && vcs import src < stonefish.repos

# underlay: stonefish C++ 라이브러리를 /opt/stonefish에 빌드
WORKDIR /ws/src/stonefish/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/opt/stonefish -DCMAKE_BUILD_TYPE=Release \
 && make -j"$(nproc)" \
 && make install
