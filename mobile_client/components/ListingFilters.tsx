import React from 'react';
import { View, StyleSheet, TextInput, Platform } from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { ThemedText } from './ThemedText';

interface FiltersProps {
  filters: {
    type: string;
    priceMin: string;
    priceMax: string;
    location: string;
  };
  onFilterChange: (filters: any) => void;
}

export function ListingFilters({ filters, onFilterChange }: FiltersProps) {
  return (
    <View style={styles.container}>
      <View style={styles.pickerContainer}>
        <ThemedText style={styles.label}>Type</ThemedText>
        <Picker
          selectedValue={filters.type}
          onValueChange={(value) => onFilterChange({ ...filters, type: value })}
          style={styles.picker}
          itemStyle={styles.pickerItem}
        >
          <Picker.Item label="All Types" value="" />
          <Picker.Item label="Single Room" value="single" />
          <Picker.Item label="Shared Room" value="shared" />
          <Picker.Item label="Studio" value="studio" />
          <Picker.Item label="Apartment" value="apartment" />
        </Picker>
      </View>

      <View style={styles.section}>
        <ThemedText style={styles.label}>Price Range</ThemedText>
        <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
          <TextInput
            style={[styles.input, styles.priceInput]}
            placeholder="Min Price"
            value={filters.priceMin}
            onChangeText={(value) => onFilterChange({ ...filters, priceMin: value })}
            keyboardType="numeric"
            placeholderTextColor="#999"
          />
          <TextInput
            style={[styles.input, styles.priceInput]}
            placeholder="Max Price"
            value={filters.priceMax}
            onChangeText={(value) => onFilterChange({ ...filters, priceMax: value })}
            keyboardType="numeric"
            placeholderTextColor="#999"
          />
        </View>
      </View>

      <View style={styles.section}>
        <ThemedText style={styles.label}>Location</ThemedText>
        <TextInput
          style={styles.input}
          placeholder="Enter location"
          value={filters.location}
          onChangeText={(value) => onFilterChange({ ...filters, location: value })}
          placeholderTextColor="#999"
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 8,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
    maxHeight: Platform.OS === 'ios' ? 280 : 220,
  },
  pickerContainer: {
    marginBottom: 8,
  },
  section: {
    marginBottom: 8,
  },
  label: {
    fontSize: 12,
    fontWeight: '600',
    marginBottom: 4,
    color: '#333',
  },
  picker: {
    ...Platform.select({
      ios: {
        height: 80,
      },
      android: {
        height: 32,
      },
    }),
  },
  pickerItem: {
    fontSize: 14,
  },
  input: {
    height: 32,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 6,
    paddingHorizontal: 8,
    fontSize: 13,
    backgroundColor: '#f9f9f9',
  },
  priceInput: {
    width: '48%',
  },
});