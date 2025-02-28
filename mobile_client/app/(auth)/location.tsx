import React, { useState } from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { Button, Input } from 'react-native-elements';
import { ThemedView } from '@/components/ThemedView';
import { ThemedText } from '@/components/ThemedText';
import { useAuth } from '@/contexts/AuthContext';
import { authService } from '@/services/auth';
import MapView, { Marker } from 'react-native-maps';

// Remove unused imports and fix auth context usage
export default function Location() {
  const { user } = useAuth(); // Replace unused authState and updateLocation
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  const [region, setRegion] = useState({
    latitude: -1.9441,
    longitude: 30.0619,
    latitudeDelta: 0.0922,
    longitudeDelta: 0.0421,
  });

  const handleSearch = async () => {
    try {
      setIsLoading(true);
      // todo: Implement location search functionality
      // todo: Update region based on search results
    } catch (err) {
      setError('Failed to find location');
    } finally {
      setIsLoading(false);
    }
  };

  const handleNext = async () => {
    try {
      setIsLoading(true);
      await authService.updateProfile(user?._id || '', {
        location: {
          latitude: region.latitude,
          longitude: region.longitude,
          preferredArea: searchQuery,
        }
      });
      router.push('/(tabs)');
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to update location');
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
          <ThemedText style={styles.stepText}>Step 4 of 4</ThemedText>
        </View>

        <ThemedText style={styles.title}>Preferred Location</ThemedText>
        
        <View style={styles.searchContainer}>
          <Input
            placeholder="Search location"
            value={searchQuery}
            onChangeText={setSearchQuery}
            rightIcon={{
              name: 'search',
              type: 'ionicon',
              color: '#666',
              onPress: handleSearch,
            }}
            containerStyle={styles.searchInput}
          />
        </View>

        <View style={styles.mapContainer}>
          <MapView
            style={styles.map}
            region={region}
            onRegionChangeComplete={setRegion}
          >
            <Marker
              coordinate={{
                latitude: region.latitude,
                longitude: region.longitude,
              }}
              draggable
              onDragEnd={(e) => setRegion({
                ...region,
                latitude: e.nativeEvent.coordinate.latitude,
                longitude: e.nativeEvent.coordinate.longitude,
              })}
            />
          </MapView>
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
            title={isLoading ? "Saving..." : "Finish"}
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
    marginBottom: 20,
  },
  searchContainer: {
    marginBottom: 20,
  },
  searchInput: {
    paddingHorizontal: 0,
  },
  mapContainer: {
    flex: 1,
    borderRadius: 12,
    overflow: 'hidden',
    marginBottom: 20,
  },
  map: {
    width: '100%',
    height: '100%',
  },
  errorText: {
    color: 'red',
    textAlign: 'center',
    marginBottom: 16,
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 20,
  },
  backButton: {
    width: '48%',
  },
  nextButton: {
    width: '48%',
    backgroundColor: '#1a2b3c',
  },
});