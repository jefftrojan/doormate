import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { ThemedText } from '@/components/ThemedText';
import { MaterialCommunityIcons } from '@expo/vector-icons';

export default function MatchDetailsScreen() {
  return (
    <SafeAreaView edges={['top']} style={styles.container}>
      <View style={styles.header}>
        <ThemedText style={styles.headerTitle}>AI Match Analysis</ThemedText>
      </View>

      <ScrollView style={styles.content}>
        {/* Match Score */}
        <View style={styles.scoreCircle}>
          <ThemedText style={styles.scoreText}>87%</ThemedText>
          <ThemedText style={styles.changeText}>+5% this week</ThemedText>
        </View>

        {/* Feature Analysis */}
        <View style={styles.section}>
          <ThemedText style={styles.sectionTitle}>Feature Analysis</ThemedText>
          <View style={styles.featureItem}>
            <ThemedText>Communication</ThemedText>
            <View style={styles.progressBar}>
              <View style={[styles.progress, { width: '90%' }]} />
            </View>
          </View>
          <View style={styles.featureItem}>
            <ThemedText>Interests</ThemedText>
            <View style={styles.progressBar}>
              <View style={[styles.progress, { width: '85%' }]} />
            </View>
          </View>
        </View>

        {/* Lifestyle Match */}
        <View style={styles.section}>
          <ThemedText style={styles.sectionTitle}>Lifestyle Match</ThemedText>
          <View style={styles.matchList}>
            <View style={styles.matchItem}>
              <MaterialCommunityIcons name="check-circle" size={24} color="#4CAF50" />
              <ThemedText style={styles.matchText}>Morning Exercise</ThemedText>
            </View>
            <View style={styles.matchItem}>
              <MaterialCommunityIcons name="check-circle" size={24} color="#4CAF50" />
              <ThemedText style={styles.matchText}>Evening Study</ThemedText>
            </View>
          </View>
        </View>

        {/* Budget Compatibility */}
        <View style={styles.section}>
          <ThemedText style={styles.sectionTitle}>Budget Compatibility</ThemedText>
          <View style={styles.affordabilityBar}>
            <View style={[styles.affordabilityProgress, { width: '78%' }]}>
              <ThemedText style={styles.affordabilityText}>78% Affordability Index</ThemedText>
            </View>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    padding: 16,
    backgroundColor: '#fff',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '600',
  },
  content: {
    flex: 1,
  },
  scoreCircle: {
    width: 160,
    height: 160,
    borderRadius: 80,
    backgroundColor: '#f8f8f8',
    alignItems: 'center',
    justifyContent: 'center',
    alignSelf: 'center',
    marginVertical: 24,
  },
  scoreText: {
    fontSize: 36,
    fontWeight: 'bold',
  },
  changeText: {
    fontSize: 14,
    color: '#4CAF50',
    marginTop: 4,
  },
  section: {
    padding: 16,
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '600',
    marginBottom: 16,
  },
  featureItem: {
    marginBottom: 16,
  },
  progressBar: {
    height: 8,
    backgroundColor: '#f0f0f0',
    borderRadius: 4,
    marginTop: 8,
  },
  progress: {
    height: '100%',
    backgroundColor: '#1a1a1a',
    borderRadius: 4,
  },
  matchList: {
    backgroundColor: '#f8f8f8',
    borderRadius: 8,
    padding: 16,
  },
  matchItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  matchText: {
    marginLeft: 12,
    fontSize: 16,
  },
  affordabilityBar: {
    height: 44,
    backgroundColor: '#f0f0f0',
    borderRadius: 8,
  },
  affordabilityProgress: {
    height: '100%',
    backgroundColor: '#4CAF50',
    borderRadius: 8,
    justifyContent: 'center',
    paddingHorizontal: 16,
  },
  affordabilityText: {
    color: '#fff',
    fontWeight: '500',
  },
});

