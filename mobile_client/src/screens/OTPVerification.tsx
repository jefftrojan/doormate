import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useAuth } from '@/contexts/AuthContext';

export default function OTPVerification({ route, navigation }: any) {
  const { email } = route.params;
  const { verifyOTP, regenerateOTP, loading } = useAuth();
  const [otp, setOtp] = useState('');
  const [countdown, setCountdown] = useState(60);

  useEffect(() => {
    const timer = countdown > 0 && setInterval(() => setCountdown(prev => prev - 1), 1000);
    return () => {
      if (timer) clearInterval(timer);
    };
  }, [countdown]);

  const handleVerifyOTP = async () => {
    if (!otp) {
      Alert.alert('Error', 'Please enter the OTP');
      return;
    }

    try {
      const response = await verifyOTP(email, otp);
      if (response.token) {
        navigation.replace('MainApp');
      }
    } catch (error: any) {
      Alert.alert('Verification Failed', error.message);
    }
  };

  const handleResendOTP = async () => {
    if (countdown > 0) return;

    try {
      await regenerateOTP(email);
      setCountdown(60);
      Alert.alert('Success', 'New OTP has been sent to your email');
    } catch (error: any) {
      Alert.alert('Failed', error.message);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Verify Your Email</Text>
        <Text style={styles.subtitle}>
          Please enter the verification code sent to {email}
        </Text>

        <TextInput
          style={styles.otpInput}
          placeholder="Enter OTP"
          value={otp}
          onChangeText={setOtp}
          keyboardType="numeric"
          maxLength={6}
        />

        <TouchableOpacity
          style={[styles.button, loading && styles.buttonDisabled]}
          onPress={handleVerifyOTP}
          disabled={loading}
        >
          {loading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.buttonText}>Verify OTP</Text>
          )}
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.resendButton, countdown > 0 && styles.resendButtonDisabled]}
          onPress={handleResendOTP}
          disabled={countdown > 0}
        >
          <Text style={[styles.resendText, countdown > 0 && styles.resendTextDisabled]}>
            {countdown > 0 ? `Resend OTP in ${countdown}s` : 'Resend OTP'}
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
  content: {
    padding: 20,
    alignItems: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 10,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 30,
  },
  otpInput: {
    borderWidth: 1,
    borderColor: '#ddd',
    padding: 15,
    borderRadius: 10,
    width: '100%',
    fontSize: 18,
    textAlign: 'center',
    marginBottom: 20,
  },
  button: {
    backgroundColor: '#91604B',
    padding: 15,
    borderRadius: 10,
    width: '100%',
    alignItems: 'center',
  },
  buttonDisabled: {
    opacity: 0.7,
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '600',
  },
  resendButton: {
    marginTop: 20,
    padding: 10,
  },
  resendButtonDisabled: {
    opacity: 0.7,
  },
  resendText: {
    color: '#91604B',
    fontSize: 16,
  },
  resendTextDisabled: {
    color: '#666',
  },
});