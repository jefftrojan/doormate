import React, { useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'expo-router';
import { ActivityIndicator, View } from 'react-native';

export const AuthGuard = ({ children }: { children: React.ReactNode }) => {
  const { isAuthenticated, loading, checkAuth } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && !isAuthenticated) {
      router.replace('/login');
    }
  }, [isAuthenticated, loading]);

  if (loading) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <ActivityIndicator size="large" color="#8B4513" />
      </View>
    );
  }

  return isAuthenticated ? <>{children}</> : null;
};