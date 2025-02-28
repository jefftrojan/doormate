import React, {useEffect, useState} from 'react';
import {
  View,
  Text,
  StyleSheet,
  Image,
  TouchableOpacity,
  ScrollView,
  ActivityIndicator,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import MatchAnalysis from '@/components/MatchAnalysis';
import WeeklySchedule from '@/components/WeeklySchedule';
import { useLocalSearchParams } from 'expo-router';
import { matchService, ScheduleData } from '@/services/match';
import { useAuth } from '@/contexts/AuthContext';

export default function MatchScreen() {
  const { user } = useAuth();
  const { id: matchId } = useLocalSearchParams();
  const [matchData, setMatchData] = useState<ScheduleData | null>(null);
  const [userSchedule, setUserSchedule] = useState<boolean[][] | null>(null);
  const [loading, setLoading] = useState(true);
  const [profiles, setProfiles] = useState<ScheduleData[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [noMoreProfiles, setNoMoreProfiles] = useState(false);

  const handleNextProfile = async () => {
    if (currentIndex < profiles.length - 1) {
      setCurrentIndex(currentIndex + 1);
      setMatchData(profiles[currentIndex + 1]);
    } else {
      try {
        // Since getMoreMatches doesn't exist, we'll use getMatchProfile to get next match
        const nextMatchId = await matchService.getNextMatchId(); // You'll need to add this method
        if (nextMatchId) {
          const newProfile = await matchService.getMatchProfile(nextMatchId);
          if (newProfile) {
            setProfiles([...profiles, newProfile]);
            setCurrentIndex(currentIndex + 1);
            setMatchData(newProfile);
          } else {
            setNoMoreProfiles(true);
          }
        } else {
          setNoMoreProfiles(true);
        }
      } catch (error) {
        console.error('Error fetching more profiles:', error);
      }
    }
  };

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [matchProfile, userScheduleData] = await Promise.all([
          matchService.getMatchProfile(matchId as string),
          matchService.getUserSchedule(user?._id as string)
        ]);
        
        const compatibility = await matchService.getScheduleCompatibility(
          user?._id as string,
          matchId as string
        );
        
        setMatchData({ ...matchProfile, ...compatibility });
        setUserSchedule(userScheduleData.weeklySchedule);
      } catch (error) {
        console.error('Error fetching data:', error);
      } finally {
        setLoading(false);
      }
    };

    if (matchId && user) {
      fetchData();
    }
  }, [matchId, user]);

  if (loading) {
    return <ActivityIndicator style={styles.loader} />;
  }

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Image 
          source={require('@/assets/images/avatar.png')}
          style={styles.profileImage}
        />
        <View style={styles.verifiedBadge}>
          <Ionicons name="checkmark-circle" size={24} color="#4CAF50" />
          <Text style={styles.verifiedText}>Verified</Text>
        </View>
      </View>

      <View style={styles.infoSection}>
        <View style={styles.infoRow}>
          <Ionicons name="school-outline" size={20} color="#666" />
          <Text style={styles.infoText}>22, Junior Year</Text>
        </View>
        <View style={styles.infoRow}>
          <Ionicons name="location-outline" size={20} color="#666" />
          <Text style={styles.infoText}>2.5 miles away</Text>
        </View>
        <View style={styles.infoRow}>
          <Ionicons name="cash-outline" size={20} color="#666" />
          <Text style={styles.infoText}>rwf 200k-350k/mo</Text>
        </View>
      </View>

      {matchData && matchData.compatibility && (
        <MatchAnalysis
          overallCompatibility={matchData.compatibility.overall}
          lifestyle={matchData.compatibility.lifestyle}
          schedule={matchData.compatibility.schedule}
          budget={matchData.compatibility.budget}
          lifestyleTraits={matchData.preferences.lifestyle}
          budgetRange={matchData.preferences.budget}
          conflicts={matchData.compatibility.conflicts}
        />
      )}

      <View style={styles.scheduleSection}>
        <Text style={styles.sectionTitle}>Schedule Alignment</Text>
        {matchData && userSchedule && (
          <WeeklySchedule
            schedule={matchData.weeklySchedule}
            matchSchedule={userSchedule}
          />
        )}
      </View>

      <View style={styles.actionButtons}>
        <TouchableOpacity 
          style={styles.actionButton}
          onPress={handleNextProfile}
        >
          <Ionicons name="close" size={32} color="#FF3B30" />
        </TouchableOpacity>
        <TouchableOpacity 
          style={[styles.actionButton, styles.likeButton]}
          onPress={handleNextProfile}
        >
          <Ionicons name="heart" size={32} color="#fff" />
        </TouchableOpacity>
        <TouchableOpacity style={styles.actionButton}>
          <Ionicons name="bookmark-outline" size={32} color="#007AFF" />
        </TouchableOpacity>
      </View>

      {noMoreProfiles && (
        <View style={styles.noMoreProfiles}>
          <Text style={styles.noMoreProfilesText}>
            No more profiles available
          </Text>
        </View>
      )}
    </ScrollView>
  );
}

// Add to existing styles
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    alignItems: 'center',
    padding: 20,
  },
  profileImage: {
    width: '100%',
    height: 300,
    borderRadius: 20,
  },
  verifiedBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    position: 'absolute',
    top: 30,
    right: 30,
    backgroundColor: 'rgba(255,255,255,0.9)',
    padding: 8,
    borderRadius: 20,
  },
  verifiedText: {
    marginLeft: 4,
    color: '#4CAF50',
    fontWeight: '600',
  },
  infoSection: {
    padding: 20,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  infoText: {
    marginLeft: 8,
    fontSize: 16,
    color: '#333',
  },
  matchSection: {
    padding: 20,
    backgroundColor: '#F8F9FA',
  },
  matchHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  matchTitle: {
    fontSize: 20,
    fontWeight: '600',
  },
  matchPercentage: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#4CAF50',
  },
  matchItem: {
    marginBottom: 16,
  },
  matchLabel: {
    fontSize: 16,
    marginBottom: 8,
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
  scheduleSection: {
    padding: 20,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '600',
    marginBottom: 16,
  },
  scheduleGraph: {
    height: 200,
    backgroundColor: '#F8F9FA',
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  graphLabel: {
    color: '#666',
  },
  actionButtons: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    padding: 20,
    borderTopWidth: 1,
    borderTopColor: '#E2E8F0',
  },
  actionButton: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: '#fff',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  likeButton: {
    backgroundColor: '#8B4513',
  },
  loader: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  noMoreProfiles: {
    padding: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  noMoreProfilesText: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
  },
});