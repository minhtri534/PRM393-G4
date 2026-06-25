import axios, { 
  type InternalAxiosRequestConfig, 
  type AxiosResponse, 
  AxiosError, 
  type AxiosInstance 
} from 'axios';
import { authService } from '../services/authService';

// Định nghĩa kiểu cho hàng đợi request chờ refresh token
interface FailedRequest {
  resolve: (token: string | null) => void;
  reject: (error: any) => void;
}

// Get API base URL from environment or use default
const getApiBaseUrl = (): string => {
  if (typeof window !== 'undefined') {
    // Check window config (injected at runtime)
    const windowConfig = (window as any).__APP_CONFIG__;
    if (windowConfig?.API_URL) return windowConfig.API_URL;
  }
  // Use env variable or default to localhost
  return import.meta.env.VITE_API_URL || 'http://localhost:5000/api';
};

const api: AxiosInstance = axios.create({
  baseURL: getApiBaseUrl(),
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: true,
});

let isRefreshing = false;
let failedQueue: FailedRequest[] = [];

const processQueue = (error: any | null, token: string | null = null) => {
  failedQueue.forEach((prom) => {
    if (error) {
      prom.reject(error);
    } else {
      prom.resolve(token);
    }
  });
  failedQueue = [];
};

// Request Interceptor
api.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = localStorage.getItem('accessToken');
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    // Let the browser set multipart boundary for file uploads.
    if (config.data instanceof FormData && config.headers) {
      delete config.headers['Content-Type'];
    }
    return config;
  },
  (error: AxiosError) => Promise.reject(error)
);

// Response Interceptor
api.interceptors.response.use(
  (response: AxiosResponse) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };

    // Only attempt token refresh for non-auth endpoints with 401
    // Auth endpoints (login, register, etc.) return 401 for invalid credentials, not token expiry
    const isAuthEndpoint = originalRequest.url?.includes('/auth/');
    if (error.response?.status === 401 && !isAuthEndpoint) {
      if (originalRequest._retry) {
        return Promise.reject(error);
      }

      if (isRefreshing) {
        return new Promise<string | null>((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        })
          .then((token) => {
            if (originalRequest.headers) {
              originalRequest.headers.Authorization = `Bearer ${token}`;
            }
            return api(originalRequest);
          })
          .catch((err) => Promise.reject(err));
      }

      originalRequest._retry = true;
      isRefreshing = true;

      const refreshToken = localStorage.getItem('refreshToken');
      if (!refreshToken) {
        localStorage.clear();
        window.location.href = '/login';
        return Promise.reject(error);
      }

      try {
        const rs = await authService.refreshToken({ refreshToken });
        if (rs.isSuccess && rs.data) {
          const { accessToken, refreshToken: newRefreshToken } = rs.data;
          
          localStorage.setItem('accessToken', accessToken);
          localStorage.setItem('refreshToken', newRefreshToken);
          
          api.defaults.headers.common.Authorization = `Bearer ${accessToken}`;
          processQueue(null, accessToken);
          
          return api(originalRequest);
        } else {
          throw new Error('Refresh session failed');
        }
      } catch (refreshError) {
        localStorage.clear();
        window.location.href = '/login';
        processQueue(refreshError);
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }

    return Promise.reject(error);
  }
);

export default api;