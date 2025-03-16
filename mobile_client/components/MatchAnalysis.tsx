import React from 'react';
import { View, StyleSheet } from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import { MaterialCommunityIcons } from '@expo/vector-icons';

interface MatchAnalysisProps {
  matchScore: number;
  weeklyChange: number;
  communication: number;
  interests: number;
  lifestyleMatches: string[];
  affordabilityIndex: number;
}

export default function MatchAnalysis({
  matchScore = 87,
  weeklyChange = 5,
  communication = 90,
  interests = 85,
  lifestyleMatches = ['Morning Exercise', 'Evening Study'],
  affordabilityIndex = 78,
}: MatchAnalysisProps) {
  return (
    <View style={styles.container}>
      {/* Match Score Circle */}
      <View style={styles.scoreCircle}>
        <ThemedText style={styles.scoreText}>{matchScore}%</ThemedText>
        <ThemedText style={styles.changeText}>+{weeklyChange}% this week</ThemedText>
      </View>

      {/* Feature Analysis */}
      <View style={styles.section}>
        <ThemedText style={styles.sectionTitle}>Feature Analysis</ThemedText>
        <View style={styles.featureContainer}>
          <ThemedText style={styles.featureLabel}>Communication</ThemedText>
          <View style={styles.progressBar}>
            <View style={[styles.progress, { width: `${communication}%` }]} />
          </View>

          <ThemedText style={styles.featureLabel}>Interests</ThemedText>
          <View style={styles.progressBar}>
            <View style={[styles.progress, { width: `${interests}%` }]} />
          </View>
        </View>
      </View>

      {/* Lifestyle Match */}
      <View style={styles.section}>
        <ThemedText style={styles.sectionTitle}>Lifestyle Match</ThemedText>
        {lifestyleMatches.map((match, index) => (
          <View key={index} style={styles.matchItem}>
            <MaterialCommunityIcons name="check-circle" size={24} color="#4CAF50" />
            <ThemedText style={styles.matchText}>{match}</ThemedText>
          </View>
        ))}
      </View>

      {/* Budget Compatibility */}
      <View style={styles.section}>
        <ThemedText style={styles.sectionTitle}>Budget Compatibility</ThemedText>
        <View style={styles.budgetContainer}>
          <View style={[styles.budgetBar, { width: `${affordabilityIndex}%` }]}>
            <ThemedText style={styles.budgetText}>{affordabilityIndex}% Affordability Index</ThemedText>
          </View>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: '#fff',
  },
  scoreCircle: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: '#f5f5f5',
    alignItems: 'center',
    justifyContent: 'center',
    alignSelf: 'center',
    marginBottom: 30,
  },
  scoreText: {
    fontSize: 32,
    fontWeight: 'bold',
  },
  changeText: {
    fontSize: 14,
    color: '#4CAF50',
  },
  section: {
    marginBottom: 25,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 15,
  },
  featureContainer: {
    marginTop: 10,
  },
  featureLabel: {
    fontSize: 16,
    marginBottom: 8,
  },
  progressBar: {
    height: 8,
    backgroundColor: '#f0f0f0',
    borderRadius: 4,
    marginBottom: 15,
  },
  progress: {
    height: '100%',
    backgroundColor: '#1a1a1a',
    borderRadius: 4,
  },
  matchItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
  },
  matchText: {
    marginLeft: 10,
    fontSize: 16,
  },
  budgetContainer: {
    marginTop: 10,
  },
  budgetBar: {
    height: 40,
    backgroundColor: '#4CAF50',
    borderRadius: 8,
    justifyContent: 'center',
    paddingHorizontal: 15,
  },
  budgetText: {
    color: '#fff',
    fontWeight: '600',
  },
});