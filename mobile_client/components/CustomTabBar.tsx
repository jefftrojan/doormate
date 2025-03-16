import React from 'react';
import { View, TouchableOpacity, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { ThemedText } from '@/components/ThemedText';
import { BottomTabBarProps } from '@react-navigation/bottom-tabs';

type IconName = keyof typeof Ionicons.glyphMap;

type IconMapping = {
  [key: string]: {
    default: IconName;
    outline: IconName;
  };
};

export function CustomTabBar({ state, descriptors, navigation }: BottomTabBarProps) {
  const iconMapping: IconMapping = {
    home: {
      default: 'home',
      outline: 'home-outline'
    },
    search: {
      default: 'search',
      outline: 'search-outline'
    },
    chat: {
      default: 'chatbubble',
      outline: 'chatbubble-outline'
    },
    profile: {
      default: 'person',
      outline: 'person-outline'
    }
  };

  return (
    <View style={styles.container}>
      {state.routes.map((route, index) => {
        const { options } = descriptors[route.key];
        const isFocused = state.index === index;

        let labelText: string;
        if (typeof options.tabBarLabel === 'function') {
          labelText = route.name;
        } else {
          labelText = (options.tabBarLabel || options.title || route.name) as string;
        }

        const routeIcons = iconMapping[route.name.toLowerCase()] || {
          default: 'help-circle',
          outline: 'help-circle-outline'
        };

        return (
          <TouchableOpacity
            key={route.key}
            style={styles.tab}
            onPress={() => navigation.navigate(route.name)}
          >
            <Ionicons
              name={isFocused ? routeIcons.default : routeIcons.outline}
              size={24}
              color={isFocused ? '#8B4513' : '#666'}
            />
            <ThemedText
              style={[
                styles.label,
                { color: isFocused ? '#8B4513' : '#666' }
              ]}
            >
              {labelText}
            </ThemedText>
          </TouchableOpacity>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    backgroundColor: '#fff',
    paddingBottom: 20,
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#f0f0f0',
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.1,
    shadowRadius: 3,
  },
  tab: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  label: {
    fontSize: 12,
    marginTop: 4,
  },
});