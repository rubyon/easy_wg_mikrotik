[![Buy me a coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=☕&slug=rubyonstudio&button_colour=FF5F5F&font_colour=ffffff&font_family=Lato&outline_colour=000000&coffee_colour=FFDD00)](https://www.buymeacoffee.com/rubyonstudio)

# Easy WireGuard MikroTik Manager

A simple and intuitive web interface for managing WireGuard VPN clients on MikroTik routers.

## Features

- **🔗 MikroTik RouterOS API Integration**: Direct connection to your MikroTik router with secure session management
- **🔄 Dynamic Interface Selection**: Automatically detect and select WireGuard interfaces with real-time updates
- **👥 Client Management**: Create, view, and delete WireGuard clients with live status monitoring
- **📱 QR Code Generation**: Instant QR codes for mobile device configuration with Bootstrap Icons
- **💾 Configuration Downloads**: Download .conf files for desktop clients via Stimulus controllers
- **⚡ Real-time Updates**: Turbo Stream-powered interface for seamless user experience
- **🎨 Modern UI**: Clean, responsive design with Tailwind CSS 4.1.11 and backdrop blur effects
- **🌍 Multi-language Support**: Korean (default), English, Chinese, and Japanese localization
- **🔒 Enhanced Security**: XSS protection with input validation and safe QR code generation

## Requirements

- **Ruby**: 3.0+ (Tested with Ruby 3.4.2)
- **Rails**: 8.0.2+ with Hotwire (Turbo + Stimulus)
- **MikroTik Router**: RouterOS v7.0+ with WireGuard support
- **Dependencies**: Node.js, Yarn for asset compilation
- **Browser**: Modern browser with JavaScript enabled

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
bundle install
yarn install
```

3. Start the development server:
```bash
bin/dev
```

4. Open your browser and navigate to `http://localhost:3000`

## Usage

### Initial Setup

1. **Login to MikroTik**: Enter your MikroTik router's IP address, username, and password
2. **Ensure WireGuard Interface**: Make sure you have at least one WireGuard interface configured on your MikroTik router

### Creating WireGuard Clients

1. Click "Create New Client" button
2. Select your WireGuard interface from the dropdown
3. Configure the following settings:
   - **Endpoint**: Your server's public IP and port (e.g., `your-server.com:51820`)
   - **Allowed IPs**: Networks the client can access (e.g., `10.1.1.0/24,192.168.1.0/24`)
   - **Client IP Range**: Subnet prefix for client IPs (e.g., `10.1.1`)
   - **Keep Alive**: Persistent keepalive interval in seconds (e.g., `25`)
4. Click "Create Client" button
5. Download the configuration file or scan the QR code with your mobile device

### Managing Clients

- **View Clients**: Click "Client List" to see all configured clients
- **Filter by Interface**: Select an interface to view only its clients
- **Delete Clients**: Click the delete button next to any client to remove it
- **Refresh**: Click the refresh button to update the client list

## Configuration

The application uses session-based authentication to store your MikroTik credentials securely. No credentials are stored permanently on the server.

## Technology Stack

### Backend
- **Framework**: Ruby on Rails 8.0.2
- **Authentication**: Session-based with optional cookie persistence (no database)
- **API**: RouterOS API gem for MikroTik integration
- **Security**: Brakeman scanning, XSS protection, input validation

### Frontend
- **JavaScript**: Hotwire (Turbo + Stimulus) for reactive UI
- **CSS**: Tailwind CSS 4.1.11 with modern features
- **Icons**: Bootstrap Icons 1.11.3
- **Build Tools**: esbuild for JavaScript, Tailwind CLI for CSS
- **Real-time**: Turbo Streams for live updates

### Core Libraries
- **Cryptography**: RbNaCl for secure WireGuard key generation
- **QR Codes**: RQRCode for mobile configuration
- **Localization**: Rails I18n with 4 language support
- **Code Quality**: RuboCop Rails Omakase, ERB Lint

## Security Features

- **🔒 XSS Protection**: Input validation and safe output rendering
- **🛡️ Session Security**: Secure session management without persistent credential storage
- **🔍 Security Scanning**: Integrated Brakeman security analysis
- **✅ Input Validation**: Comprehensive validation for all WireGuard configuration parameters
- **🔐 Safe QR Generation**: Secure QR code generation with validation

### Security Best Practices
- Use strong passwords for your MikroTik router
- Run behind HTTPS in production environments
- Regularly update MikroTik RouterOS firmware
- Monitor and remove unused VPN clients
- Review application logs for suspicious activity

## Development

### Code Quality Commands
```bash
# Run security scan
bundle exec brakeman

# Check code style
bundle exec rubocop
erb_lint --lint-all

# Auto-fix style issues
bundle exec rubocop -A
erb_lint --lint-all --autocorrect

# Run tests
bin/rails test
bin/rails test:system
```

### Project Structure
- `app/controllers/clients_controller.rb` - Main WireGuard client management
- `app/helpers/qr_code_helper.rb` - Secure QR code generation
- `app/javascript/controllers/` - Stimulus controllers for dynamic UI
- `app/views/clients/` - WireGuard client management views
- `config/locales/` - Multi-language support files

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes with proper tests
4. Run code quality checks (`rubocop -A && erb_lint --lint-all --autocorrect`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is open source and available under the MIT License.

---

# Easy WireGuard MikroTik Manager (한국어)

MikroTik 라우터에서 WireGuard VPN 클라이언트를 관리할 수 있는 간단하고 직관적인 웹 인터페이스입니다.

## 주요 기능

- **🔗 MikroTik RouterOS API 연동**: 안전한 세션 관리로 MikroTik 라우터에 직접 연결
- **🔄 동적 인터페이스 선택**: 실시간 업데이트로 WireGuard 인터페이스 자동 감지 및 선택
- **👥 클라이언트 관리**: 실시간 상태 모니터링으로 WireGuard 클라이언트 생성, 조회, 삭제
- **📱 QR 코드 생성**: Bootstrap Icons와 함께 모바일 디바이스 설정을 위한 즉시 QR 코드 생성
- **💾 설정 파일 다운로드**: Stimulus 컨트롤러를 통한 데스크톱 클라이언트용 .conf 파일 다운로드
- **⚡ 실시간 업데이트**: Turbo Stream 기반 인터페이스로 원활한 사용자 경험
- **🎨 모던 UI**: Tailwind CSS 4.1.11과 백드롭 블러 효과를 사용한 깔끔하고 반응형 디자인
- **🌍 다국어 지원**: 한국어(기본), 영어, 중국어, 일본어 현지화
- **🔒 강화된 보안**: 입력 검증과 안전한 QR 코드 생성으로 XSS 보호

## 시스템 요구사항

- **Ruby**: 3.0+ (Ruby 3.4.2에서 테스트됨)
- **Rails**: 8.0.2+ with Hotwire (Turbo + Stimulus)
- **MikroTik 라우터**: RouterOS v7.0+ with WireGuard 지원
- **의존성**: Node.js, Yarn (에셋 컴파일용)
- **브라우저**: JavaScript가 활성화된 최신 브라우저

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
bundle install
yarn install
```

3. 개발 서버 시작:
```bash
bin/dev
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
4. "새 클라이언트 생성" 버튼 클릭
5. 설정 파일을 다운로드하거나 모바일 디바이스로 QR 코드 스캔

### 클라이언트 관리

- **클라이언트 보기**: "클라이언트 목록"을 클릭하여 모든 구성된 클라이언트 확인
- **인터페이스별 필터링**: 인터페이스를 선택하여 해당 클라이언트만 표시
- **클라이언트 삭제**: 클라이언트 옆의 삭제 버튼을 클릭하여 제거
- **새로고침**: 새로고침 버튼을 클릭하여 클라이언트 목록 업데이트

## 구성

애플리케이션은 세션 기반 인증을 사용하여 MikroTik 자격 증명을 안전하게 저장합니다. 서버에는 자격 증명이 영구적으로 저장되지 않습니다.

## 기술 스택

### 백엔드
- **프레임워크**: Ruby on Rails 8.0.2
- **인증**: 선택적 쿠키 지속성을 가진 세션 기반 인증 (데이터베이스 없음)
- **API**: MikroTik 통합을 위한 RouterOS API gem
- **보안**: Brakeman 스캐닝, XSS 보호, 입력 검증

### 프론트엔드
- **JavaScript**: 반응형 UI를 위한 Hotwire (Turbo + Stimulus)
- **CSS**: 최신 기능을 가진 Tailwind CSS 4.1.11
- **아이콘**: Bootstrap Icons 1.11.3
- **빌드 도구**: JavaScript용 esbuild, CSS용 Tailwind CLI
- **실시간**: 실시간 업데이트를 위한 Turbo Streams

### 핵심 라이브러리
- **암호화**: 안전한 WireGuard 키 생성을 위한 RbNaCl
- **QR 코드**: 모바일 설정을 위한 RQRCode
- **현지화**: 4개 언어 지원을 가진 Rails I18n
- **코드 품질**: RuboCop Rails Omakase, ERB Lint

## 보안 기능

- **🔒 XSS 보호**: 입력 검증과 안전한 출력 렌더링
- **🛡️ 세션 보안**: 영구 자격 증명 저장 없이 안전한 세션 관리
- **🔍 보안 스캐닝**: 통합된 Brakeman 보안 분석
- **✅ 입력 검증**: 모든 WireGuard 설정 매개변수에 대한 포괄적 검증
- **🔐 안전한 QR 생성**: 검증을 통한 안전한 QR 코드 생성

### 보안 모범 사례
- MikroTik 라우터에 강력한 비밀번호 사용
- 프로덕션 환경에서 HTTPS 뒤에서 실행
- MikroTik RouterOS 펌웨어 정기 업데이트
- 사용하지 않는 VPN 클라이언트 모니터링 및 제거
- 의심스러운 활동에 대한 애플리케이션 로그 검토

## 기여하기

1. 저장소 포크
2. 기능 브랜치 생성
3. 변경 사항 적용
4. 풀 리퀘스트 제출

## 라이센스

이 프로젝트는 오픈 소스이며 MIT 라이센스 하에 제공됩니다.