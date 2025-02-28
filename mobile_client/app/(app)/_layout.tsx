import { Tabs } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { AuthGuard } from '@/components/AuthGuard';
import { Slot } from 'expo-router';

export default function AppLayout() {
  return (
    <AuthGuard>
      <Slot />
    </AuthGuard>
  );
}