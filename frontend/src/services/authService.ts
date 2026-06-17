import api from '../lib/axios';

export interface RegisterResponse {
  email: string;
  devOtp?: string | null;
}

export interface VerifyEmailOtpRequest {
  email: string;
  otpCode: string;
}

export interface ResendEmailVerificationRequest {
  email: string;
}

export interface RegisterRequest {
  fullName: string;
  email: string;
  password: string;
  phoneNumber?: string;
  identifyNumber?: string;
  gender?: string;
  address?: string;
  dateOfBirth?: string;
}

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  userId: string;
  email: string;
  fullName: string;
}

export interface ServiceResponse<T> {
  isSuccess: boolean;
  message: string;
  data: T;
  errors?: string[];
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RefreshTokenRequest {
  refreshToken: string;
}

export interface ForgotPasswordRequest {
  email: string;
}

export interface ForgotPasswordResponse {
  resetToken: string | null;
}

export interface ResetPasswordRequest {
  email: string;
  resetToken: string;
  newPassword: string;
}

export interface ChangePasswordRequest {
  currentPassword: string;
  newPassword: string;
}

export const authService = {
  async register(data: RegisterRequest): Promise<ServiceResponse<RegisterResponse>> {
    const response = await api.post<ServiceResponse<RegisterResponse>>('/auth/register', data);
    return response.data;
  },

  async verifyEmailOtp(data: VerifyEmailOtpRequest): Promise<ServiceResponse<AuthResponse>> {
    const response = await api.post<ServiceResponse<AuthResponse>>('/auth/verify-email-otp', data);
    return response.data;
  },

  async resendVerificationOtp(
    data: ResendEmailVerificationRequest,
  ): Promise<ServiceResponse<RegisterResponse>> {
    const response = await api.post<ServiceResponse<RegisterResponse>>(
      '/auth/resend-verification-otp',
      data,
    );
    return response.data;
  },

  async login(data: LoginRequest): Promise<ServiceResponse<AuthResponse>> {
    const response = await api.post<ServiceResponse<AuthResponse>>('/auth/login', data);
    return response.data;
  },

  async loginGoogle(idToken: string): Promise<ServiceResponse<AuthResponse>> {
    const response = await api.post<ServiceResponse<AuthResponse>>('/auth/login-google', { idToken });
    return response.data;
  },

  async refreshToken(data: RefreshTokenRequest): Promise<ServiceResponse<AuthResponse>> {
    const response = await api.post<ServiceResponse<AuthResponse>>('/auth/refresh-token', data);
    return response.data;
  },

  async forgotPassword(data: ForgotPasswordRequest): Promise<ServiceResponse<ForgotPasswordResponse>> {
    const response = await api.post<ServiceResponse<ForgotPasswordResponse>>('/auth/forgot-password', data);
    return response.data;
  },

  async resetPassword(data: ResetPasswordRequest): Promise<ServiceResponse<boolean>> {
    const response = await api.post<ServiceResponse<boolean>>('/auth/reset-password', data);
    return response.data;
  },

  async changePassword(data: ChangePasswordRequest): Promise<ServiceResponse<boolean>> {
    const response = await api.post<ServiceResponse<boolean>>('/auth/change-password', data);
    return response.data;
  },

  async logout(refreshToken: string): Promise<ServiceResponse<boolean>> {
    const response = await api.post<ServiceResponse<boolean>>('/auth/logout', { refreshToken });
    return response.data;
  }
};
