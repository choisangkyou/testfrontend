import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  ReactNode,
} from "react";
// AuthContext.tsx 상단에 추가
import { jwtDecode } from "jwt-decode";
import {
  AuthContextType,
  User,
  DecodedToken,
  ApiResponse,
  LoginResponse,
} from "../types/auth.types";
import { loginApi } from "../api/authApi";

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [accessToken, setAccessToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // 앱 시작 시 로컬 스토리지에서 토큰 확인
    const token = localStorage.getItem("accessToken");
    if (token) {
      try {
        const decoded = jwtDecode<DecodedToken>(token);

        // 토큰 만료 확인
        if (decoded.exp * 1000 > Date.now()) {
          setUser({
            id: decoded.sub,
            username: decoded.sub,
            email: decoded.email,
            roles: decoded.roles,
          });

          console.log("✅ 저장된 토큰으로 자동 로그인:", decoded.sub);
        } else {
          // 만료된 토큰 제거
          console.log("⚠️ 토큰 만료됨");
          localStorage.removeItem("accessToken");
          localStorage.removeItem("refreshToken");
        }
      } catch (error) {
        console.error("토큰 디코딩 실패:", error);
        localStorage.removeItem("accessToken");
        localStorage.removeItem("refreshToken");
      }
    }
    setIsLoading(false);
  }, []);

  const login = async (username: string, password: string) => {
    try {
      console.log("🔐 로그인 시도:", username);
      const response = await loginApi<ApiResponse<LoginResponse>>({
        username,
        password,
      });

      console.log("📦 서버 응답:", response);

      // 응답 성공 여부 확인
      if (!response.success) {
        throw new Error(response.message || "로그인 실패");
      }

      // 토큰 저장
      const { accessToken, refreshToken } = response.data;
      // localStorage.setItem("accessToken", response.accessToken);
      // if (response.refreshToken) {
      //   localStorage.setItem("refreshToken", response.refreshToken);
      // }

      // 토큰 디코딩하여 사용자 정보 추출
      const decoded = jwtDecode<DecodedToken>(accessToken);
      setUser({
        id: decoded.sub,
        username: decoded.sub,
        email: decoded.email,
        roles: decoded.roles,
      });
    } catch (error) {
      console.error("로그인 실패:", error);
      throw error;
    }
  };

  const logout = () => {
    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
    setUser(null);
  };

  const getAccessToken = (): string | null => {
    return localStorage.getItem("accessToken");
  };

  const value: AuthContextType = {
    user,
    accessToken,
    isAuthenticated: !!user,
    isLoading,
    login,
    logout,
    getAccessToken,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
