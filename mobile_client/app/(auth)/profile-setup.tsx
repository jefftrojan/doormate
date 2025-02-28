import React, { useState } from 'react';
import { View, StyleSheet, Platform } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { Button, Input } from 'react-native-elements';
import * as ImagePicker from 'expo-image-picker';
import { ThemedView } from '@/components/ThemedView';
import { ThemedText } from '@/components/ThemedText';
import { Image, TouchableOpacity } from 'react-native';
import { Icon } from 'react-native-elements';
import { useAuth } from '@/contexts/AuthContext';
import { authService } from '@/services/auth';

export default function ProfileSetup() {
  const { user, updateProfile } = useAuth();
  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [profile, setProfile] = useState({
    fullName: '',
    dateOfBirth: '',
    gender: '',
    university: '',
    yearOfStudy: '',
    studentId: '',
    profilePhoto: ''
  });

  const handleProfileUpdate = (update: Partial<typeof profile>) => {
    setProfile(prev => ({ ...prev, ...update }));
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
    if (!profile.studentId) {
      newErrors.studentId = 'Student ID is required';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleStudentIdUpload = async () => {
    try {
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [3, 2],
        quality: 0.8,
      });

      if (!result.canceled) {
        const response = await fetch(result.assets[0].uri);
        const blob = await response.blob();
        
        const formData = new FormData();
        formData.append('studentId', blob, 'student-id.jpg');

        setIsLoading(true);
        const uploadResponse = await authService.uploadStudentId(formData);
        handleProfileUpdate({ studentId: uploadResponse.imageUrl });
      }
    } catch (err: any) {
      setErrors({ studentId: 'Failed to upload student ID' });
    } finally {
      setIsLoading(false);
    }
  };

  const handleImagePick = async () => {
    try {
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.5,
      });

      if (!result.canceled) {
        const formData = new FormData();
        const imageUri = result.assets[0].uri;
        
        const response = await fetch(imageUri);
        const blob = await response.blob();
        
        formData.append('image', blob, 'profile-photo.jpg');

        setIsLoading(true);
        const uploadResponse = await authService.uploadImage(formData);
        handleProfileUpdate({ profilePhoto: uploadResponse.imageUrl });
      }
    } catch (err: any) {
      setErrors({ photo: 'Failed to upload image' });
    } finally {
      setIsLoading(false);
    }
  };

  const handleNext = async () => {
    if (validateForm()) {
      try {
        setIsLoading(true);
        await authService.updateProfile(user?._id as string, profile);
        router.push('/(auth)/preferences');
      } catch (err: any) {
        setErrors({ submit: err.response?.data?.message || 'Failed to update profile' });
      } finally {
        setIsLoading(false);
      }
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <ThemedView style={styles.content}>
        <View style={styles.header}>
          <Button
            icon={{ name: 'arrow-back', type: 'ionicon', color: '#000' }}
            type="clear"
            onPress={() => router.back()}
          />
          <ThemedText style={styles.stepText}>Step 2 of 4</ThemedText>
        </View>

        <View style={styles.photoSection}>
          <TouchableOpacity onPress={handleImagePick}>
            {profile.profilePhoto ? (
              <Image 
                source={{ uri: profile.profilePhoto }} 
                style={styles.profilePhoto} 
              />
            ) : (
              <View style={styles.photoPlaceholder}>
                <Icon name="camera" type="ionicon" color="#666" />
              </View>
            )}
          </TouchableOpacity>
          <ThemedText style={styles.photoText}>Upload Profile Photo</ThemedText>
        </View>

        <Input
          placeholder="Full Name"
          value={profile.fullName}
          onChangeText={text => handleProfileUpdate({ fullName: text })}
          errorMessage={errors.fullName}
        />

        <Input
          placeholder="Date of Birth"
          value={profile.dateOfBirth}
          onChangeText={text => handleProfileUpdate({ dateOfBirth: text })}
          errorMessage={errors.dateOfBirth}
          rightIcon={{ name: 'calendar', type: 'ionicon', color: '#666' }}
        />

        <Input
          placeholder="Select Gender"
          value={profile.gender}
          onChangeText={text => handleProfileUpdate({ gender: text })}
          errorMessage={errors.gender}
          rightIcon={{ name: 'chevron-down', type: 'ionicon', color: '#666' }}
        />

        <Input
          placeholder="Select University"
          value={profile.university}
          onChangeText={text => handleProfileUpdate({ university: text })}
          errorMessage={errors.university}
          rightIcon={{ name: 'chevron-down', type: 'ionicon', color: '#666' }}
        />

        <Input
          placeholder="Year of Study"
          value={profile.yearOfStudy}
          onChangeText={text => handleProfileUpdate({ yearOfStudy: text })}
          errorMessage={errors.yearOfStudy}
          rightIcon={{ name: 'chevron-down', type: 'ionicon', color: '#666' }}
        />

        <View style={styles.idSection}>
          <ThemedText style={styles.idTitle}>Upload Student ID</ThemedText>
          {profile.studentId ? (
            <View style={styles.idPreview}>
              <Image 
                source={{ uri: profile.studentId }} 
                style={styles.idImage} 
              />
              <TouchableOpacity onPress={handleStudentIdUpload}>
                <ThemedText style={styles.changeIdText}>Change ID</ThemedText>
              </TouchableOpacity>
            </View>
          ) : (
            <Button
              title={isLoading ? "Uploading..." : "Upload ID"}
              onPress={handleStudentIdUpload}
              buttonStyle={styles.uploadButton}
              disabled={isLoading}
            />
          )}
          {errors.studentId && (
            <ThemedText style={styles.errorText}>{errors.studentId}</ThemedText>
          )}
        </View>

        <View style={styles.buttonContainer}>
          <Button
            title="Back"
            type="outline"
            containerStyle={styles.backButton}
            onPress={() => router.back()}
          />
          <Button
            title={isLoading ? "Saving..." : "Next"}
            containerStyle={styles.nextButton}
            onPress={handleNext}
            disabled={isLoading}
          />
        </View>
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
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 30,
  },
  stepText: {
    fontSize: 16,
    marginLeft: 10,
  },
  photoSection: {
    alignItems: 'center',
    marginBottom: 30,
  },
  profilePhoto: {
    width: 100,
    height: 100,
    borderRadius: 50,
  },
  photoPlaceholder: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: '#f0f0f0',
    justifyContent: 'center',
    alignItems: 'center',
  },
  photoText: {
    marginTop: 10,
    fontSize: 16,
  },
  idSection: {
    marginTop: 20,
    alignItems: 'center',
  },
  idTitle: {
    fontSize: 16,
    marginBottom: 10,
  },
  uploadButton: {
    backgroundColor: '#1a2b3c',
    paddingHorizontal: 30,
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 'auto',
    paddingTop: 20,
  },
  backButton: {
    width: '48%',
  },
  nextButton: {
    width: '48%',
    backgroundColor: '#1a2b3c',
  },
  idPreview: {
    alignItems: 'center',
    marginTop: 10,
  },
  idImage: {
    width: 200,
    height: 120,
    borderRadius: 8,
    marginBottom: 10,
  },
  changeIdText: {
    color: '#1a2b3c',
    textDecorationLine: 'underline',
  },
  errorText: {
    color: 'red',
    fontSize: 12,
    marginTop: 5,
  },
});