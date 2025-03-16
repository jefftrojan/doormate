import React, { useState } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  TextInput, 
  TouchableOpacity, 
  Alert,
  ActivityIndicator,
  Image,
  ScrollView,
  Platform
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';
import { useAuth } from '@/contexts/AuthContext';
import api from '@/services/api';

export default function ProfileSetup() {
  const { user, updateUser, setProfileCompleted } = useAuth();
  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [profile, setProfile] = useState({
    fullName: user?.fullName || '',
    dateOfBirth: '',
    gender: '',
    university: '',
    yearOfStudy: '',
    studentId: '',
    profilePhoto: ''
  });

  const handleProfileUpdate = (field: string, value: string) => {
    setProfile(prev => ({ ...prev, [field]: value }));
    // Clear error for this field if it exists
    if (errors[field]) {
      setErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[field];
        return newErrors;
      });
    }
  };

  const validateForm = () => {
    const newErrors: Record<string, string> = {};
    
    if (!profile.fullName.trim()) {
      newErrors.fullName = 'Full name is required';
    }
    if (!profile.dateOfBirth) {
      newErrors.dateOfBirth = 'Date of birth is required';
    }
    if (!profile.gender) {
      newErrors.gender = 'Gender is required';
    }
    if (!profile.university) {
      newErrors.university = 'University is required';
    }
    if (!profile.yearOfStudy) {
      newErrors.yearOfStudy = 'Year of study is required';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleProfilePhotoUpload = async () => {
    try {
      // Request permission
      const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
      
      if (status !== 'granted') {
        Alert.alert('Permission Denied', 'We need camera roll permission to upload your profile photo');
        return;
      }
      
      // Launch image picker
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.5,
      });
      
      if (!result.canceled) {
        // Update profile with selected image
        setProfile(prev => ({ ...prev, profilePhoto: result.assets[0].uri }));
      }
    } catch (error) {
      console.error('Error picking image:', error);
      Alert.alert('Error', 'Failed to pick image');
    }
  };

  const handleNext = async () => {
    if (!validateForm()) {
      return;
    }

    try {
      setIsLoading(true);
      
      // Create form data for image upload
      const formData = new FormData();
      
      // Add profile photo if available
      if (profile.profilePhoto) {
        const filename = profile.profilePhoto.split('/').pop() || 'profile.jpg';
        const match = /\.(\w+)$/.exec(filename);
        const type = match ? `image/${match[1]}` : 'image/jpeg';
        
        formData.append('profilePhoto', {
          uri: profile.profilePhoto,
          name: filename,
          type,
        } as any);
      }
      
      // Add other profile data
      Object.keys(profile).forEach(key => {
        if (key !== 'profilePhoto') {
          formData.append(key, profile[key as keyof typeof profile]);
        }
      });
      
      // Update profile on server
      const response = await api.post('/api/profile/update', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      
      if (response.data.success) {
        // Update local user data
        updateUser({
          ...profile,
          profileCompleted: true
        });
        
        // Mark profile as completed
        setProfileCompleted(true);
        
        // Navigate to preferences screen
        router.push('/(auth)/preferences');
      }
    } catch (error: any) {
      console.error('Profile update error:', error);
      Alert.alert(
        'Update Failed', 
        error.response?.data?.message || 'Failed to update profile'
      );
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity 
          style={styles.backButton}
          onPress={() => router.back()}
        >
          <Ionicons name="arrow-back" size={24} color="#000" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Complete Your Profile</Text>
        <View style={{ width: 24 }} />
      </View>
      
      <ScrollView 
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <TouchableOpacity 
          style={styles.photoContainer}
          onPress={handleProfilePhotoUpload}
        >
          {profile.profilePhoto ? (
            <Image 
              source={{ uri: profile.profilePhoto }} 
              style={styles.profilePhoto} 
            />
          ) : (
            <View style={styles.photoPlaceholder}>
              <Ionicons name="camera" size={32} color="#666" />
              <Text style={styles.photoText}>Add Photo</Text>
            </View>
          )}
        </TouchableOpacity>
        
        <View style={styles.form}>
          <View style={styles.inputContainer}>
            <Text style={styles.label}>Full Name</Text>
            <TextInput
              style={[styles.input, errors.fullName && styles.inputError]}
              placeholder="Enter your full name"
              value={profile.fullName}
              onChangeText={(text) => handleProfileUpdate('fullName', text)}
            />
            {errors.fullName && <Text style={styles.errorText}>{errors.fullName}</Text>}
          </View>
          
          <View style={styles.inputContainer}>
            <Text style={styles.label}>Date of Birth</Text>
            <TextInput
              style={[styles.input, errors.dateOfBirth && styles.inputError]}
              placeholder="YYYY-MM-DD"
              value={profile.dateOfBirth}
              onChangeText={(text) => handleProfileUpdate('dateOfBirth', text)}
            />
            {errors.dateOfBirth && <Text style={styles.errorText}>{errors.dateOfBirth}</Text>}
          </View>
          
          <View style={styles.inputContainer}>
            <Text style={styles.label}>Gender</Text>
            <View style={styles.genderOptions}>
              <TouchableOpacity 
                style={[
                  styles.genderOption, 
                  profile.gender === 'Male' && styles.genderOptionSelected
                ]}
                onPress={() => handleProfileUpdate('gender', 'Male')}
              >
                <Text style={[
                  styles.genderOptionText,
                  profile.gender === 'Male' && styles.genderOptionTextSelected
                ]}>Male</Text>
              </TouchableOpacity>
              
              <TouchableOpacity 
                style={[
                  styles.genderOption, 
                  profile.gender === 'Female' && styles.genderOptionSelected
                ]}
                onPress={() => handleProfileUpdate('gender', 'Female')}
              >
                <Text style={[
                  styles.genderOptionText,
                  profile.gender === 'Female' && styles.genderOptionTextSelected
                ]}>Female</Text>
              </TouchableOpacity>
              
              <TouchableOpacity 
                style={[
                  styles.genderOption, 
                  profile.gender === 'Other' && styles.genderOptionSelected
                ]}
                onPress={() => handleProfileUpdate('gender', 'Other')}
              >
                <Text style={[
                  styles.genderOptionText,
                  profile.gender === 'Other' && styles.genderOptionTextSelected
                ]}>Other</Text>
              </TouchableOpacity>
            </View>
            {errors.gender && <Text style={styles.errorText}>{errors.gender}</Text>}
          </View>
          
          <View style={styles.inputContainer}>
            <Text style={styles.label}>University</Text>
            <TextInput
              style={[styles.input, errors.university && styles.inputError]}
              placeholder="Enter your university"
              value={profile.university}
              onChangeText={(text) => handleProfileUpdate('university', text)}
            />
            {errors.university && <Text style={styles.errorText}>{errors.university}</Text>}
          </View>
          
          <View style={styles.inputContainer}>
            <Text style={styles.label}>Year of Study</Text>
            <TextInput
              style={[styles.input, errors.yearOfStudy && styles.inputError]}
              placeholder="Enter your year of study"
              value={profile.yearOfStudy}
              onChangeText={(text) => handleProfileUpdate('yearOfStudy', text)}
              keyboardType="number-pad"
            />
            {errors.yearOfStudy && <Text style={styles.errorText}>{errors.yearOfStudy}</Text>}
          </View>
          
          <TouchableOpacity 
            style={styles.button}
            onPress={handleNext}
            disabled={isLoading}
          >
            {isLoading ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.buttonText}>Continue</Text>
            )}
          </TouchableOpacity>
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
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  backButton: {
    padding: 8,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    padding: 24,
    paddingBottom: 40,
  },
  photoContainer: {
    alignSelf: 'center',
    marginBottom: 32,
  },
  profilePhoto: {
    width: 120,
    height: 120,
    borderRadius: 60,
  },
  photoPlaceholder: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: '#F3F4F6',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#E2E8F0',
    borderStyle: 'dashed',
  },
  photoText: {
    marginTop: 8,
    fontSize: 14,
    color: '#666',
  },
  form: {
    width: '100%',
  },
  inputContainer: {
    marginBottom: 20,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    marginBottom: 8,
    color: '#333',
  },
  input: {
    borderWidth: 1,
    borderColor: '#E2E8F0',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
  },
  inputError: {
    borderColor: '#E53E3E',
  },
  errorText: {
    color: '#E53E3E',
    fontSize: 12,
    marginTop: 4,
  },
  genderOptions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  genderOption: {
    flex: 1,
    padding: 12,
    borderWidth: 1,
    borderColor: '#E2E8F0',
    borderRadius: 8,
    marginHorizontal: 4,
    alignItems: 'center',
  },
  genderOptionSelected: {
    borderColor: '#1E293B',
    backgroundColor: '#1E293B',
  },
  genderOptionText: {
    color: '#333',
  },
  genderOptionTextSelected: {
    color: '#fff',
  },
  button: {
    backgroundColor: '#1E293B',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 16,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});