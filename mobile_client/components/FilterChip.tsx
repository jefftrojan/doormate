import React from 'react';
import { StyleSheet, TouchableOpacity, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { ThemedText } from './ThemedText';

interface FilterChipProps {
  icon?: string;
  label: string;
  active: boolean;
  onPress: () => void;
  variant?: 'filter' | 'view';
}

export function FilterChip({ icon, label, active, onPress, variant = 'filter' }: FilterChipProps) {
  return (
    <TouchableOpacity 
      style={[
        styles.chip,
        variant === 'view' ? styles.viewChip : styles.filterChip,
        active && styles.chipActive
      ]}
      onPress={onPress}
    >
      {icon && (
        <Ionicons 
          name={icon as any} 
          size={16} 
          color={active ? '#B25068' : '#666'} 
          style={styles.icon}
        />
      )}
      <ThemedText 
        style={[
          styles.label,
          variant === 'view' && styles.viewLabel,
          active && styles.labelActive
        ]}
      >
        {label}
      </ThemedText>
      {variant === 'filter' && (
        <Ionicons 
          name="chevron-down" 
          size={14} 
          color="#666" 
          style={styles.chevron}
        />
      )}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  chip: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 8,
    marginRight: 8,
  },
  filterChip: {
    paddingVertical: 8,
    paddingHorizontal: 12,
    backgroundColor: '#F5F5F5',
    borderWidth: 1,
    borderColor: '#EEEEEE',
  },
  viewChip: {
    paddingVertical: 6,
    paddingHorizontal: 10,
    backgroundColor: 'transparent',
  },
  chipActive: {
    backgroundColor: '#FFF',
    borderColor: '#B25068',
  },
  icon: {
    marginRight: 6,
  },
  chevron: {
    marginLeft: 4,
  },
  label: {
    fontSize: 13,
    color: '#666',
  },
  viewLabel: {
    fontSize: 14,
    fontWeight: '500',
  },
  labelActive: {
    color: '#B25068',
    fontWeight: '500',
  },
});