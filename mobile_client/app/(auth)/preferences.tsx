import React, { useState } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  TouchableOpacity, 
  Alert,
  ActivityIndicator,
  Image,
  ScrollView,
  Platform,
  Slider
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '@/contexts/AuthContext';
import api from '@/services/api';

export default function Preferences() {
  const { user } = useAuth();
  const [isLoading, setIsLoading] = useState(false);
  const [preferences, setPreferences] = useState({
    cleanliness: 3, // 1-5 scale
    noiseLevel: 3, // 1-5 scale
    sleepSchedule: 'Regular', // Regular, Night Owl, Early Bird
    studyHabits: 'Moderate', // Light, Moderate, Intense
    smoking: false,
    pets: false,
    budget: {
      min: 100,
      max: 500
    }
  });

  const handleSliderChange = (field: 'cleanliness' | 'noiseLevel', value: number) => {
    setPreferences(prev => ({
      ...prev,
      [field]: Math.round(value)
    }));
  };

  const handleToggle = (field: 'smoking' | 'pets') => {
    setPreferences(prev => ({
      ...prev,
      [field]: !prev[field]
    }));
  };

  const handleSelectOption = (
    field: 'sleepSchedule' | 'studyHabits', 
    value: string
  ) => {
    setPreferences(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleBudgetChange = (type: 'min' | 'max', value: number) => {
    setPreferences(prev => ({
      ...prev,
      budget: {
        ...prev.budget,
        [type]: Math.round(value)
      }
    }));
  };

  const handleNext = async () => {
    try {
      setIsLoading(true);
      
      // Save preferences to server
      const response = await api.post('/api/preferences/update', preferences);
      
      if (response.data.success) {
        // Navigate to location screen
        router.push('/(auth)/location');
      }
    } catch (error: any) {
      console.error('Preferences update error:', error);
      Alert.alert(
        'Update Failed', 
        error.response?.data?.message || 'Failed to update preferences'
      );
    } finally {
      setIsLoading(false);
    }
  };

  const handleSkip = () => {
    router.push('/(auth)/location');
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
        <Text style={styles.headerTitle}>Your Preferences</Text>
        <View style={{ width: 24 }} />
      </View>
      
      <ScrollView 
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <Text style={styles.subtitle}>
          Tell us about your living preferences to help find your perfect roommate
        </Text>
        
        {/* Cleanliness Preference */}
        <View style={styles.preferenceSection}>
          <Text style={styles.sectionTitle}>Cleanliness</Text>
          <Text style={styles.sectionSubtitle}>How clean do you keep your living space?</Text>
          
          <View style={styles.sliderContainer}>
            <Text style={styles.sliderLabel}>Relaxed</Text>
            <Slider
              style={styles.slider}
              minimumValue={1}
              maximumValue={5}
              step={1}
              value={preferences.cleanliness}
              onValueChange={(value) => handleSliderChange('cleanliness', value)}
              minimumTrackTintColor="#1E293B"
              maximumTrackTintColor="#E2E8F0"
              thumbTintColor="#1E293B"
            />
            <Text style={styles.sliderLabel}>Very Clean</Text>
          </View>
          
          <View style={styles.valueIndicator}>
            <Text style={styles.valueText}>{preferences.cleanliness}</Text>
          </View>
        </View>
        
        {/* Noise Level Preference */}
        <View style={styles.preferenceSection}>
          <Text style={styles.sectionTitle}>Noise Level</Text>
          <Text style={styles.sectionSubtitle}>What noise level do you prefer?</Text>
          
          <View style={styles.sliderContainer}>
            <Text style={styles.sliderLabel}>Quiet</Text>
            <Slider
              style={styles.slider}
              minimumValue={1}
              maximumValue={5}
              step={1}
              value={preferences.noiseLevel}
              onValueChange={(value) => handleSliderChange('noiseLevel', value)}
              minimumTrackTintColor="#1E293B"
              maximumTrackTintColor="#E2E8F0"
              thumbTintColor="#1E293B"
            />
            <Text style={styles.sliderLabel}>Lively</Text>
          </View>
          
          <View style={styles.valueIndicator}>
            <Text style={styles.valueText}>{preferences.noiseLevel}</Text>
          </View>
        </View>
        
        {/* Sleep Schedule */}
        <View style={styles.preferenceSection}>
          <Text style={styles.sectionTitle}>Sleep Schedule</Text>
          <Text style={styles.sectionSubtitle}>What's your typical sleep schedule?</Text>
          
          <View style={styles.optionsContainer}>
            <TouchableOpacity 
              style={[
                styles.optionButton,
                preferences.sleepSchedule === 'Early Bird' && styles.optionButtonSelected
              ]}
              onPress={() => handleSelectOption('sleepSchedule', 'Early Bird')}
            >
              <Text style={[
                styles.optionText,
                preferences.sleepSchedule === 'Early Bird' && styles.optionTextSelected
              ]}>Early Bird</Text>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={[
                styles.optionButton,
                preferences.sleepSchedule === 'Regular' && styles.optionButtonSelected
              ]}
              onPress={() => handleSelectOption('sleepSchedule', 'Regular')}
            >
              <Text style={[
                styles.optionText,
                preferences.sleepSchedule === 'Regular' && styles.optionTextSelected
              ]}>Regular</Text>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={[
                styles.optionButton,
                preferences.sleepSchedule === 'Night Owl' && styles.optionButtonSelected
              ]}
              onPress={() => handleSelectOption('sleepSchedule', 'Night Owl')}
            >
              <Text style={[
                styles.optionText,
                preferences.sleepSchedule === 'Night Owl' && styles.optionTextSelected
              ]}>Night Owl</Text>
            </TouchableOpacity>
          </View>
        </View>
        
        {/* Study Habits */}
        <View style={styles.preferenceSection}>
          <Text style={styles.sectionTitle}>Study Habits</Text>
          <Text style={styles.sectionSubtitle}>How much do you typically study?</Text>
          
          <View style={styles.optionsContainer}>
            <TouchableOpacity 
              style={[
                styles.optionButton,
                preferences.studyHabits === 'Light' && styles.optionButtonSelected
              ]}
              onPress={() => handleSelectOption('studyHabits', 'Light')}
            >
              <Text style={[
                styles.optionText,
                preferences.studyHabits === 'Light' && styles.optionTextSelected
              ]}>Light</Text>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={[
                styles.optionButton,
                preferences.studyHabits === 'Moderate' && styles.optionButtonSelected
              ]}
              onPress={() => handleSelectOption('studyHabits', 'Moderate')}
            >
              <Text style={[
                styles.optionText,
                preferences.studyHabits === 'Moderate' && styles.optionTextSelected
              ]}>Moderate</Text>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={[
                styles.optionButton,
                preferences.studyHabits === 'Intense' && styles.optionButtonSelected
              ]}
              onPress={() => handleSelectOption('studyHabits', 'Intense')}
            >
              <Text style={[
                styles.optionText,
                preferences.studyHabits === 'Intense' && styles.optionTextSelected
              ]}>Intense</Text>
            </TouchableOpacity>
          </View>
        </View>
        
        {/* Smoking Preference */}
        <View style={styles.preferenceSection}>
          <View style={styles.toggleContainer}>
            <View>
              <Text style={styles.sectionTitle}>Smoking</Text>
              <Text style={styles.sectionSubtitle}>Do you smoke?</Text>
            </View>
            
            <TouchableOpacity 
              style={[
                styles.toggleButton,
                preferences.smoking && styles.toggleButtonActive
              ]}
              onPress={() => handleToggle('smoking')}
            >
              <View style={[
                styles.toggleIndicator,
                preferences.smoking && styles.toggleIndicatorActive
              ]} />
            </TouchableOpacity>
          </View>
        </View>
        
        {/* Pets Preference */}
        <View style={styles.preferenceSection}>
          <View style={styles.toggleContainer}>
            <View>
              <Text style={styles.sectionTitle}>Pets</Text>
              <Text style={styles.sectionSubtitle}>Do you have or want pets?</Text>
            </View>
            
            <TouchableOpacity 
              style={[
                styles.toggleButton,
                preferences.pets && styles.toggleButtonActive
              ]}
              onPress={() => handleToggle('pets')}
            >
              <View style={[
                styles.toggleIndicator,
                preferences.pets && styles.toggleIndicatorActive
              ]} />
            </TouchableOpacity>
          </View>
        </View>
        
        {/* Budget Range */}
        <View style={styles.preferenceSection}>
          <Text style={styles.sectionTitle}>Budget Range (USD)</Text>
          <Text style={styles.sectionSubtitle}>What's your monthly budget for rent?</Text>
          
          <View style={styles.budgetContainer}>
            <View style={styles.budgetSection}>
              <Text style={styles.budgetLabel}>Minimum: ${preferences.budget.min}</Text>
              <Slider
                style={styles.slider}
                minimumValue={50}
                maximumValue={preferences.budget.max - 50}
                step={10}
                value={preferences.budget.min}
                onValueChange={(value) => handleBudgetChange('min', value)}
                minimumTrackTintColor="#E2E8F0"
                maximumTrackTintColor="#1E293B"
                thumbTintColor="#1E293B"
              />
            </View>
            
            <View style={styles.budgetSection}>
              <Text style={styles.budgetLabel}>Maximum: ${preferences.budget.max}</Text>
              <Slider
                style={styles.slider}
                minimumValue={preferences.budget.min + 50}
                maximumValue={1000}
                step={10}
                value={preferences.budget.max}
                onValueChange={(value) => handleBudgetChange('max', value)}
                minimumTrackTintColor="#E2E8F0"
                maximumTrackTintColor="#1E293B"
                thumbTintColor="#1E293B"
              />
            </View>
          </View>
        </View>
        
        <View style={styles.buttonContainer}>
          <TouchableOpacity 
            style={styles.skipButton}
            onPress={handleSkip}
          >
            <Text style={styles.skipButtonText}>Skip</Text>
          </TouchableOpacity>
          
          <TouchableOpacity 
            style={styles.nextButton}
            onPress={handleNext}
            disabled={isLoading}
          >
            {isLoading ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.nextButtonText}>Continue</Text>
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
  subtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 32,
  },
  preferenceSection: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  sectionSubtitle: {
    fontSize: 14,
    color: '#666',
    marginBottom: 16,
  },
  sliderContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  slider: {
    flex: 1,
    height: 40,
    marginHorizontal: 10,
  },
  sliderLabel: {
    fontSize: 12,
    color: '#666',
    width: 60,
  },
  valueIndicator: {
    alignItems: 'center',
    marginTop: 8,
  },
  valueText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1E293B',
  },
  optionsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  optionButton: {
    flex: 1,
    padding: 12,
    borderWidth: 1,
    borderColor: '#E2E8F0',
    borderRadius: 8,
    marginHorizontal: 4,
    alignItems: 'center',
  },
  optionButtonSelected: {
    borderColor: '#1E293B',
    backgroundColor: '#1E293B',
  },
  optionText: {
    color: '#333',
  },
  optionTextSelected: {
    color: '#fff',
  },
  toggleContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  toggleButton: {
    width: 50,
    height: 30,
    borderRadius: 15,
    backgroundColor: '#E2E8F0',
    padding: 2,
    justifyContent: 'center',
  },
  toggleButtonActive: {
    backgroundColor: '#1E293B',
  },
  toggleIndicator: {
    width: 26,
    height: 26,
    borderRadius: 13,
    backgroundColor: '#fff',
  },
  toggleIndicatorActive: {
    transform: [{ translateX: 20 }],
  },
  budgetContainer: {
    marginTop: 8,
  },
  budgetSection: {
    marginBottom: 16,
  },
  budgetLabel: {
    fontSize: 14,
    marginBottom: 8,
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 24,
  },
  skipButton: {
    flex: 1,
    padding: 16,
    borderWidth: 1,
    borderColor: '#E2E8F0',
    borderRadius: 8,
    alignItems: 'center',
    marginRight: 8,
  },
  skipButtonText: {
    color: '#666',
    fontSize: 16,
    fontWeight: '500',
  },
  nextButton: {
    flex: 2,
    backgroundColor: '#1E293B',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
    marginLeft: 8,
  },
  nextButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});