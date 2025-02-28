import React, { useState } from 'react';
import { View, StyleSheet, TextInput } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { Button, Input } from 'react-native-elements';
import { ThemedView } from '@/components/ThemedView';
import { ThemedText } from '@/components/ThemedText';
import { useAuth } from '@/contexts/AuthContext';
import { authService } from '@/services/auth';
import { storage } from '@/utils/storage';
import { isValidUniversityEmail } from '@/utils/validation';

export default function EmailVerification() {
  const { verifyOTP } = useAuth(); // Remove unused authState and updateEmailVerification
  const [isLoading, setIsLoading] = useState(false);
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState(['', '', '', '', '', '']);
  const [error, setError] = useState('');
  const [isVerifying, setIsVerifying] = useState(false);
  
  const otpRefs = Array(6).fill(0).map(() => React.createRef<TextInput>());

  const handleOtpChange = (value: string, index: number) => {
    if (value.length <= 1) {
      const newOtp = [...otp];
      newOtp[index] = value;
      setOtp(newOtp);

      // Move to next input if value is entered
      if (value !== '' && index < 5) {
        otpRefs[index + 1].current?.focus();
      }
    }
  };

  const handleEmailSubmit = async () => {
    if (!isValidUniversityEmail(email)) {
      setError('Please use a valid university email address (e.g., @student.ac.rw or @alustudent.com)');
      return;
    }

    try {
      setIsLoading(true);
      const response = await authService.sendVerificationEmail(email);
      if (response.success) {
        setIsVerifying(true);
      }
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to send verification code');
    } finally {
      setIsLoading(false);
    }
  };

  const handleVerifyOtp = async () => {
    const otpString = otp.join('');
    if (otpString.length !== 6) {
      setError('Please enter the complete verification code');
      return;
    }

    try {
      setIsLoading(true);
      const response = await verifyOTP(email, otpString);
      await storage.setToken(response.token);
      router.push('/(auth)/profile-setup'); // Update the navigation path
    } catch (err: any) {
      setError(err.response?.data?.message || 'Invalid verification code');
    } finally {
      setIsLoading(false);
    }
  };

  // Update the button components to show loading state
  return (
    <SafeAreaView style={styles.container}>
      <ThemedView style={styles.content}>
        <Button
          icon={{ name: 'arrow-back', type: 'ionicon', color: '#000' }}
          type="clear"
          onPress={() => router.back()}
          containerStyle={styles.backButton}
        />

        <ThemedText style={styles.stepText}>Step 1 of 4</ThemedText>
        <ThemedText style={styles.title}>Verify your email</ThemedText>
        <ThemedText style={styles.subtitle}>
          Please enter your university email address ending with .ac.rw
        </ThemedText>

        {!isVerifying ? (
          <>
            <Input
              placeholder="university@student.ac.rw"
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoCapitalize="none"
              errorMessage={error}
              containerStyle={styles.inputContainer}
            />
            <Button
              title={isLoading ? "Please wait..." : "Send Verification Code"}
              onPress={handleEmailSubmit}
              containerStyle={styles.buttonContainer}
              buttonStyle={styles.button}
              disabled={isLoading}
            />
          </>
        ) : (
          <>
            <ThemedText style={styles.verificationText}>
              Enter the 6-digit code sent to {email}
            </ThemedText>
            <View style={styles.otpContainer}>
              {otp.map((digit, index) => (
                <TextInput
                  key={index}
                  ref={otpRefs[index]}
                  style={styles.otpInput}
                  value={digit}
                  onChangeText={(value) => handleOtpChange(value, index)}
                  keyboardType="number-pad"
                  maxLength={1}
                />
              ))}
            </View>
            {error ? <ThemedText style={styles.errorText}>{error}</ThemedText> : null}
            <Button
              title="Verify"
              onPress={handleVerifyOtp}
              containerStyle={styles.buttonContainer}
              buttonStyle={styles.button}
            />
          </>
        )}
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
  stepText: {
    fontSize: 16,
    marginBottom: 8,
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
  verificationText: {
    fontSize: 16,
    marginBottom: 20,
  },
  otpContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 24,
  },
  otpInput: {
    width: 45,
    height: 45,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    textAlign: 'center',
    fontSize: 20,
  },
  errorText: {
    color: 'red',
    marginBottom: 16,
  },
});