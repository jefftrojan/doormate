import React, { useState, useEffect } from 'react';
import { View, StyleSheet, TextInput, ScrollView, TouchableOpacity, ActivityIndicator } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { listingService } from '@/services/listing';
import { useDebounce } from '@/hooks/useDebounce';
import { ThemedText } from '@/components/ThemedText';

type FilterOption = {
  id: 'price' | 'room' | 'location';
  label: string;
  icon: keyof typeof Ionicons.glyphMap;
};

export default function Search() {
  const router = useRouter();
  const [searchQuery, setSearchQuery] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const debouncedSearch = useDebounce(searchQuery, 500);

  const filterOptions: FilterOption[] = [
    { id: 'price', label: 'Price Range', icon: 'cash-outline' },
    { id: 'room', label: 'Room Type', icon: 'bed-outline' },
    { id: 'location', label: 'Location', icon: 'location-outline' }
  ];

  const handleFilterPress = (filterId: FilterOption['id']) => {
    router.push({
      pathname: '/filters',
      params: { type: filterId }
    });
  };

  return (
    <View style={styles.container}>
      {/* Search Header */}
      <View style={styles.searchHeader}>
        <View style={styles.searchBar}>
          <Ionicons name="search" size={20} color="#8B4513" />
          <TextInput
            style={styles.searchInput}
            placeholder="Search location, neighborhoods..."
            value={searchQuery}
            onChangeText={setSearchQuery}
            placeholderTextColor="#666"
          />
        </View>
      </View>

      {/* Filter Options */}
      <View style={styles.filterContainer}>
        {filterOptions.map((option) => (
          <TouchableOpacity
            key={option.id}
            style={styles.filterButton}
            onPress={() => handleFilterPress(option.id)}
          >
            <Ionicons name={option.icon} size={20} color="#333" />
            <ThemedText style={styles.filterText}>{option.label}</ThemedText>
            <Ionicons name="chevron-down" size={16} color="#333" />
          </TouchableOpacity>
        ))}
      </View>

      {/* Content Area */}
      <ScrollView style={styles.content}>
        {isLoading ? (
          <ActivityIndicator style={styles.loader} color="#8B4513" />
        ) : (
          // Add your listing content here
          <View style={styles.listingsContainer}>
            {/* Listings will go here */}
          </View>
        )}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  searchHeader: {
    padding: 16,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  searchBar: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
    paddingHorizontal: 12,
    borderRadius: 12,
    height: 44,
  },
  searchInput: {
    flex: 1,
    marginLeft: 8,
    fontSize: 16,
    color: '#333',
  },
  filterContainer: {
    flexDirection: 'row',
    paddingHorizontal: 12,
    paddingVertical: 8,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  filterButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 8,
    marginHorizontal: 4,
    backgroundColor: '#f5f5f5',
    borderRadius: 8,
  },
  filterText: {
    marginHorizontal: 4,
    fontSize: 14,
    color: '#333',
  },
  content: {
    flex: 1,
  },
  loader: {
    marginTop: 20,
  },
  listingsContainer: {
    padding: 16,
  },
});