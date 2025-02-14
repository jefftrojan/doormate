import { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  TextInput,
  Image,
  ScrollView,
  Platform,
  Alert,
} from 'react-native';

import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { SafeAreaView } from 'react-native-safe-area-context';
import * as ImagePicker from 'expo-image-picker';
import { ImagePickerResult } from 'expo-image-picker';
import { StatusBar } from 'expo-status-bar';
export default function ProfileSetupScreen({ navigation }: { navigation: NativeStackNavigationProp<any> }) {
  const [profileImage, setProfileImage] = useState(null);
  const [studentId, setStudentId] = useState(null);

  const requestPermission = async () => {
    const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert(
        'Permission Required',
        'Sorry, we need camera roll permissions to upload images.',
        [{ text: 'OK' }]
      );
      return false;
    }
    return true;
  };


type ImageType = 'profile' | 'id';

const pickImage = async (type: ImageType): Promise<void> => {
    const hasPermission = await requestPermission();
    if (!hasPermission) return;

    try {
        const result: ImagePickerResult = await ImagePicker.launchImageLibraryAsync({
            mediaTypes: ImagePicker.MediaTypeOptions.Images,
            allowsEditing: true,
            aspect: [1, 1],
            quality: 1,
        });

        if (!result.canceled) {
            if (type === 'profile') {
                setProfileImage(result.assets[0].uri);
            } else {
                setStudentId(result.assets[0].uri);
            }
        }
    } catch (error) {
        Alert.alert('Error', 'Failed to pick image');
    }
};

  return (
    <SafeAreaView style={styles.container} edges={['top']}>
      <StatusBar style="dark" />
      <ScrollView 
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.progressContainer}>
          <View style={styles.progressBar}>
            {[1, 2, 3, 4].map((step) => (
              <View
                key={step}
                style={[
                  styles.progressStep,
                  { opacity: step <= 2 ? 1 : 0.3 },
                ]}
              />
            ))}
          </View>
          <Text style={styles.progressText}>Step 2 of 4</Text>
        </View>

        <View style={styles.photoContainer}>
          <TouchableOpacity
            style={styles.photoUpload}
            onPress={() => pickImage('profile')}
            activeOpacity={0.8}
          >
            {profileImage ? (
              <Image source={{ uri: profileImage }} style={styles.profilePhoto} />
            ) : (
              <View style={styles.photoPlaceholder}>
                <Text style={styles.photoPlaceholderText}>+</Text>
              </View>
            )}
          </TouchableOpacity>
          <Text style={styles.photoText}>Upload Profile Photo</Text>
        </View>

        <View style={styles.form}>
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Full Name</Text>
            <TextInput
              style={styles.input}
              placeholder="Enter your full name"
              placeholderTextColor="#999"
            />
          </View>

          <View style={styles.inputGroup}>
            <Text style={styles.label}>Date of Birth</Text>
            <TextInput
              style={styles.input}
              placeholder="mm/dd/yyyy"
              placeholderTextColor="#999"
              keyboardType="numbers-and-punctuation"
            />
          </View>

          <View style={styles.inputGroup}>
            <Text style={styles.label}>Gender</Text>
            <TouchableOpacity style={styles.select} activeOpacity={0.8}>
              <Text style={styles.selectText}>Select gender</Text>
              <Text style={styles.selectIcon}>▼</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.inputGroup}>
            <Text style={styles.label}>University</Text>
            <TouchableOpacity style={styles.select} activeOpacity={0.8}>
              <Text style={styles.selectText}>Select university</Text>
              <Text style={styles.selectIcon}>▼</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.inputGroup}>
            <Text style={styles.label}>Year of Study</Text>
            <TouchableOpacity style={styles.select} activeOpacity={0.8}>
              <Text style={styles.selectText}>Select year</Text>
              <Text style={styles.selectIcon}>▼</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.idUploadContainer}>
            <Text style={styles.label}>Upload Student ID</Text>
            <View style={styles.idUploadContent}>
              <Image
                source={{ uri: 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/step2-JDAeTpqsLv9K6tzdHT3H3nI3rPZSQr.png' }}
                style={styles.exampleId}
                resizeMode="contain"
              />
              <Text style={styles.exampleText}>Example ID format</Text>
              <TouchableOpacity
                style={styles.uploadButton}
                onPress={() => pickImage('id')}
                activeOpacity={0.8}
              >
                <Text style={styles.uploadButtonText}>Upload ID</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>

        <View style={styles.navigation}>
          <TouchableOpacity
            style={styles.backButton}
            onPress={() => navigation.goBack()}
            activeOpacity={0.6}
          >
            <Text style={styles.backButtonText}>Back</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.nextButton}
            onPress={() => {/* Handle next step */}}
            activeOpacity={0.8}
          >
            <Text style={styles.nextButtonText}>Next</Text>
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
  scrollContent: {
    flexGrow: 1,
    padding: 20,
  },
  progressContainer: {
    alignItems: 'center',
    marginBottom: 32,
  },
  progressBar: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  progressStep: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: '#1a2b3c',
    marginHorizontal: 4,
  },
  progressText: {
    fontSize: 14,
    color: '#666',
  },
  photoContainer: {
    alignItems: 'center',
    marginBottom: 32,
  },
  photoUpload: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: '#f8f9fa',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 8,
    borderWidth: 1,
    borderColor: '#ddd',
    overflow: 'hidden',
  },
  profilePhoto: {
    width: '100%',
    height: '100%',
  },
  photoPlaceholder: {
    width: '100%',
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },
  photoPlaceholderText: {
    fontSize: 40,
    color: '#999',
  },
  photoText: {
    fontSize: 14,
    color: '#666',
  },
  form: {
    marginBottom: 32,
  },
  inputGroup: {
    marginBottom: 16,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 8,
    color: '#333',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    color: '#333',
  },
  select: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
  },
  selectText: {
    fontSize: 16,
    color: '#999',
  },
  selectIcon: {
    fontSize: 12,
    color: '#666',
  },
  idUploadContainer: {
    borderWidth: 1,
    borderStyle: 'dashed',
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 16,
  },
  idUploadContent: {
    alignItems: 'center',
  },
  exampleId: {
    width: 120,
    height: 80,
    marginBottom: 8,
  },
  exampleText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 16,
  },
  uploadButton: {
    backgroundColor: '#1a2b3c',
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 8,
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
  uploadButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  navigation: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 20,
  },
  backButton: {
    paddingVertical: 12,
    paddingHorizontal: 24,
  },
  backButtonText: {
    fontSize: 16,
    color: '#666',
  },
  nextButton: {
    backgroundColor: '#1a2b3c',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 8,
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
  nextButtonText: {
    fontSize: 16,
    color: '#fff',
    fontWeight: '600',
  },
});