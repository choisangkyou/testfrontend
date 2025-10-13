# JWT 인증 시스템 사용 가이드

## 📋 개요

React + TypeScript 기반의 JWT 인증 시스템이 구현되었습니다.

## 🏗️ 구조

```
src/
├── api/
│   ├── axiosConfig.ts      # Axios 인스턴스 및 인터셉터 설정
│   ├── authApi.ts          # 인증 관련 API 함수
│   └── helloApi.ts         # 예제 API
├── components/
│   └── ProtectedRoute.tsx  # 보호된 라우트 컴포넌트
├── contexts/
│   └── AuthContext.tsx     # 인증 컨텍스트 및 Provider
├── pages/
│   ├── HomePage.tsx        # 홈 페이지 (보호됨)
│   ├── HomePage.css
│   ├── LoginPage.tsx       # 로그인 페이지
│   └── LoginPage.css
├── types/
│   └── auth.types.ts       # 인증 관련 타입 정의
└── App.tsx                 # 라우팅 설정
```

## 🔑 주요 기능

### 1. **자동 토큰 관리**
- 모든 API 요청에 JWT 토큰 자동 추가
- 토큰 만료 시 자동 갱신 (Refresh Token)
- 401 에러 발생 시 자동 재시도

### 2. **보호된 라우트**
- 인증되지 않은 사용자는 자동으로 로그인 페이지로 리다이렉트
- 로딩 상태 처리

### 3. **사용자 정보 관리**
- JWT 토큰에서 사용자 정보 자동 추출
- Context API를 통한 전역 상태 관리

## 🚀 사용 방법

### 1. 패키지 설치

```bash
npm install
```

### 2. 백엔드 API 엔드포인트

다음 엔드포인트가 백엔드에 구현되어 있어야 합니다:

#### **POST /auth/login**
```json
// Request
{
  "username": "string",
  "password": "string"
}

// Response
{
  "accessToken": "string",
  "refreshToken": "string" // 선택사항
}
```

#### **POST /auth/refresh**
```json
// Request
{
  "refreshToken": "string"
}

// Response
{
  "accessToken": "string"
}
```

#### **POST /auth/logout** (선택사항)
```json
// Request: 빈 본문
// Response: 성공 상태
```

### 3. JWT 토큰 페이로드 구조

백엔드에서 생성하는 JWT 토큰은 다음 정보를 포함해야 합니다:

```json
{
  "sub": "사용자ID",
  "email": "user@example.com",
  "roles": ["USER", "ADMIN"],
  "exp": 1234567890,
  "iat": 1234567890
}
```

### 4. 애플리케이션 실행

```bash
npm start
```

## 💡 코드 사용 예제

### AuthContext 사용하기

```tsx
import { useAuth } from './contexts/AuthContext';

function MyComponent() {
  const { user, isAuthenticated, login, logout } = useAuth();

  const handleLogin = async () => {
    try {
      await login('username', 'password');
      // 로그인 성공
    } catch (error) {
      // 로그인 실패
    }
  };

  return (
    <div>
      {isAuthenticated ? (
        <div>
          <p>환영합니다, {user?.username}님!</p>
          <button onClick={logout}>로그아웃</button>
        </div>
      ) : (
        <button onClick={handleLogin}>로그인</button>
      )}
    </div>
  );
}
```

### 보호된 API 호출

```tsx
import { api } from './api/axiosConfig';

// 자동으로 JWT 토큰이 헤더에 추가됩니다
const fetchData = async () => {
  const response = await api.get('/protected-endpoint');
  return response.data;
};
```

### 새로운 보호된 페이지 추가

```tsx
// App.tsx
<Route
  path="/dashboard"
  element={
    <ProtectedRoute>
      <DashboardPage />
    </ProtectedRoute>
  }
/>
```

## 🔧 설정 변경

### API 베이스 URL 변경

`src/api/axiosConfig.ts` 파일에서 수정:

```typescript
export const api = axios.create({
  baseURL: 'http://your-api-url:port',
  headers: {
    'Content-Type': 'application/json',
  },
});
```

### 토큰 저장소 변경 (LocalStorage → SessionStorage)

`src/contexts/AuthContext.tsx`에서 `localStorage`를 `sessionStorage`로 변경:

```typescript
// 변경 전
localStorage.setItem('accessToken', token);

// 변경 후
sessionStorage.setItem('accessToken', token);
```

## 🔒 보안 고려사항

1. **HTTPS 사용**: 프로덕션 환경에서는 반드시 HTTPS를 사용하세요.
2. **토큰 만료 시간**: 적절한 토큰 만료 시간을 설정하세요 (예: Access Token 15분, Refresh Token 7일).
3. **XSS 방지**: 토큰을 LocalStorage에 저장하므로 XSS 공격에 주의하세요.
4. **CORS 설정**: 백엔드에서 적절한 CORS 설정이 필요합니다.

## 📝 라우트 구조

- `/login` - 로그인 페이지 (공개)
- `/` - 홈 페이지 (보호됨)
- 기타 경로 - `/`로 리다이렉트

## 🐛 트러블슈팅

### 401 에러가 계속 발생하는 경우
- 백엔드 API가 올바르게 실행 중인지 확인
- JWT 토큰 형식이 올바른지 확인
- CORS 설정 확인

### 로그인 후 페이지가 리다이렉트되지 않는 경우
- 브라우저 콘솔에서 에러 확인
- 네트워크 탭에서 API 응답 확인

### 토큰이 저장되지 않는 경우
- 브라우저의 LocalStorage 사용 가능 여부 확인
- 시크릿 모드에서는 LocalStorage가 제한될 수 있음

## 📦 설치된 패키지

- `jwt-decode`: JWT 토큰 디코딩
- `react-router-dom`: 라우팅
- `axios`: HTTP 클라이언트

## 🎨 UI 커스터마이징

로그인 페이지와 홈 페이지의 스타일은 각각의 CSS 파일에서 수정할 수 있습니다:
- `src/pages/LoginPage.css`
- `src/pages/HomePage.css`
