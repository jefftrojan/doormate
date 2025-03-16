import { useEffect } from 'react';
import { View, Image, StyleSheet } from 'react-native';
import { Redirect } from 'expo-router';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useAuth } from '../contexts/AuthContext';

export default function SplashScreen() {
  const { isAuthenticated, user } = useAuth();

  useEffect(() => {
    // Add a delay to show the splash screen
    const initializeApp = async () => {
      await new Promise(resolve => setTimeout(resolve, 2000));
    };
    initializeApp();
  }, []);

  return (
    <View style={styles.container}>
      <Image
        source={require('@/assets/images/splash-icon.png')}
        style={styles.logo}
        resizeMode="contain"
      />
      <Redirect href={isAuthenticated ? "/(tabs)" : "/(auth)/onboarding"} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
  logo: {
    width: 200,
    height: 200,
  },
});