# 📚 읽쓰 문해력 학습 플랫폼

> 학생들의 독해력과 문해력 향상을 위한 체계적인 온라인 학습 시스템

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](package.json)
[![Platform](https://img.shields.io/badge/platform-Web%20%7C%20Mobile-lightgrey.svg)](README.md)

---

## 🎯 프로젝트 소개

**읽쓰 문해력**은 초등학생과 중학생을 위한 독해력 향상 학습 플랫폼입니다. 체계적인 학습 구조와 게이미피케이션 요소를 결합하여 학생들의 자기주도 학습을 촉진하고, 실질적인 문해력 향상을 돕습니다.

### ✨ 주요 특징

- 📖 **15권 체계적 커리큘럼**: 단계별 학습 구조
- 🎮 **게이미피케이션**: 퀘스트 시스템과 보상으로 학습 동기 부여
- 🤖 **AI 기반 피드백**: 서술 요약 자동 교정
- 📊 **실시간 학습 추적**: 읽기 속도, 정답률 등 상세 분석
- 🔄 **복습 시스템**: 종합 어휘장과 서술 요약
- 📱 **반응형 디자인**: PC, 태블릿, 모바일 지원

---

## 🚀 빠른 시작

### 사전 요구사항

```bash
Node.js >= 16.x
npm >= 8.x
PostgreSQL >= 14.x
Redis >= 6.x
```

### 설치 방법

```bash
# 저장소 클론
git clone https://github.com/your-org/literacy-platform.git
cd literacy-platform

# 의존성 설치
npm install

# 환경 변수 설정
cp .env.example .env
# .env 파일을 열어 필요한 값 입력

# 데이터베이스 마이그레이션
npm run db:migrate

# 개발 서버 실행
npm run dev
```

### 접속

- **학생 페이지**: http://localhost:3000
- **관리자 페이지**: http://localhost:3000/admin
- **API 문서**: http://localhost:3000/api-docs

---

## 📂 프로젝트 구조

```
literacy-platform/
├── src/
│   ├── api/              # API 엔드포인트
│   │   ├── auth/         # 인증 관련
│   │   ├── learning/     # 학습 관련
│   │   ├── vocabulary/   # 어휘 관련
│   │   └── quest/        # 퀘스트 관련
│   ├── components/       # React 컴포넌트
│   │   ├── common/       # 공통 컴포넌트
│   │   ├── learning/     # 학습 화면
│   │   ├── vocabulary/   # 어휘장
│   │   └── quest/        # 퀘스트
│   ├── hooks/            # Custom Hooks
│   ├── services/         # 비즈니스 로직
│   ├── utils/            # 유틸리티 함수
│   ├── models/           # 데이터 모델
│   └── constants/        # 상수 정의
├── public/               # 정적 파일
├── docs/                 # 문서
│   ├── 읽쓰문해력_상세분석.md
│   ├── 기능정의서.md
│   └── API.md
├── tests/                # 테스트 파일
├── scripts/              # 스크립트
└── config/               # 설정 파일
```

---

## 🎓 주요 기능

### 1. 학습 시스템

#### 권(Volume) 관리
- 총 15권 구성
- 부여 시점으로부터 6개월 사용 기한
- 중복 부여 시 독립된 학습관 생성

#### 강(Chapter) 진행
- 순차적 학습 구조
- 3차시 연속 실패 시 자동 패스
- 20분 내 재접속 시 이어하기 지원

#### 학습 단계
- **A단계**: 심화 학습 (10개 구간)
- **B/C단계**: 기본 학습 (8개 구간)

```
[학습 흐름]
제목읽기 → 문제풀이 → 어휘확인 → 지문읽기 → 
문제확인 → 다시읽기 → 정보처리 → 줄거리순서 → 어휘문제
```

### 2. 종합 어휘장

#### 오늘의 어휘
- 어휘 문제 오답 자동 생성
- 최근 3개 강좌 표시
- 복수 선택 학습 가능

#### 어휘 학습 프로세스
```
살펴보기 → 집중학습 → 문제풀기
```

#### 어휘 분류
- **아는 어휘**: 정답 처리된 어휘
- **모르는 어휘**: 오답 처리된 어휘

### 3. 서술 요약

#### 작성 지원 도구
- **발문**: 4가지 유형 제공
- **힌트**: 작성 틀 제공
- **모범 답안**: 비교 학습용
- **AI 교정**: 자동 교정 및 피드백

#### 관리 메뉴
- **오늘의 요약**: 최근 3개 강좌
- **전체 보기**: 전체 진행 현황

### 4. 학습 퀘스트 (나만의 디저트 만들기)

#### 퀘스트 구성
| 퀘스트 | 목표 횟수 |
|--------|----------|
| 강좌 성공 | 10개 |
| 오늘의 어휘 완료 | 7개 |
| 오늘의 요약 완료 | 7개 |
| 테마 학습 완료 | 5개 |

#### 보상 시스템
- **우수 쿠폰**: 순차적으로 퀘스트 완료 시
- **일반 쿠폰**: 4가지 퀘스트 모두 완료 시

---

## 🛠️ 기술 스택

### Frontend
- **Framework**: React 18.x
- **상태관리**: Redux Toolkit
- **스타일링**: Tailwind CSS
- **라우팅**: React Router v6
- **차트**: Recharts

### Backend
- **Runtime**: Node.js
- **Framework**: Express.js
- **ORM**: Prisma
- **인증**: JWT
- **파일저장**: AWS S3

### Database
- **주 데이터베이스**: PostgreSQL
- **캐싱**: Redis
- **세션**: Redis

### AI/ML
- **텍스트 분석**: OpenAI GPT-4
- **자연어 처리**: spaCy

### DevOps
- **컨테이너**: Docker
- **CI/CD**: GitHub Actions
- **모니터링**: Sentry
- **로깅**: Winston

---

## 🧪 테스트

### 테스트 실행

```bash
# 전체 테스트
npm test

# 단위 테스트
npm run test:unit

# 통합 테스트
npm run test:integration

# E2E 테스트
npm run test:e2e

# 커버리지 확인
npm run test:coverage
```

### 테스트 작성 가이드

```javascript
// 단위 테스트 예시
describe('Learning Service', () => {
  test('차시 성공 판정', () => {
    const result = checkLearningSuccess(testData);
    expect(result.success).toBe(true);
  });
});
```

---

## 📚 API 문서

### 인증

```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "student001",
  "password": "password123"
}
```

### 학습 진행

```http
POST /api/learning/progress
Authorization: Bearer {token}
Content-Type: application/json

{
  "volumeId": 1,
  "chapterId": 5,
  "lessonData": {
    "readingTime": 120,
    "answers": [...]
  }
}
```

자세한 API 문서는 [API.md](docs/API.md)를 참조하세요.

---

## 📊 데이터베이스 스키마

### 주요 테이블

```sql
-- 학생 테이블
CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 권 부여 테이블
CREATE TABLE volume_assignments (
  id SERIAL PRIMARY KEY,
  student_id INTEGER REFERENCES students(id),
  volume_id INTEGER NOT NULL,
  assigned_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP NOT NULL
);

-- 학습 진행 테이블
CREATE TABLE learning_progress (
  id SERIAL PRIMARY KEY,
  student_id INTEGER REFERENCES students(id),
  volume_id INTEGER,
  chapter_id INTEGER,
  lesson_id INTEGER,
  status VARCHAR(20), -- success, failed, in_progress
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🎨 UI/UX 가이드

### 디자인 시스템

#### 색상 팔레트
```css
:root {
  --primary: #FF6B6B;      /* 메인 색상 */
  --secondary: #4ECDC4;    /* 보조 색상 */
  --success: #95E1D3;      /* 성공 */
  --warning: #FFE66D;      /* 경고 */
  --danger: #FF6B9D;       /* 오류 */
  --text: #2C3E50;         /* 텍스트 */
  --background: #F8F9FA;   /* 배경 */
}
```

#### 타이포그래피
- **본문**: Pretendard, 16px
- **제목**: Pretendard Bold, 24px
- **캡션**: Pretendard, 14px

### 컴포넌트 사용 예시

```jsx
import { Button, Card, ProgressBar } from '@/components/common';

function LearningCard() {
  return (
    <Card>
      <h2>1권 - 동물의 세계</h2>
      <ProgressBar value={75} max={100} />
      <Button onClick={handleStart}>학습 시작</Button>
    </Card>
  );
}
```

---

## 🔒 보안

### 인증 및 권한
- JWT 토큰 기반 인증
- 역할 기반 접근 제어 (RBAC)
- 세션 타임아웃: 2시간

### 데이터 보호
- 개인정보 암호화 (AES-256)
- HTTPS 통신 필수
- SQL Injection 방어
- XSS 방어

### 개인정보 처리
- GDPR 준수
- 아동 온라인 개인정보 보호법 준수
- 데이터 최소 수집 원칙

---

## 📈 성능 최적화

### 프론트엔드
- Code Splitting
- Lazy Loading
- Image Optimization
- Service Worker 활용

### 백엔드
- 데이터베이스 인덱싱
- Redis 캐싱
- API 응답 압축
- Connection Pooling

### 모니터링
```bash
# 성능 측정
npm run analyze

# 번들 사이즈 확인
npm run bundle-size
```

---

## 🌐 배포

### Production 배포

```bash
# 빌드
npm run build

# Docker 이미지 생성
docker build -t literacy-platform:latest .

# Docker 컨테이너 실행
docker run -d -p 3000:3000 literacy-platform:latest
```

### 환경 변수

```bash
# .env.production
NODE_ENV=production
DATABASE_URL=postgresql://user:pass@host:5432/db
REDIS_URL=redis://host:6379
JWT_SECRET=your-secret-key
OPENAI_API_KEY=your-openai-key
AWS_S3_BUCKET=your-bucket-name
```

---

## 🤝 기여 가이드

### 브랜치 전략

- `main`: 프로덕션 브랜치
- `develop`: 개발 브랜치
- `feature/*`: 기능 개발
- `bugfix/*`: 버그 수정
- `hotfix/*`: 긴급 수정

### 커밋 메시지 규칙

```
feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅
refactor: 코드 리팩토링
test: 테스트 코드
chore: 빌드 설정 등

예시:
feat: 오늘의 어휘 자동 생성 기능 추가
fix: 학습 세션 타임아웃 오류 수정
```

### Pull Request 프로세스

1. Fork 저장소
2. Feature 브랜치 생성
3. 코드 작성 및 테스트
4. Commit & Push
5. Pull Request 생성
6. 코드 리뷰
7. Merge

---

## 📝 문서

- [상세 분석 문서](docs/읽쓰문해력_상세분석.md)
- [기능 정의서](docs/기능정의서.md)
- [API 문서](docs/API.md)
- [데이터베이스 스키마](docs/DATABASE.md)
- [개발 가이드](docs/DEVELOPMENT.md)

---

## 🐛 문제 해결

### 자주 묻는 질문 (FAQ)

**Q: 학습 중 세션이 끊겼어요.**
A: 20분 내에 재접속하면 이어하기가 가능합니다. 20분 초과 시 처음부터 다시 진행해야 합니다.

**Q: 퀘스트가 반영되지 않아요.**
A: 테마 학습은 1일 1회만 반영됩니다. 또한 상품을 선택해야 퀘스트가 시작됩니다.

**Q: 권이 만료되었는데 어떻게 하나요?**
A: 관리자에게 문의하여 권을 재부여 받으시면 됩니다.

### 버그 리포트

버그를 발견하셨나요? [이슈](https://github.com/your-org/literacy-platform/issues)를 등록해주세요.

---

## 📞 지원

- **이메일**: support@literacy-platform.com
- **문서**: https://docs.literacy-platform.com
- **커뮤니티**: https://community.literacy-platform.com

---

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

---

## 👥 팀

- **기획**: [기획팀]
- **디자인**: [디자인팀]
- **개발**: [개발팀]
- **QA**: [QA팀]

---

## 🗓️ 로드맵

### v1.0 (현재)
- ✅ 기본 학습 시스템
- ✅ 종합 어휘장
- ✅ 서술 요약
- ✅ 학습 퀘스트

### v1.1 (예정)
- [ ] 모바일 앱 출시
- [ ] 음성 인식 기능
- [ ] 학부모 대시보드
- [ ] 소셜 기능

### v2.0 (계획)
- [ ] AI 맞춤 학습
- [ ] 멀티미디어 콘텐츠
- [ ] 그룹 학습 기능
- [ ] 글로벌 서비스

---

## 🙏 감사의 말

이 프로젝트는 다음 오픈소스 라이브러리를 사용합니다:
- React
- Express.js
- PostgreSQL
- Redis
- Tailwind CSS

---

## 📊 통계

![GitHub stars](https://img.shields.io/github/stars/your-org/literacy-platform?style=social)
![GitHub forks](https://img.shields.io/github/forks/your-org/literacy-platform?style=social)
![GitHub issues](https://img.shields.io/github/issues/your-org/literacy-platform)
![GitHub pull requests](https://img.shields.io/github/issues-pr/your-org/literacy-platform)

---

<div align="center">
  <sub>Built with ❤️ by Literacy Platform Team</sub>
</div>
