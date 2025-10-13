export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken?: string;
  // tokenType?: string;
}

// 백엔드 응답 구조
export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
}

export interface User {
  id: string;
  username: string;
  email?: string;
  roles?: string[];
}

export interface AuthContextType {
  user: User | null;
  accessToken: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (username: string, password: string) => Promise<void>;
  logout: () => void;
  getAccessToken: () => string | null;
}

export interface DecodedToken {
  sub: string;
  exp: number;
  iat: number;
  email?: string;
  roles?: string[];
  [key: string]: any;
}
