import { Stack } from 'expo-router';

export default function AuthLayout() {
  return (
    <Stack
      screenOptions={{
        headerShown: false,
        animation: 'slide_from_right',
      }}
    >
      <Stack.Screen name="onboarding" />
      <Stack.Screen name="welcome" />
      <Stack.Screen name="login" />
      <Stack.Screen name="Register" />
      <Stack.Screen name="email-verification" />
      <Stack.Screen name="profile-setup" />
      <Stack.Screen name="preferences" />
      <Stack.Screen name="location" />
    </Stack>
  );
}