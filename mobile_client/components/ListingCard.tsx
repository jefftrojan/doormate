import React from 'react';
import { View, Image, StyleSheet, Pressable, Dimensions } from 'react-native';
import { useRouter } from 'expo-router';
import { ThemedText } from './ThemedText';
import { formatPrice } from '../utils/format';

const { width } = Dimensions.get('window');
const CARD_WIDTH = width - 32;
const CARD_HEIGHT = 180; // Reduced height
const IMAGE_HEIGHT = 120; // Reduced image height

interface ListingCardProps {
  id: string;
  title: string;
  price: number;
  location: string;
  images: string[];
  user: {
    name: string;
    email: string;
    profilePhoto?: string;
  };
  onPress: () => void;
}

export function ListingCard({ id, title, price, location, images, user }: ListingCardProps) {
  const router = useRouter();

  return (
    <Pressable 
      style={styles.container}
      onPress={() => router.push(`/listing/${id}`)}
    >
      <Image 
        source={{ uri: images[0] || 'https://via.placeholder.com/300' }}
        style={styles.image}
      />
      <View style={styles.content}>
        <ThemedText style={styles.title}>{title}</ThemedText>
        <ThemedText style={styles.price}>{formatPrice(price)}</ThemedText>
        <ThemedText style={styles.location}>{location}</ThemedText>
        <View style={styles.userInfo}>
          {user.profilePhoto && (
            <Image 
              source={{ uri: user.profilePhoto }}
              style={styles.userPhoto}
            />
          )}
          <ThemedText style={styles.userName}>{user.name}</ThemedText>
        </View>
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  container: {
    width: CARD_WIDTH,
    height: CARD_HEIGHT,
    backgroundColor: '#fff',
    borderRadius: 12,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 2,
  },
  image: {
    width: '100%',
    height: IMAGE_HEIGHT,
    borderTopLeftRadius: 12,
    borderTopRightRadius: 12,
  },
  content: {
    padding: 10,
    flex: 1,
  },
  title: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 2,
  },
  price: {
    fontSize: 16,
    fontWeight: '700',
    color: '#2E7D32',
    marginBottom: 2,
  },
  location: {
    fontSize: 12,
    color: '#666',
  },
  userInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 4,
  },
  userPhoto: {
    width: 16,
    height: 16,
    borderRadius: 8,
    marginRight: 4,
  },
  userName: {
    fontSize: 12,
    color: '#666',
  },
});