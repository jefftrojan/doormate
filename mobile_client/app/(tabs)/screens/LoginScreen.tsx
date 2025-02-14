import { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Image,
  ScrollView,
  Platform,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';

export default function LoginScreen({ navigation }) {
  return (
    <SafeAreaView style={styles.container} edges={['top']}>
      <StatusBar style="dark" />
      <ScrollView 
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.header}>
          <Image
            source={require('../assets/doormate-logo.png')}
            style={styles.logo}
            resizeMode="contain"
          />
          <Text style={styles.title}>DoorMate</Text>
        </View>

        <View style={styles.content}>
          <Text style={styles.heading}>Find Your Perfect Roommate</Text>
          <Text style={styles.subtitle}>
            Join the trusted community of student roommates in Rwanda
          </Text>

          <TouchableOpacity 
            style={styles.emailButton}
            onPress={() => navigation.navigate('ProfileSetup')}
            activeOpacity={0.8}
          >
            <Text style={styles.emailButtonText}>Sign Up with School Email</Text>
          </TouchableOpacity>

          <TouchableOpacity 
            style={styles.googleButton}
            activeOpacity={0.8}
          >
            <Image
              source={require('../assets/google-icon.png')}
              style={styles.googleIcon}
              resizeMode="contain"
            />
            <Text style={styles.googleButtonText}>Continue with Google</Text>
          </TouchableOpacity>

          <TouchableOpacity 
            style={styles.loginLink}
            activeOpacity={0.6}
          >
            <Text style={styles.loginText}>
              Already have an account? <Text style={styles.loginHighlight}>Log in</Text>
            </Text>
          </TouchableOpacity>
        </View>

        <View style={styles.testimonials}>
          <View style={styles.testimonialCard}>
            <Image
              source={{ uri: 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Frame-h50yH1v0BjJF7nZ1DRnSDHVGNfzepA.png' }}
              style={styles.testimonialAvatar}
            />
            <View style={styles.testimonialContent}>
              <Text style={styles.testimonialName}>Sarah K.</Text>
              <Text style={styles.testimonialSchool}>
                Kigali Institute of Technology
              </Text>
              <Text style={styles.testimonialText}>
                "Found my ideal roommate through DoorMate. The process was smooth and secure!"
              </Text>
            </View>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  scrollContent: {
    flexGrow: 1,
    padding: 20,
  },
  header: {
    alignItems: 'center',
    marginTop: Platform.OS === 'ios' ? 20 : 40,
  },
  logo: {
    width: 40,
    height: 40,
  },
  title: {
    fontSize: 20,
    fontWeight: '600',
    marginTop: 8,
    fontFamily: Platform.OS === 'ios' ? 'System' : 'Roboto',
  },
  content: {
    marginTop: 40,
    alignItems: 'center',
  },
  heading: {
    fontSize: 28,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 12,
    fontFamily: Platform.OS === 'ios' ? 'System' : 'Roboto',
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 32,
  },
  emailButton: {
    backgroundColor: '#1a2b3c',
    width: '100%',
    padding: 16,
    borderRadius: 12,
    marginBottom: 12,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
      },
      android: {
        elevation: 3,
      },
    }),
  },
  emailButtonText: {
    color: '#fff',
    textAlign: 'center',
    fontSize: 16,
    fontWeight: '600',
  },
  googleButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#fff',
    width: '100%',
    padding: 16,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  googleIcon: {
    width: 20,
    height: 20,
    marginRight: 8,
  },
  googleButtonText: {
    fontSize: 16,
    fontWeight: '600',
  },
  loginLink: {
    marginTop: 24,
    padding: 8,
  },
  loginText: {
    fontSize: 14,
    color: '#666',
  },
  loginHighlight: {
    color: '#1a2b3c',
    fontWeight: '600',
  },
  testimonials: {
    marginTop: 40,
  },
  testimonialCard: {
    flexDirection: 'row',
    padding: 16,
    backgroundColor: '#f8f9fa',
    borderRadius: 12,
    marginBottom: 12,
  },
  testimonialAvatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    marginRight: 12,
  },
  testimonialContent: {
    flex: 1,
  },
  testimonialName: {
    fontSize: 14,
    fontWeight: '600',
  },
  testimonialSchool: {
    fontSize: 12,
    color: '#666',
    marginBottom: 4,
  },
  testimonialText: {
    fontSize: 14,
    color: '#444',
  },
});