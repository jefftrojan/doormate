import React, { useEffect, useState } from 'react';
import { View, StyleSheet, ScrollView, Image, ActivityIndicator } from 'react-native';
import { useLocalSearchParams } from 'expo-router';
import { ThemedText } from '@/components/ThemedText';
import api from '@/services/api';
import { formatPrice } from '@/utils/format';

interface Listing {
  id: string;
  title: string;
  description: string;
  price: number;
  location: string;
  images: string[];
  amenities: string[];
  university: string;
  room_type: string;
  user: {
    name: string;
    email: string;
    profilePhoto?: string;
  };
}

export default function ListingDetail() {
  const { id } = useLocalSearchParams();
  const [listing, setListing] = useState<Listing | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchListing();
  }, [id]);

  const fetchListing = async () => {
    try {
      const response = await api.get(`/listings/${id}`);
      setListing(response.data);
    } catch (err) {
      setError('Failed to load listing details');
      console.error('Error:', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  if (error || !listing) {
    return (
      <View style={styles.centered}>
        <ThemedText style={styles.error}>{error || 'Listing not found'}</ThemedText>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container}>
      {listing.images.length > 0 && (
        <Image 
          source={{ uri: listing.images[0] }}
          style={styles.image}
        />
      )}
      <View style={styles.content}>
        <ThemedText style={styles.title}>{listing.title}</ThemedText>
        <ThemedText style={styles.price}>{formatPrice(listing.price)}</ThemedText>
        <ThemedText style={styles.location}>{listing.location}</ThemedText>
        
        <View style={styles.section}>
          <ThemedText style={styles.sectionTitle}>Description</ThemedText>
          <ThemedText style={styles.description}>{listing.description}</ThemedText>
        </View>

        <View style={styles.section}>
          <ThemedText style={styles.sectionTitle}>Details</ThemedText>
          <ThemedText>University: {listing.university}</ThemedText>
          <ThemedText>Room Type: {listing.room_type}</ThemedText>
        </View>

        {listing.amenities.length > 0 && (
          <View style={styles.section}>
            <ThemedText style={styles.sectionTitle}>Amenities</ThemedText>
            {listing.amenities.map((amenity, index) => (
              <ThemedText key={index} style={styles.amenity}>• {amenity}</ThemedText>
            ))}
          </View>
        )}

        <View style={styles.userSection}>
          <View style={styles.userInfo}>
            {listing.user.profilePhoto && (
              <Image 
                source={{ uri: listing.user.profilePhoto }}
                style={styles.userPhoto}
              />
            )}
            <View>
              <ThemedText style={styles.userName}>{listing.user.name}</ThemedText>
              <ThemedText style={styles.userEmail}>{listing.user.email}</ThemedText>
            </View>
          </View>
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  image: {
    width: '100%',
    height: 300,
  },
  content: {
    padding: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  price: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#2E7D32',
    marginBottom: 8,
  },
  location: {
    fontSize: 16,
    color: '#666',
    marginBottom: 16,
  },
  section: {
    marginVertical: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 8,
  },
  description: {
    fontSize: 16,
    lineHeight: 24,
  },
  amenity: {
    fontSize: 16,
    marginBottom: 4,
  },
  userSection: {
    marginTop: 24,
    paddingTop: 16,
    borderTopWidth: 1,
    borderTopColor: '#eee',
  },
  userInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  userPhoto: {
    width: 48,
    height: 48,
    borderRadius: 24,
    marginRight: 12,
  },
  userName: {
    fontSize: 16,
    fontWeight: '600',
  },
  userEmail: {
    fontSize: 14,
    color: '#666',
  },
  error: {
    color: 'red',
    fontSize: 16,
  },
});