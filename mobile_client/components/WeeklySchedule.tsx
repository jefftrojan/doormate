import React from 'react';
import { View, Text, StyleSheet, Dimensions } from 'react-native';

const DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const HOURS = Array.from({ length: 24 }, (_, i) => i);

interface WeeklyScheduleProps {
  schedule: boolean[][];  // 7x24 array representing busy hours
  matchSchedule?: boolean[][];  // Optional matching schedule for comparison
}

export default function WeeklySchedule({ schedule, matchSchedule }: WeeklyScheduleProps) {
  const cellWidth = (Dimensions.get('window').width - 60) / 24;
  
  return (
    <View style={styles.container}>
      <View style={styles.timeLabels}>
        {[0, 6, 12, 18, 23].map(hour => (
          <Text key={hour} style={styles.timeLabel}>
            {hour === 0 ? '12am' : hour === 12 ? '12pm' : hour > 12 ? `${hour-12}pm` : `${hour}am`}
          </Text>
        ))}
      </View>

      {DAYS.map((day, dayIndex) => (
        <View key={day} style={styles.dayRow}>
          <Text style={styles.dayLabel}>{day}</Text>
          <View style={styles.hourCells}>
            {HOURS.map((hour) => (
              <View
                key={hour}
                style={[
                  styles.cell,
                  { width: cellWidth },
                  schedule[dayIndex][hour] && styles.busyCell,
                  matchSchedule && matchSchedule[dayIndex][hour] && styles.matchCell,
                ]}
              />
            ))}
          </View>
        </View>
      ))}

      <View style={styles.legend}>
        <View style={styles.legendItem}>
          <View style={[styles.legendDot, styles.busyCell]} />
          <Text style={styles.legendText}>Your Schedule</Text>
        </View>
        {matchSchedule && (
          <View style={styles.legendItem}>
            <View style={[styles.legendDot, styles.matchCell]} />
            <Text style={styles.legendText}>Match's Schedule</Text>
          </View>
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 16,
    backgroundColor: '#fff',
    borderRadius: 12,
  },
  timeLabels: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginLeft: 50,
    marginBottom: 8,
  },
  timeLabel: {
    fontSize: 12,
    color: '#666',
  },
  dayRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  dayLabel: {
    width: 40,
    fontSize: 12,
    color: '#666',
  },
  hourCells: {
    flexDirection: 'row',
    flex: 1,
  },
  cell: {
    height: 24,
    borderWidth: 0.5,
    borderColor: '#E2E8F0',
  },
  busyCell: {
    backgroundColor: '#8B4513',
  },
  matchCell: {
    backgroundColor: '#4CAF50',
    opacity: 0.5,
  },
  legend: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 16,
    gap: 16,
  },
  legendItem: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  legendDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginRight: 8,
  },
  legendText: {
    fontSize: 12,
    color: '#666',
  },
});