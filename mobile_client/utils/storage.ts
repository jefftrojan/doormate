import * as SecureStore from 'expo-secure-store';

export const storage = {
  async setToken(token: string): Promise<void> {
    await SecureStore.setItemAsync('auth_token', token);
  },

  async getToken(): Promise<string | null> {
    return await SecureStore.getItemAsync('auth_token');
  },

  async removeToken(): Promise<void> {
    await SecureStore.deleteItemAsync('auth_token');
  }
};