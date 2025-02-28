import React, { useState } from 'react';
import { View, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { Button, Input } from 'react-native-elements';
import { ThemedView } from '@/components/ThemedView';
import { ThemedText } from '@/components/ThemedText';
import { authService } from '@/services/auth';

export default function ForgotPassword() {
  const [email, setEmail] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async () => {
    if (!email) {
      setError('Please enter your email address');
      return;
    }

    try {
      setIsLoading(true);
      await authService.sendVerificationEmail(email);
      router.push({
        pathname: '/(auth)/email-verification',
        params: { email }
      });
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to send reset email');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <ThemedView style={styles.content}>
        <Button
          icon={{ name: 'arrow-back', type: 'ionicon', color: '#000' }}
          type="clear"
          onPress={() => router.back()}
          containerStyle={styles.backButton}
        />

        <ThemedText style={styles.title}>Reset Password</ThemedText>
        <ThemedText style={styles.subtitle}>
          Enter your email address and we'll send you instructions to reset your password.
        </ThemedText>

        <Input
          placeholder="Email address"
          value={email}
          onChangeText={setEmail}
          keyboardType="email-address"
          autoCapitalize="none"
          errorMessage={error}
          containerStyle={styles.inputContainer}
        />

        <Button
          title={isLoading ? "Sending..." : "Send Reset Link"}
          onPress={handleSubmit}
          containerStyle={styles.buttonContainer}
          buttonStyle={styles.button}
          disabled={isLoading}
        />
      </ThemedView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    flex: 1,
    padding: 20,
  },
  backButton: {
    alignSelf: 'flex-start',
    marginBottom: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  subtitle: {
    fontSize: 16,
    opacity: 0.7,
    marginBottom: 24,
  },
  inputContainer: {
    marginBottom: 20,
  },
  buttonContainer: {
    width: '100%',
  },
  button: {
    backgroundColor: '#1a2b3c',
    padding: 15,
    borderRadius: 8,
  },
});