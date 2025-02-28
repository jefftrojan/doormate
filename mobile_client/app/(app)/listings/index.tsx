import React, { useState, useEffect } from 'react';
import { View, StyleSheet, FlatList, ActivityIndicator, RefreshControl } from 'react-native';
import { useRouter } from 'expo-router';
import { ListingCard } from '@/components/ListingCard';
import { ListingFilters } from '@/components/ListingFilters';
import api from '@/services/api';
import { ThemedText } from '@/components/ThemedText';
import { Layout } from '@/components/Layout';

interface Listing {
  id: string;
  title: string;
  description: string;
  price: number;
  location: string;
  images: string[];
  user: {
    name: string;
    email: string;
    profilePhoto?: string;
  };
}

export default function ListingsScreen() {
  const router = useRouter();
  const [listings, setListings] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [filters, setFilters] = useState({
    type: '',
    priceMin: '',
    priceMax: '',
    location: ''
  });

  const fetchListings = async () => {
    try {
      const params = new URLSearchParams();
      if (filters.type) params.append('type', filters.type);
      if (filters.priceMin) params.append('priceMin', filters.priceMin);
      if (filters.priceMax) params.append('priceMax', filters.priceMax);
      if (filters.location) params.append('location', filters.location);

      const response = await api.get(`/listings?${params.toString()}`);
      setListings(response.data);
    } catch (error: any) {
      console.error('Error fetching listings:', error);
      if (error?.response?.status === 401) {
        // Redirect to login if unauthorized
        router.replace('/(auth)/login' as const);
      }
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchListings();
  }, [filters]);

  const onRefresh = React.useCallback(() => {
    setRefreshing(true);
    fetchListings();
  }, []);

  if (loading) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  return (
    <Layout>
      <ListingFilters
        filters={filters}
        onFilterChange={setFilters}
      />
      <FlatList
        data={listings}
        renderItem={({ item }) => (
          <ListingCard
            onPress={() => router.push(`/(app)/listing/${item.id}` as const)}
            id={item.id}
            title={item.title}
            price={item.price}
            location={item.location}
            images={item.images}
            user={item.user}
          />
        )}
        keyExtractor={item => item.id}
        contentContainerStyle={styles.listContent}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
          />
        }
        ListEmptyComponent={
          <View style={styles.emptyState}>
            <ThemedText>No listings found</ThemedText>
          </View>
        }
      />
    </Layout>
  );
}

const styles = StyleSheet.create({
  listContent: {
    paddingVertical: 12,
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  }
});