# helperAI — llama.cpp 크로스 플랫폼 배포

`llama-server`(llama.cpp의 OpenAI 호환 API 서버)를 **Windows / Linux / macOS** 에서 동일한 방식으로 실행할 수 있는 배포 스크립트 모음입니다.

GGUF 모델을 로드해서 채팅/코드 도우미 등으로 사용하거나, 다른 애플리케이션의 AI 백엔드로 활용할 수 있습니다.

---

## 📦 폴더 구조 (실행 후)

```
배포 루트/
  ├─ setup.bat / setup.sh    ← 최초 1회 실행 (의존성/모델 다운로드)
  ├─ start.bat / start.sh    ← 매번 실행 (서버 기동)
  ├─ bin/                    ← llama.cpp 바이너리 (자동 생성됨)
  │   ├─ llama-server
  │   └─ ... (기타 .dll/.so/.dylib)
  └─ models/                 ← GGUF 모델 (자동 다운로드됨)
      └─ *.gguf
```

`bin/`과 `models/`는 setup 스크립트가 알아서 만듭니다. 사용자는 **setup → start** 순서로만 실행하면 됩니다.

---

## 🚀 빠른 시작

### Windows

```cmd
setup.bat        :: 최초 1회 (llama.cpp + 모델 다운로드)
start.bat        :: 서버 시작
```

→ 브라우저가 `http://127.0.0.1:8080` 으로 자동 열립니다.

### Linux / macOS

```bash
chmod +x setup.sh start.sh    # 최초 1회 실행 권한 부여
./setup.sh                    # 의존성 + 모델 다운로드
./start.sh                    # 서버 시작
```

→ 브라우저로 `http://127.0.0.1:8080` 접속.

### 종료

서버 콘솔에서 `Ctrl+C` 또는 창 닫기.

---

## 🛠️ 사전 요구사항

### 공통
- 인터넷 연결 (최초 셋업 시 약 6 GB 다운로드)
- GPU 드라이버 (Vulkan 1.2 이상 지원)
  - **NVIDIA**: 최신 GeForce/Quadro 드라이버
  - **AMD**: Adrenalin / Mesa 드라이버
  - **Intel**: Arc / Iris 드라이버

### Windows
- Windows 10/11 (x64)
- VC++ 재배포 패키지 ([vc_redist.x64.exe](https://aka.ms/vs/17/release/vc_redist.x64.exe))
- PowerShell (기본 포함되어 있음)

### Linux (Ubuntu 22.04 이상)
```bash
sudo apt install -y curl unzip libvulkan1 mesa-vulkan-drivers
# NVIDIA 사용 시: sudo apt install -y nvidia-driver-550 (또는 최신 버전)
```

### macOS (Big Sur 11.0 이상, Apple Silicon 권장)
```bash
# 기본 도구는 모두 macOS에 포함되어 있음
xcode-select --install   # 아직 설치 안 했으면 한 번만
```

---

## ⚙️ 설정 변경

### 모델 변경

`setup.bat` / `setup.sh` 안의 `MODEL_NAME` / `MODEL_URL` 부분을 수정하거나, `models/` 폴더에 직접 다른 `.gguf` 파일을 넣은 뒤 `start` 스크립트만 다시 실행하면 됩니다.

**추천 모델** (RTX 5070 12GB 기준):

| 용도 | 모델 | 크기 | 비고 |
|------|------|------|------|
| 일반 대화 | Qwen3-8B Q5_K_M | 약 5.8 GB | 기본값 (균형 좋음) |
| 일반 대화 | Qwen3-14B Q4_K_M | 약 9 GB | 컨텍스트 줄여서 사용 |
| 코딩 | Qwen2.5-Coder-7B Q5_K_M | 약 5.5 GB | 코드 생성/리뷰에 강함 |
| 가벼운 챗봇 | Qwen3-4B Q5_K_M | 약 2.8 GB | 4 GB GPU에서도 동작 |

추가 모델은 [HuggingFace - bartowski](https://huggingface.co/bartowski) 또는 [Qwen 공식](https://huggingface.co/Qwen) 에서 받을 수 있습니다.

### 서버 옵션 변경

`start.bat` / `start.sh` 안의 옵션을 조정하세요.

| 옵션 | 의미 | 기본값 |
|------|------|--------|
| `-c 32768` | 컨텍스트 길이 (토큰) | 32 K |
| `-ngl 99` | GPU에 올릴 레이어 수 (전체) | 99 |
| `--port 8080` | 서비스 포트 | 8080 |
| `--host 0.0.0.0` | 바인딩 주소 | 0.0.0.0 (LAN 노출) |
| `-fa on` | Flash Attention (속도↑, VRAM↓) | on |

`--host 127.0.0.1` 로 변경하면 본인 PC 에서만 접속 가능합니다 (LAN 노출 차단).

---

## 🌐 다중 사용자 / 내부망 사용

기본 설정(`--host 0.0.0.0`)이면 같은 네트워크의 다른 PC 에서도 접속할 수 있습니다.

### 서버 PC IP 확인

**Windows**:
```cmd
ipconfig
```

**Linux / macOS**:
```bash
ip addr | grep inet      # Linux
ifconfig | grep inet     # macOS
```

→ `192.168.x.x` 같은 LAN IP 를 다른 사용자에게 알려주면, 그 사람들은 `http://192.168.x.x:8080` 으로 접속하면 됩니다.

### 방화벽 허용 (Windows)

```cmd
netsh advfirewall firewall add rule name="helperAI" dir=in action=allow protocol=TCP localport=8080
```

(관리자 권한 cmd 에서 실행)

---

## 🔌 다른 앱과 연동 (OpenAI 호환 API)

`llama-server`는 OpenAI API 와 호환되므로, 다음 도구들과 즉시 연동됩니다:

- **VSCode**: Continue, Cline, Roo Code 같은 확장
- **JetBrains IDE**: Continue 플러그인
- **자체 앱**: HTTP POST `/v1/chat/completions`

### 연동 설정 예시

```json
{
  "apiBase": "http://127.0.0.1:8080/v1",
  "model": "Qwen_Qwen3-8B-Q5_K_M",
  "apiKey": "none"
}
```

→ 모델 이름은 `models/` 폴더의 `.gguf` 파일명(확장자 제외) 을 그대로 사용합니다.

### 자연어 → 구조화된 명령 (JSON Schema)

3D 엔진 / IDE 통합에 매우 유용합니다:

```bash
curl http://127.0.0.1:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen_Qwen3-8B-Q5_K_M",
    "messages": [
      {"role": "system", "content": "출력은 JSON 만 하세요."},
      {"role": "user", "content": "큐브 3개 만들어줘"}
    ],
    "response_format": {
      "type": "json_schema",
      "json_schema": {
        "schema": {
          "type": "object",
          "properties": {
            "actions": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "command": { "type": "string" },
                  "params":  { "type": "object" }
                }
              }
            }
          }
        }
      }
    }
  }'
```

→ 응답이 **항상 정의한 스키마에 맞는 JSON** 으로 옵니다. 파싱 실패가 거의 없어서 자동화에 적합합니다.

---

## 📦 USB / 외장 드라이브로 배포

이 스크립트들은 `%~dp0` (Windows) / `$(dirname "$0")` (Linux/macOS) 기준 상대 경로를 사용하므로 **어떤 폴더/드라이브에 풀어놔도 그대로 동작**합니다.

```
USB 드라이브 (예: E:\helperAI 또는 /Volumes/USB/helperAI)
  ├─ setup.bat / setup.sh
  ├─ start.bat / start.sh
  ├─ bin/
  └─ models/
```

→ USB 꽂은 후 `start.bat` 더블클릭 만으로 동작합니다.

⚠️ USB 메모리에서 실행하면 모델 로딩이 느립니다 (4–10 GB 파일을 매번 로드). **외장 SSD** 사용을 권장합니다.

---

## 🌍 OS 별 백엔드 선택 가이드

`setup` 스크립트는 기본적으로 Vulkan 빌드를 받습니다. 이유:

| OS | Vulkan | 다른 옵션 |
|---|---|---|
| Windows | ✅ 기본 | CUDA (NVIDIA, 약 5–15% 빠름) |
| Linux | ✅ 기본 | CUDA (설치 까다로움) |
| macOS | ⚠️ MoltenVK 경유 | **Metal (네이티브, 약 30% 빠름)** |

→ Windows / Linux 는 Vulkan 으로 충분.
→ macOS 에서 최고 성능이 필요하면 setup 스크립트 수정해서 `*-bin-macos-arm64.zip` (Metal 빌드) 로 받으세요.

---

## ❓ 문제 해결

### llama-server 실행 시 GPU 가 안 잡힘
콘솔 로그에 `ggml_vulkan: Found ...` 이 안 뜨면 드라이버 문제입니다.

```bash
# Vulkan 동작 확인
vulkaninfo --summary
```

→ 정보가 안 나오면 GPU 드라이버를 업데이트하세요.

### "cudart64_*.dll 을 찾을 수 없습니다" (Windows)
잘못된 빌드를 받았을 때 발생. setup.bat 은 Vulkan 빌드를 받아야 정상입니다.

→ `bin/` 폴더 삭제 후 `setup.bat` 재실행.

### 모델 로딩 시 메모리 부족
`start` 스크립트의 `-c 32768` 을 `-c 8192` 등으로 줄이거나, 더 작은 모델을 사용하세요.

### 다운로드가 중단됨
- Windows: `setup.bat` 은 자동 재시도가 안 됩니다. → `temp/` 폴더 삭제 후 재실행.
- Linux / macOS: `curl -C -` 로 이어받기 가능 (스크립트에는 미반영, 수동 시).

### 포트 8080 이 이미 사용 중
`start` 스크립트의 `--port 8080` 을 다른 포트(예: 8090) 로 변경하세요.

### Vulkan SDK 가 없다고 나옴
**런타임 실행에는 Vulkan SDK 가 필요 없습니다.** GPU 드라이버에 포함된 Vulkan 런타임만 있으면 됩니다.
SDK 가 필요한 경우는 본인이 직접 llama.cpp 를 빌드하려는 경우뿐입니다.

---

## 📚 참고

- **llama.cpp 본 프로젝트**: https://github.com/ggml-org/llama.cpp
- **모델 검색 (GGUF)**: https://huggingface.co/models?library=gguf
- **llama-server API 문서**: https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md
- **이 fork**: https://github.com/kimyuheon/llama

---

## 📝 라이선스

llama.cpp 는 MIT 라이선스입니다.
이 setup 스크립트도 동일하게 자유롭게 사용/수정 가능합니다.
