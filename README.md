# stonefish_bringup

HERO Lab stonefish 수중 시뮬레이터(stonefish + stonefish_sim + stonefish_slam,
ROS2 Humble, GPU 가속)의 배포용 Docker 환경.

`docker compose build` 한 번으로 GPU 가속 시뮬레이터 이미지를 빌드해 바로 띄울 수 있는,
재현 가능·자족적 멀티스테이지 Dockerfile이다. (사전 빌드 이미지는 아직 배포하지 않는다 —
코드가 활발히 바뀌는 단계라 Dockerfile만 제공한다. 각자 빌드해 쓴다.)

## 빠른 시작

```bash
git clone https://github.com/HERO-Lab-POSTECH/stonefish_bringup.git
cd stonefish_bringup

# 이미지 빌드 (최초 1회, ~15-30분)
docker compose build

# 호스트에서 X 디스플레이(:0) 캡처 권한 부여 (1회)
DISPLAY=:0 xhost +local:

# 시뮬레이터를 호스트 :0(GPU)에 직접 렌더
docker compose run --rm stonefish bash -c \
  '. /ws/install/setup.bash && ros2 launch stonefish_ros2 simulator.launch.py \
   simulation_data:=/ws/install/share/stonefish_description \
   scenario_desc:=/ws/install/share/stonefish_description/scenarios/bluerov2_empty.scn'
```

## 요구사항

- NVIDIA GPU + nvidia-container-toolkit (드라이버는 OpenGL 4.3+ 지원)
- 호스트에 GPU X 디스플레이(`:0`, NVIDIA Xorg)가 떠 있어야 함

## 디스플레이 모델

stonefish는 OpenGL 4.3+ GPU에 **직접 GLX 렌더**한다(공식 install 문서 요구사항). 따라서
컨테이너는 호스트의 물리 GPU X 디스플레이(`:0`)에 직접 그린다 — VirtualGL이나 가상 디스플레이를
거치지 않는다. 컨테이너는 호스트 `/tmp/.X11-unix` 소켓만 마운트하면 된다.

```
호스트 :0 (NVIDIA Xorg, RTX 4070/4060) ◄── 컨테이너 stonefish가 GLX로 직접 렌더
```

## 원격에서 보기 (Mac → 호스트)

GPU 렌더 화면을 렉 없이 Mac에서 보려면 호스트 Ubuntu에 **Sunshine**(NVENC 스트리밍 서버)을
네이티브 설치하고 Mac에서 **Moonlight**로 접속한다. Sunshine이 호스트 `:0` 데스크톱을 통째 캡처하므로,
위 명령으로 띄운 stonefish 창이 그대로 스트림에 보인다(시뮬레이터 컨테이너가 안 떠 있어도 데스크톱은 보인다).

- 호스트: Sunshine을 systemd user 서비스로 상시 기동 (`systemctl --user enable --now sunshine`,
  drop-in에 `Environment=DISPLAY=:0`). crash 시 자동 재시작.
- Mac: Moonlight → Add PC `<호스트 IP>` → 웹UI(`https://<호스트 IP>:47990`)에서 PIN 입력 → Desktop 스트림

> Sunshine/Moonlight는 이 repo의 범위 밖(호스트 인프라)이다. 이 Dockerfile은 stonefish 시뮬레이터만 담는다.

## 구조

- `stonefish.repos` — 3 repo 버전 매니페스트 (vcstool)
- `Dockerfile` — 멀티스테이지(builder→runtime). stonefish=`/opt` underlay, sim/slam=colcon overlay.
- `entrypoint.sh` — ROS·overlay 환경 source.
- `docker-compose.yml` — GPU·`:0` 디스플레이·X 소켓 마운트.

## 3-tier 의존 계층

| repo | 역할 | ROS 레이어 |
|:---|:---|:---|
| `stonefish` | C++ 물리/렌더 라이브러리 (v1.3.0, HERO Lab fork) | underlay (`/opt/stonefish`) |
| `stonefish_sim` | ROS2 Humble 통합 메타 (ros2/msgs/control/description) | overlay (`colcon_ws`) |
| `stonefish_slam` | 소나 SLAM 응용 (CFAR/OctoMap/GTSAM) | overlay (`colcon_ws`) |

## 버전 고정

```bash
vcs export src --exact > stonefish.lock.repos  # 현재 SHA 핀
```
