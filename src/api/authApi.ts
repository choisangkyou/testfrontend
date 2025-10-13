import { api } from "./axiosConfig";

import { LoginRequest, LoginResponse, ApiResponse } from "../types/auth.types";

// export const login = async (credentials: LoginRequest): Promise<LoginResponse> => {
//     const response = await api.post<LoginResponse>('/auth/login', credentials);
//     return response.data;
// };

// export const logout = async (): Promise<void> => {
//     await api.post('/auth/logout');
// };

// export const refreshToken = async (refreshToken: string): Promise<LoginResponse> => {
//     const response = await api.post<LoginResponse>('/auth/refresh', { refreshToken });
//     return response.data;
// };

// 로그인 API
export const loginApi = async <T = ApiResponse<LoginResponse>>(
  credentials: LoginRequest
): Promise<T> => {
  try {
    const response = await api.post<T>(`/auth/login`, credentials, {
      headers: {
        "Content-Type": "application/json",
      },
    });

    return response.data;
  } catch (error) {
    console.error("Login API Error:", error);
    throw error;
  }
};

// 토큰 갱신 API
export const refreshTokenApi = async (
  refreshToken: string
): Promise<ApiResponse<LoginResponse>> => {
  try {
    const response = await api.post<ApiResponse<LoginResponse>>(
      `/auth/refresh`,
      {},
      {
        headers: {
          Authorization: `Bearer ${refreshToken}`,
        },
      }
    );

    return response.data;
  } catch (error) {
    console.error("Refresh Token API Error:", error);
    throw error;
  }
};

// 로그아웃 API (선택사항)
export const logoutApi = async (): Promise<ApiResponse<null>> => {
  try {
    const token = localStorage.getItem("accessToken");
    const response = await api.post<ApiResponse<null>>(
      `/auth/logout`,
      {},
      {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      }
    );

    return response.data;
  } catch (error) {
    console.error("Logout API Error:", error);
    throw error;
  }
};
