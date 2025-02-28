import React, { useState, useEffect } from 'react';
import { View, StyleSheet, Platform } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { Button, Slider } from 'react-native-elements';
import { ThemedView } from '@/components/ThemedView';
import { ThemedText } from '@/components/ThemedText';
import { useAuth } from '@/contexts/AuthContext';
import { authService } from '@/services/auth';
import { TouchableOpacity } from 'react-native';

export default function Preferences() {
  const { user, updatePreferences } = useAuth();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [preferences, setPreferences] = useState({
    cleanliness: 0,
    noiseLevel: 0,
    studyHabits: '',
    budget: 300
  });

  useEffect(() => {
    const fetchPreferences = async () => {
      try {
        setIsLoading(true);
        if (user?._id) {
          const response = await authService.getUserPreferences(user._id);
          setPreferences(response.data);
        }
      } catch (err: any) {
        setError(err.response?.data?.message || 'Failed to load preferences');
      } finally {
        setIsLoading(false);
      }
    };

    fetchPreferences();
  }, [user]);

  const handlePreferencesUpdate = async (update: Partial<typeof preferences>) => {
    try {
      const newPreferences = { ...preferences, ...update };
      setPreferences(newPreferences);
      if (user?._id) {
        await authService.updatePreferences(user._id, newPreferences);
      }
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to update preference');
    }
  };

  const handleNext = async () => {
    try {
      if (!user) {
        throw new Error('User not found');
      }
      setIsLoading(true);
      await authService.updatePreferences(user._id, preferences); // Use local preferences state
      router.push('/(tabs)');
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to update preferences');
    } finally {
      setIsLoading(false);
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
          <ThemedText style={styles.stepText}>Step 3 of 4</ThemedText>
        </View>

        <ThemedText style={styles.title}>Your Preferences</ThemedText>

        <View style={styles.section}>
          <ThemedText style={styles.label}>Cleanliness Level</ThemedText>
          <View style={styles.emojiScale}>
            {['😫', '🙁', '😐', '🙂', '😊'].map((emoji, index) => (
              <TouchableOpacity
                key={index}
                onPress={() => handlePreferencesUpdate({ cleanliness: index + 1 })}
                style={[
                  styles.emojiButton,
                  preferences.cleanliness === index + 1 && styles.selectedEmoji
                ]}
              >
                <ThemedText style={styles.emoji}>{emoji}</ThemedText>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        <View style={styles.section}>
          <ThemedText style={styles.label}>Noise Level</ThemedText>
          <Slider
            value={preferences.noiseLevel}
            onValueChange={value => handlePreferencesUpdate({ noiseLevel: value })}
            minimumValue={0}
            maximumValue={100}
            step={1}
            thumbStyle={styles.sliderThumb}
            trackStyle={styles.sliderTrack}
          />
          <View style={styles.sliderLabels}>
            <ThemedText>Quiet</ThemedText>
            <ThemedText>Noisy</ThemedText>
          </View>
        </View>

        <View style={styles.section}>
          <ThemedText style={styles.label}>Study Habits</ThemedText>
          <View style={styles.buttonGroup}>
            {['Morning', 'Afternoon', 'Night'].map(time => (
              <TouchableOpacity
                key={time}
                style={[
                  styles.habitButton,
                  preferences.studyHabits === time.toLowerCase() && styles.selectedButton
                ]}
                onPress={() => handlePreferencesUpdate({ studyHabits: time.toLowerCase() })}
              >
                <ThemedText style={styles.buttonText}>{time}</ThemedText>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        <View style={styles.section}>
          <ThemedText style={styles.label}>Budget Range (Monthly)</ThemedText>
          <View style={styles.budgetContainer}>
            <Slider
              value={preferences.budget}
              onValueChange={value => handlePreferencesUpdate({ budget: Math.round(value) })}
              minimumValue={300}
              maximumValue={2000}
              step={50}
              thumbStyle={styles.sliderThumb}
              trackStyle={styles.sliderTrack}
            />
            <View style={styles.budgetLabels}>
              <ThemedText>$300</ThemedText>
              <ThemedText>${preferences.budget || 300}</ThemedText>
            </View>
          </View>
        </View>

        {error ? <ThemedText style={styles.errorText}>{error}</ThemedText> : null}

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
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 30,
  },
  section: {
    marginBottom: 24,
  },
  label: {
    fontSize: 16,
    marginBottom: 12,
  },
  emojiScale: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
  },
  sliderLabels: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 8,
  },
  emojiButton: {
    padding: 10,
    borderRadius: 25,
  },
  selectedEmoji: {
    backgroundColor: '#f0f0f0',
  },
  emoji: {
    fontSize: 24,
  },
  sliderThumb: {
    width: 20,
    height: 20,
    backgroundColor: '#1a2b3c',
  },
  sliderTrack: {
    height: 4,
  },
  buttonGroup: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  socialButton: {
    flex: 1,
    padding: 12,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#ddd',
    marginHorizontal: 4,
    alignItems: 'center',
  },
  budgetContainer: {
    marginTop: 10,
  },
  budgetLabels: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 8,
  },
  errorText: {
    color: 'red',
    textAlign: 'center',
    marginBottom: 16,
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 24,
  },
  backButton: {
    flex: 1,
    marginRight: 8,
  },
  nextButton: {
    flex: 1,
    marginLeft: 8,
  },
  habitButton: {
    flex: 1,
    padding: 12,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#ddd',
    marginHorizontal: 4,
    alignItems: 'center',
  },
  selectedButton: {
    backgroundColor: '#1a2b3c',
  },
  buttonText: {
    color: '#000',
  },
});