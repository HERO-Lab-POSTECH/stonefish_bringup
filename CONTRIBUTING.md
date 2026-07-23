# 기여 가이드 (팀 공통 규칙 SSOT)

국기연 SLAM 시뮬레이터 repo 묶음(`stonefish`, `stonefish_sim`, `stonefish_slam`, `stonefish_bringup`)의 **협업 규칙 단일 진실(SSOT)**. git 워크플로와 작업 프로세스를 규정한다. 담당: 김승민.

> **발명한 규칙이 아니라 이 repo들이 이미 쓰고 있는 관행을 명문화한 것**이다(커밋 로그·각 repo `docs/CONVENTIONS.md`에서 귀납). 코드 레벨 컨벤션(명명·구조·좌표계)은 각 repo의 `docs/CONVENTIONS.md`가 SSOT다 — 이 문서는 repo 무관 공통 규칙만 다룬다.

## 1. 커밋 메시지 — Conventional Commits

형식: `type(scope): subject` (영어, 소문자 시작, 마침표 없음). scope는 선택.

| type | 용도 | 실제 예시 |
|:---|:---|:---|
| `feat` | 기능 추가 | `feat(launch): add top-level bringup for simulator + control + path` |
| `fix` | 버그 수정 | `fix(rviz): make SLAM displays render in world_ned` |
| `docs` | 문서만 변경 | `docs: add Docker install section + sync docs with code` |
| `refactor` | 동작 불변 구조 개선 | `refactor(launch): split control stack into control + path` |
| `chore` | 빌드/설정/도구 | `chore(launch): parameterize standalone launches` |
| `test` | 테스트 추가/수정 | `test: add regression for velocity_damped NameError` |
| `release` | 버전 컷 | `release(p4): cut 0.4.0 -- CHANGELOG, license` |

- 본문(선택)에는 **왜** 바꿨는지·검증 방법을 적는다. "동작 불변" 리팩토링은 그 사실을 본문에 명시.
- 한 커밋 = 한 논리적 변경(atomic). 무관한 변경을 한 커밋에 섞지 않는다.

## 2. 브랜치 전략

- `main`은 항상 빌드·동작 가능한 상태를 유지한다(보호 브랜치). **`main`에 직접 push하지 않는다.**
- 작업은 `<type>/<짧은-설명>` 브랜치에서 한다. 예: `fix/readme-launch-file-name`, `feat/fft-localization`.
- 브랜치 이름의 `type`은 커밋 type과 같은 어휘를 쓴다.

## 3. Pull Request

- 모든 변경은 PR로 `main`에 병합한다. PR 제목도 Conventional Commits 형식.
- PR 본문은 **문제 → 수정 → 검증** 3단 구성. 무엇을 어떻게 검증했는지(빌드·기동·테스트 로그)를 반드시 남긴다.
- **authoring과 review는 분리한다** — 자기 작업을 자기가 승인하지 않는다. 리뷰 통과 후 병합.

## 4. 작업 프로세스 게이트

비자명한 변경은 아래 5단계를 순서대로 통과한다. "간단해 보여서 바로 고침"이 이 프로젝트에서 가장 위험한 안티패턴이다.

| 단계 | 무엇을 | 산출물(증거) |
|:---|:---|:---|
| ① 정독 + 의존성 추적 | 대상 코드를 줄 단위로 읽고, import/호출하는 곳·의존하는 곳을 모두 추적 | "누가 이걸 쓰나" 목록(grep/LSP 근거) |
| ② 자료 조사 | ROS2 Humble 관행·라이브러리 API·도메인 관행을 공식 문서로 확인(기억 금지) | 인용 URL/문서 근거 |
| ③ 설계 | 변경 범위·인터페이스·하위호환·테스트 전략을 먼저 글로 적음 | 설계 노트 |
| ④ 구현 | 설계대로 최소 변경. 기존 스타일을 따름 | diff |
| ⑤ 검토 | 별도 패스(자가승인 금지)로 정합성·테스트·회귀 확인 | 테스트 결과 + 리뷰 |

- **추측 금지·증거 우선.** 파일 경로·함수 시그니처·동작은 읽어서 확인한다.
- **규모에 맞게 조절.** 3–4줄 자명한 수정은 ④⑤만. 로직·수치·인터페이스·다중파일이면 전체 게이트.
- **3-Strike / 15분 규칙.** 같은 접근이 3번 실패하거나 한 문제에 15분 막히면 방법을 바꾼다.

## 5. 코드 레벨 컨벤션 (repo별 SSOT)

명명·디렉토리 구조·ROS2 노드 패턴·좌표계(NED, `world_ned`)·C++/pybind11 등 **코드 컨벤션은 각 repo의 `docs/CONVENTIONS.md`가 SSOT**다 — 코드 작업 전 필독.

- `stonefish_sim/docs/CONVENTIONS.md`
- `stonefish_slam/docs/CONVENTIONS.md`
