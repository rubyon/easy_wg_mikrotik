# Easy WireGuard MikroTik Manager

A simple and intuitive web interface for managing WireGuard VPN clients on MikroTik routers.

## Features

- **MikroTik RouterOS API Integration**: Direct connection to your MikroTik router
- **Dynamic Interface Selection**: Automatically detect and select WireGuard interfaces
- **Client Management**: Create, view, and delete WireGuard clients
- **QR Code Generation**: Instant QR codes for mobile device configuration
- **Configuration Downloads**: Download .conf files for desktop clients
- **Real-time Updates**: AJAX-powered interface for seamless user experience
- **Modern UI**: Clean, responsive design with Tailwind CSS

## Requirements

- Ruby 3.0+
- Rails 8.0+
- MikroTik router with RouterOS v7.0+ (WireGuard support)
- WireGuard interface configured on MikroTik

## Installation

### Option 1: Docker Compose (Recommended)

1. Clone the repository:
```bash
git clone https://github.com/rubyon/easy_wg_mikrotik.git
cd easy_wg_mikrotik
```

2. Run with Docker Compose:
```bash
docker compose up --build
```

3. Open your browser and navigate to `http://localhost:3000`

### Option 2: Local Development

1. Clone the repository:
```bash
git clone https://github.com/rubyon/easy_wg_mikrotik.git
cd easy_wg_mikrotik
```

2. Install dependencies:
```bash
bundle
yarn
```

3. Start the development server:
```bash
./bin/dev
```

4. Open your browser and navigate to `http://localhost:3000`

## Usage

### Initial Setup

1. **Login to MikroTik**: Enter your MikroTik router's IP address, username, and password
2. **Ensure WireGuard Interface**: Make sure you have at least one WireGuard interface configured on your MikroTik router

### Creating WireGuard Clients

1. Click "새 클라이언트 생성" (New Client) button
2. Select your WireGuard interface from the dropdown
3. Configure the following settings:
   - **Endpoint**: Your server's public IP and port (e.g., `your-server.com:51820`)
   - **Allowed IPs**: Networks the client can access (e.g., `10.1.1.0/24,192.168.1.0/24`)
   - **Client IP Range**: Subnet prefix for client IPs (e.g., `10.1.1`)
   - **Keep Alive**: Persistent keepalive interval in seconds (e.g., `25`)
4. Click "클라이언트 생성" (Create Client)
5. Download the configuration file or scan the QR code with your mobile device

### Managing Clients

- **View Clients**: Click "클라이언트 목록" (Client List) to see all configured clients
- **Filter by Interface**: Select an interface to view only its clients
- **Delete Clients**: Click the delete button next to any client to remove it
- **Refresh**: Click the refresh button to update the client list

## Configuration

The application uses session-based authentication to store your MikroTik credentials securely. No credentials are stored permanently on the server.

## Technology Stack

- **Backend**: Ruby on Rails 8.0.2
- **Frontend**: Hotwire Stimulus, Tailwind CSS
- **Cryptography**: RbNaCl for WireGuard key generation
- **QR Codes**: RQRCode gem
- **MikroTik API**: RouterOS API gem

## Security Notes

- Always use strong passwords for your MikroTik router
- Consider running this application behind a reverse proxy with HTTPS
- Regularly update your MikroTik RouterOS firmware
- Monitor client access and remove unused clients

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is open source and available under the MIT License.

---

# Easy WireGuard MikroTik Manager (한국어)

MikroTik 라우터에서 WireGuard VPN 클라이언트를 관리할 수 있는 간단하고 직관적인 웹 인터페이스입니다.

## 주요 기능

- **MikroTik RouterOS API 연동**: MikroTik 라우터에 직접 연결
- **동적 인터페이스 선택**: WireGuard 인터페이스 자동 감지 및 선택
- **클라이언트 관리**: WireGuard 클라이언트 생성, 조회, 삭제
- **QR 코드 생성**: 모바일 디바이스 설정을 위한 즉시 QR 코드 생성
- **설정 파일 다운로드**: 데스크톱 클라이언트용 .conf 파일 다운로드
- **실시간 업데이트**: AJAX 기반 인터페이스로 원활한 사용자 경험
- **모던 UI**: Tailwind CSS를 사용한 깔끔하고 반응형 디자인

## 시스템 요구사항

- Ruby 3.0+
- Rails 8.0+
- RouterOS v7.0+ (WireGuard 지원) MikroTik 라우터
- MikroTik에 구성된 WireGuard 인터페이스

## 설치 방법

### 방법 1: Docker Compose (권장)

1. 저장소 클론:
```bash
git clone https://github.com/rubyon/easy_wg_mikrotik.git
cd easy_wg_mikrotik
```

2. Docker Compose로 실행:
```bash
docker compose up --build
```

3. 브라우저에서 `http://localhost:3000` 접속

### 방법 2: 로컬 개발 환경

1. 저장소 클론:
```bash
git clone https://github.com/rubyon/easy_wg_mikrotik.git
cd easy_wg_mikrotik
```

2. 의존성 설치:
```bash
bundle
yarn
```

3. 개발 서버 시작:
```bash
./bin/dev
```

4. 브라우저에서 `http://localhost:3000` 접속

## 사용 방법

### 초기 설정

1. **MikroTik 로그인**: MikroTik 라우터의 IP 주소, 사용자명, 비밀번호 입력
2. **WireGuard 인터페이스 확인**: MikroTik 라우터에 최소 하나의 WireGuard 인터페이스가 구성되어 있는지 확인

### WireGuard 클라이언트 생성

1. "새 클라이언트 생성" 버튼 클릭
2. 드롭다운에서 WireGuard 인터페이스 선택
3. 다음 설정 구성:
   - **엔드포인트**: 서버의 공인 IP와 포트 (예: `your-server.com:51820`)
   - **허용된 IP**: 클라이언트가 액세스할 수 있는 네트워크 (예: `10.1.1.0/24,192.168.1.0/24`)
   - **클라이언트 IP 대역**: 클라이언트 IP용 서브넷 접두사 (예: `10.1.1`)
   - **킵얼라이브**: 지속적인 킵얼라이브 간격(초) (예: `25`)
4. "클라이언트 생성" 클릭
5. 설정 파일을 다운로드하거나 모바일 디바이스로 QR 코드 스캔

### 클라이언트 관리

- **클라이언트 보기**: "클라이언트 목록"을 클릭하여 모든 구성된 클라이언트 확인
- **인터페이스별 필터링**: 인터페이스를 선택하여 해당 클라이언트만 표시
- **클라이언트 삭제**: 클라이언트 옆의 삭제 버튼을 클릭하여 제거
- **새로고침**: 새로고침 버튼을 클릭하여 클라이언트 목록 업데이트

## 구성

애플리케이션은 세션 기반 인증을 사용하여 MikroTik 자격 증명을 안전하게 저장합니다. 서버에는 자격 증명이 영구적으로 저장되지 않습니다.

## 기술 스택

- **백엔드**: Ruby on Rails 8.0.2
- **프론트엔드**: Hotwire Stimulus, Tailwind CSS
- **암호화**: WireGuard 키 생성을 위한 RbNaCl
- **QR 코드**: RQRCode gem
- **MikroTik API**: RouterOS API gem

## 보안 주의사항

- MikroTik 라우터에 항상 강력한 비밀번호 사용
- HTTPS가 적용된 리버스 프록시 뒤에서 이 애플리케이션 실행 고려
- MikroTik RouterOS 펌웨어를 정기적으로 업데이트
- 클라이언트 액세스를 모니터링하고 사용하지 않는 클라이언트 제거

## 기여하기

1. 저장소 포크
2. 기능 브랜치 생성
3. 변경 사항 적용
4. 풀 리퀘스트 제출

## 라이센스

이 프로젝트는 오픈 소스이며 MIT 라이센스 하에 제공됩니다.