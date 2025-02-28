import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '@/contexts/AuthContext';

export default function MatchAnalysis() {
  const auth = useAuth();
  const matchScore = 87;
  const weeklyChange = '+5%';

  const features = [
    { name: 'Communication', score: 85 },
    { name: 'Interests', score: 90 },
  ];

  const synergyPoints = [
    'Morning Exercise',
    'Evening Study',
  ];

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <ThemedText style={styles.title}>AI Match Analysis</ThemedText>
      </View>

      <View style={styles.scoreSection}>
        <View style={styles.scoreCircle}>
          <ThemedText style={styles.scoreText}>{matchScore}%</ThemedText>
          <ThemedText style={styles.changeText}>{weeklyChange} this week</ThemedText>
        </View>
      </View>

      <View style={styles.section}>
        <ThemedText style={styles.sectionTitle}>Feature Analysis</ThemedText>
        {features.map((feature, index) => (
          <View key={index} style={styles.featureRow}>
            <ThemedText style={styles.featureName}>{feature.name}</ThemedText>
            <View style={styles.progressBar}>
              <View style={[styles.progress, { width: `${feature.score}%` }]} />
            </View>
          </View>
        ))}
      </View>

      <View style={styles.section}>
        <ThemedText style={styles.sectionTitle}>Lifestyle Match</ThemedText>
        <View style={styles.synergyPoints}>
          {synergyPoints.map((point, index) => (
            <View key={index} style={styles.synergyPoint}>
              <Ionicons name="checkmark-circle" size={24} color="#4CAF50" />
              <ThemedText style={styles.synergyText}>{point}</ThemedText>
            </View>
          ))}
        </View>
      </View>

      <View style={styles.section}>
        <ThemedText style={styles.sectionTitle}>Budget Compatibility</ThemedText>
        <View style={styles.budgetBar}>
          <View style={[styles.budgetProgress, { width: '78%' }]} />
          <ThemedText style={styles.budgetText}>78% Affordability Index</ThemedText>
        </View>
      </View>

      <View style={styles.section}>
        <ThemedText style={styles.sectionTitle}>AI Safety Features</ThemedText>
        <View style={styles.safetyScores}>
          <View style={styles.safetyScore}>
            <ThemedText style={styles.safetyValue}>95%</ThemedText>
            <ThemedText style={styles.safetyLabel}>Trust Score</ThemedText>
          </View>
          <View style={styles.safetyScore}>
            <ThemedText style={styles.safetyValue}>A+</ThemedText>
            <ThemedText style={styles.safetyLabel}>Safety Index</ThemedText>
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
  header: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  scoreSection: {
    alignItems: 'center',
    padding: 24,
  },
  scoreCircle: {
    width: 150,
    height: 150,
    borderRadius: 75,
    backgroundColor: '#F8F9FA',
    alignItems: 'center',
    justifyContent: 'center',
  },
  scoreText: {
    fontSize: 36,
    fontWeight: 'bold',
    color: '#1E293B',
  },
  changeText: {
    fontSize: 14,
    color: '#4CAF50',
    marginTop: 4,
  },
  section: {
    padding: 16,
    borderTopWidth: 1,
    borderTopColor: '#eee',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 16,
  },
  featureRow: {
    marginBottom: 12,
  },
  featureName: {
    marginBottom: 8,
  },
  progressBar: {
    height: 8,
    backgroundColor: '#F0F0F0',
    borderRadius: 4,
  },
  progress: {
    height: '100%',
    backgroundColor: '#1E293B',
    borderRadius: 4,
  },
  synergyPoints: {
    gap: 12,
  },
  synergyPoint: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  synergyText: {
    fontSize: 16,
  },
  budgetBar: {
    height: 40,
    backgroundColor: '#F0F0F0',
    borderRadius: 8,
    overflow: 'hidden',
  },
  budgetProgress: {
    height: '100%',
    backgroundColor: '#4CAF50',
  },
  budgetText: {
    position: 'absolute',
    width: '100%',
    textAlign: 'center',
    lineHeight: 40,
    color: '#fff',
    fontWeight: '600',
  },
  safetyScores: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  safetyScore: {
    alignItems: 'center',
  },
  safetyValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#4CAF50',
  },
  safetyLabel: {
    fontSize: 14,
    color: '#666',
    marginTop: 4,
  },
});