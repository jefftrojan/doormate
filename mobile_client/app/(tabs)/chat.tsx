import React from 'react';
import { View, StyleSheet, FlatList } from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import { Ionicons } from '@expo/vector-icons';
import { TouchableOpacity } from 'react-native';
import { Image } from 'react-native';
import { useRouter } from 'expo-router';

interface ChatMessage {
  id: string;
  name: string;
  message: string;
  timestamp: string;
  avatar: string;
  unread?: boolean;
}

export default function Chat() {
  const router = useRouter();
  
  const messages: ChatMessage[] = [
    {
      id: '1',
      name: 'Sarah Miller',
      message: 'Hey, I\'m interested in viewing the apartment...',
      timestamp: '2:34 PM',
      avatar: 'https://example.com/avatar1.jpg',
      unread: true,
    },
    // Add more message data
  ];

  const renderMessage = ({ item }: { item: ChatMessage }) => (
    <TouchableOpacity 
      style={styles.messageItem}
      onPress={() => router.push({
        pathname: '/(tabs)/chat/[id]',
        params: { id: item.id }
      })}
    >
      <Image 
        source={{ uri: item.avatar }}
        style={styles.avatar}
        defaultSource={require('@/assets/images/default-avatar.png')}
      />
      <View style={styles.messageContent}>
        <View style={styles.messageHeader}>
          <ThemedText style={styles.name}>{item.name}</ThemedText>
          <ThemedText style={styles.timestamp}>{item.timestamp}</ThemedText>
        </View>
        <ThemedText 
          style={[styles.message, item.unread && styles.unread]}
          numberOfLines={1}
        >
          {item.message}
        </ThemedText>
      </View>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <ThemedText style={styles.title}>Messages</ThemedText>
      </View>
      <FlatList
        data={messages}
        renderItem={renderMessage}
        keyExtractor={item => item.id}
        contentContainerStyle={styles.messageList}
      />
    </View>
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
  messageList: {
    padding: 16,
  },
  messageItem: {
    flexDirection: 'row',
    padding: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  avatar: {
    width: 50,
    height: 50,
    borderRadius: 25,
    marginRight: 12,
  },
  messageContent: {
    flex: 1,
  },
  messageHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 4,
  },
  name: {
    fontSize: 16,
    fontWeight: '600',
  },
  timestamp: {
    fontSize: 14,
    color: '#666',
  },
  message: {
    fontSize: 14,
    color: '#666',
  },
  unread: {
    fontWeight: '600',
    color: '#000',
  },
});