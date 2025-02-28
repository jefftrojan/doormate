import { Redirect } from 'expo-router';
import { useAuth } from '@/contexts/AuthContext';

export default function Index() {
  const { isAuthenticated } = useAuth();
  
  return <Redirect href={isAuthenticated ? "/(tabs)" : "/(auth)/welcome"} />;
}