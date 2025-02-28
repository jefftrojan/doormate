import axios from 'axios'
import AsyncStorage from '@react-native-async-storage/async-storage';;

const API_URL = 'http://localhost:8001/api';

export interface AuthResponse {
  token: string;
  user: {
    _id: string;
    email: string;
    fullName: string;
    university: string;
    yearOfStudy: string;
    studentId: string;
    verified: boolean;
  };
}

export interface RegisterData {
  email: string;
  password: string;
  fullName: string;
  university: string;
  yearOfStudy: string;
  studentId: string;
}
axios.interceptors.request.use(
  async (config) => {
    const token = await AsyncStorage.getItem('@auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Add response interceptor to handle token expiration
axios.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      await AsyncStorage.removeItem('@auth_token');
      // Redirect to login screen or handle token expiration
    }
    return Promise.reject(error);
  }
);
export const authService = {
  async register(userData: RegisterData): Promise<{ success: boolean; email: string }> {
    const response = await axios.post(`${API_URL}/auth/register`, userData);
    return response.data;
  },
  async checkAuthStatus(): Promise<boolean> {
    try {
      const token = await AsyncStorage.getItem('@auth_token');
      if (!token) return false;
      
      const response = await axios.get(`${API_URL}/auth/verify-token`);
      return response.data.isValid;
    } catch (error) {
      return false;
    }
  },

  async refreshToken(): Promise<string | null> {
    try {
      const response = await axios.post(`${API_URL}/auth/refresh-token`);
      const newToken = response.data.token;
      await AsyncStorage.setItem('@auth_token', newToken);
      return newToken;
    } catch (error) {
      return null;
    }
  },

  async verifyOTP(email: string, otp: string): Promise<AuthResponse> {
    try {
        const response = await axios.post(`${API_URL}/auth/verify`, { email, otp });
        return response.data;
    } catch (error: any) {
        const message = error.response?.data?.detail || 'OTP verification failed';
        throw new Error(message);
    }
},

  async login(email: string, password: string): Promise<AuthResponse> {
    const response = await axios.post(`${API_URL}/auth/login`, { email, password });
    return response.data;
  },

  async regenerateOTP(email: string): Promise<{ success: boolean }> {
    const response = await axios.post(`${API_URL}/auth/regenerate-otp`, { email });
    return response.data;
  },

  async sendVerificationEmail(email: string): Promise<{ success: boolean }> {
    const response = await axios.post(`${API_URL}/auth/verify-email`, { email });
    return response.data;
  },

  async updateProfile(userId: string, profileData: any): Promise<{ success: boolean }> {
    const response = await axios.put(`${API_URL}/auth/profile/${userId}`, profileData);
    return response.data;
  },

  async updatePreferences(userId: string, preferences: any): Promise<{ success: boolean }> {
    const response = await axios.put(`${API_URL}/auth/preferences/${userId}`, preferences);
    return response.data;
  },

  async getUserPreferences(userId: string) {
    const response = await axios.get(`${API_URL}/auth/preferences/${userId}`);
    return response.data;
  },

  async updateLocation(locationData: {
    userId: string;
    latitude: number;
    longitude: number;
    preferredArea: string;
  }) {
    const response = await axios.post(`${API_URL}/users/${locationData.userId}/location`, locationData);
    return response.data;
  },

  async signInWithGoogle(): Promise<AuthResponse> {
    try {
      // Implement actual Google Sign-In logic here
      throw new Error('Google sign in is not available at the moment');
    } catch (error: any) {
      throw error;
    }
  },

  async signOut(): Promise<void> {
    // Simplified sign out without Firebase
    return Promise.resolve();
  },
  async uploadStudentId(formData: FormData) {
    const response = await axios.post(`${API_URL}/auth/upload-student-id`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  async uploadImage(formData: FormData) {
    const response = await axios.post(`${API_URL}/auth/upload-image`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  }
};