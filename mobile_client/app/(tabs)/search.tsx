import React, { useState, useEffect } from 'react';
import { View, StyleSheet, TextInput, ScrollView, TouchableOpacity, Image, ActivityIndicator } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { ThemedText } from '@/components/ThemedText';
import { ListingCard } from '@/components/ListingCard';
import { FilterChip } from '@/components/FilterChip';
import { useRouter } from 'expo-router';
import { listingService, Listing as ListingType } from '@/services/listing';
import { useDebounce } from '@/hooks/useDebounce';

// Remove the local Listing interface and use the imported type
export default function Search() {
  const router = useRouter();
  const [listings, setListings] = useState<ListingType[]>([]);
  
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilters, setActiveFilters] = useState<string[]>([]);
  const [filters, setFilters] = useState({
    type: '',
    priceMin: 0,
    priceMax: 0,
    location: '',
    amenities: [] as string[],
  });

  const debouncedSearch = useDebounce(searchQuery, 500);

  useEffect(() => {
    fetchListings();
  }, [debouncedSearch, filters]);

  const fetchListings = async () => {
    try {
      setLoading(true);
      const response = await listingService.getListings({
        ...filters,
        location: debouncedSearch || filters.location,
      });
      setListings(response);
    } catch (error) {
      console.error('Error fetching listings:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleFilterChange = (filterType: string) => {
    setActiveFilters(prev => 
      prev.includes(filterType) 
        ? prev.filter(f => f !== filterType)
        : [...prev, filterType]
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.searchBar}>
        <Ionicons name="search" size={20} color="#666" />
        <TextInput
          style={styles.searchInput}
          placeholder="Search locations, neighborhoods..."
          placeholderTextColor="#666"
          value={searchQuery}
          onChangeText={setSearchQuery}
        />
      </View>

      <ScrollView 
        horizontal 
        showsHorizontalScrollIndicator={false}
        style={styles.filters}
        contentContainerStyle={styles.filtersContent}
      >
        <FilterChip
          icon="options-outline"
          label="All Filters"
          active={false}
          onPress={() => router.push('/(app)/filters')}
        />
        <FilterChip
          icon="cash-outline"
          label="Price Range"
          active={activeFilters.includes('price')}
          onPress={() => handleFilterChange('price')}
        />
        <FilterChip
          icon="bed-outline"
          label="Room Type"
          active={activeFilters.includes('room')}
          onPress={() => handleFilterChange('room')}
        />
        <FilterChip
          icon="location-outline"
          label="Location"
          active={activeFilters.includes('location')}
          onPress={() => handleFilterChange('location')}
        />
      </ScrollView>

      {loading ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#1E293B" />
        </View>
      ) : (
        <ScrollView 
          style={styles.listingsContainer}
          showsVerticalScrollIndicator={false}
        >
          {listings.map(listing => (
            <ListingCard
              key={listing.id}
              id={listing.id}
              title={listing.name}  // Changed from title to name
              price={listing.price}
              location={listing.location}
              images={listing.images}
              user={listing.user}
              onPress={() => router.push(`/(app)/listing/${listing.id}`)}
            />
          ))}
        </ScrollView>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  searchBar: {
    flexDirection: 'row',
    alignItems: 'center',
    margin: 16,
    padding: 12,
    backgroundColor: '#F8F9FA',
    borderRadius: 8,
  },
  searchInput: {
    flex: 1,
    marginLeft: 8,
    fontSize: 16,
  },
  filters: {
    paddingHorizontal: 16,
    marginBottom: 16,
  },
  filtersContent: {
    paddingVertical: 8,
  },
  filterButton: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 8,
    marginRight: 12,
    borderRadius: 8,
    backgroundColor: '#F8F9FA',
  },
  filterButtonText: {
    marginLeft: 4,
  },
  filterChip: {
    padding: 8,
    marginRight: 12,
    borderRadius: 8,
    backgroundColor: '#F8F9FA',
  },
  listingsContainer: {
    flex: 1,
    padding: 16,
  },
  listingCard: {
    padding: 16,
    marginBottom: 16,
    borderRadius: 12,
    backgroundColor: '#fff',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  listingHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  listingType: {
    fontSize: 14,
    color: '#666',
  },
  matchScore: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  matchScoreText: {
    marginLeft: 4,
    fontSize: 14,
    color: '#666',
  },
  listingPrice: {
    fontSize: 20,
    fontWeight: '600',
    marginBottom: 8,
  },
  locationContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  locationText: {
    marginLeft: 4,
    color: '#666',
  },
  amenitiesContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 12,
  },
  amenityTag: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 6,
    borderRadius: 6,
    backgroundColor: '#F8F9FA',
  },
  amenityText: {
    marginLeft: 4,
    fontSize: 12,
    color: '#666',
  },
  roommatesContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  avatarStack: {
    flexDirection: 'row',
    marginRight: 8,
  },
  avatar: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: '#1E293B',
    position: 'absolute',
  },
  roommatesText: {
    marginLeft: 24,
    fontSize: 14,
    color: '#666',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});