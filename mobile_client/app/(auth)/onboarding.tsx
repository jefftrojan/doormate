import React, { useState } from 'react';
import { View, Text, Image, StyleSheet, Dimensions } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { TouchableOpacity } from 'react-native-gesture-handler';
import { router } from 'expo-router';
import AsyncStorage from '@react-native-async-storage/async-storage';

const ONBOARDING_SCREENS = [
  {
    title: 'Find Your Perfect Match',
    description: 'Connect with compatible roommates based on your lifestyle and preferences',
    image: require('@/assets/images/splash-icon.png')
  },
  {
    title: 'Verified Students Only',
    description: 'Join a trusted community of verified university students',
    image: require('@/assets/images/id-example.png')
  },
  {
    title: 'Safe and Secure',
    description: 'Your safety is our priority with verified profiles and secure messaging',
    image: require('@/assets/images/avatar.png')
  }
];

export default function OnboardingScreen() {
  const [currentScreen, setCurrentScreen] = useState(0);

  const handleNext = async () => {
    if (currentScreen < ONBOARDING_SCREENS.length - 1) {
      setCurrentScreen(currentScreen + 1);
    } else {
      await AsyncStorage.setItem('@onboarding_complete', 'true');
      router.replace('/(auth)/welcome');
    }
  };

  const handleSkip = async () => {
    await AsyncStorage.setItem('@onboarding_complete', 'true');
    router.replace('/(auth)/welcome');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.skipContainer}>
        <TouchableOpacity onPress={handleSkip}>
          <Text style={styles.skipText}>Skip</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.content}>
        <Image
          source={ONBOARDING_SCREENS[currentScreen].image}
          style={styles.image}
          resizeMode="contain"
        />
        <Text style={styles.title}>{ONBOARDING_SCREENS[currentScreen].title}</Text>
        <Text style={styles.description}>
          {ONBOARDING_SCREENS[currentScreen].description}
        </Text>
      </View>

      <View style={styles.footer}>
        <View style={styles.indicators}>
          {ONBOARDING_SCREENS.map((_, index) => (
            <View
              key={index}
              style={[
                styles.indicator,
                index === currentScreen && styles.activeIndicator,
              ]}
            />
          ))}
        </View>

        <TouchableOpacity style={styles.button} onPress={handleNext}>
          <Text style={styles.buttonText}>
            {currentScreen === ONBOARDING_SCREENS.length - 1 ? 'Get Started' : 'Next'}
          </Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  skipContainer: {
    alignItems: 'flex-end',
    padding: 16,
  },
  skipText: {
    color: '#666',
    fontSize: 16,
  },
  content: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  image: {
    width: Dimensions.get('window').width * 0.8,
    height: Dimensions.get('window').width * 0.8,
    marginBottom: 40,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
  },
  description: {
    fontSize: 16,
    textAlign: 'center',
    color: '#666',
    paddingHorizontal: 20,
  },
  footer: {
    padding: 20,
  },
  indicators: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginBottom: 20,
  },
  indicator: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#ddd',
    marginHorizontal: 4,
  },
  activeIndicator: {
    backgroundColor: '#8B4513',
    width: 20,
  },
  button: {
    backgroundColor: '#8B4513',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '600',
  },
});