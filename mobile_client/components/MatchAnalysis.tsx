import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

interface MatchAnalysisProps {
  overallCompatibility: number;
  lifestyle: number;
  schedule: number;
  budget: number;
  lifestyleTraits: string[];
  budgetRange: { min: number; max: number };
  conflicts: string[];
}

export default function MatchAnalysis({
  overallCompatibility,
  lifestyle,
  schedule,
  budget,
  lifestyleTraits,
  budgetRange,
  conflicts,
}: MatchAnalysisProps) {
  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Roommate AI Match</Text>
        <Ionicons name="notifications-outline" size={24} color="#8B4513" />
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Overall Compatibility</Text>
        <Text style={styles.compatibilityScore}>{overallCompatibility}%</Text>
        
        <View style={styles.progressItem}>
          <Text style={styles.label}>Lifestyle</Text>
          <View style={styles.progressBar}>
            <View style={[styles.progress, { width: `${lifestyle}%` }]} />
          </View>
        </View>

        <View style={styles.progressItem}>
          <Text style={styles.label}>Schedule</Text>
          <View style={styles.progressBar}>
            <View style={[styles.progress, { width: `${schedule}%` }]} />
          </View>
        </View>

        <View style={styles.progressItem}>
          <Text style={styles.label}>Budget</Text>
          <View style={styles.progressBar}>
            <View style={[styles.progress, { width: `${budget}%` }]} />
          </View>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Lifestyle Match</Text>
        <View style={styles.traits}>
          {lifestyleTraits.map((trait, index) => (
            <View key={index} style={styles.traitItem}>
              <Ionicons 
                name={getTraitIcon(trait)} 
                size={24} 
                color="#8B4513" 
              />
              <Text style={styles.traitText}>{trait}</Text>
            </View>
          ))}
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Budget Range</Text>
        <View style={styles.budgetContainer}>
          <Text style={styles.budgetText}>${budgetRange.min}</Text>
          <View style={styles.budgetBar}>
            <View style={styles.budgetProgress} />
          </View>
          <Text style={styles.budgetText}>${budgetRange.max}</Text>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Potential Conflicts</Text>
        {conflicts.map((conflict, index) => (
          <View key={index} style={styles.conflictItem}>
            <Ionicons name="warning" size={20} color="#FF6B6B" />
            <Text style={styles.conflictText}>{conflict}</Text>
          </View>
        ))}
      </View>
    </View>
  );
}

const getTraitIcon = (trait: string): keyof typeof Ionicons.glyphMap => {
  const icons: { [key: string]: keyof typeof Ionicons.glyphMap } = {
    'Night Owl': 'moon',
    'Social': 'people',
    'Very Clean': 'sparkles',
    'Guests OK': 'person-add',
  };
  return icons[trait] || 'checkmark-circle';
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 12,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 24,
  },
  title: {
    fontSize: 20,
    fontWeight: '600',
    color: '#8B4513',
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 16,
    color: '#141414',
  },
  compatibilityScore: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#4CAF50',
    marginBottom: 16,
  },
  progressItem: {
    marginBottom: 12,
  },
  label: {
    fontSize: 14,
    marginBottom: 4,
    color: '#666',
  },
  progressBar: {
    height: 8,
    backgroundColor: '#E2E8F0',
    borderRadius: 4,
  },
  progress: {
    height: '100%',
    backgroundColor: '#8B4513',
    borderRadius: 4,
  },
  traits: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
  },
  traitItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F8F9FA',
    padding: 12,
    borderRadius: 8,
    minWidth: '45%',
  },
  traitText: {
    marginLeft: 8,
    color: '#333',
  },
  budgetContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  budgetText: {
    color: '#666',
    fontSize: 16,
  },
  budgetBar: {
    flex: 1,
    height: 8,
    backgroundColor: '#E2E8F0',
    borderRadius: 4,
    marginHorizontal: 12,
  },
  budgetProgress: {
    width: '75%',
    height: '100%',
    backgroundColor: '#8B4513',
    borderRadius: 4,
  },
  conflictItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFF5F5',
    padding: 12,
    borderRadius: 8,
    marginBottom: 8,
  },
  conflictText: {
    marginLeft: 8,
    color: '#FF6B6B',
  },
});