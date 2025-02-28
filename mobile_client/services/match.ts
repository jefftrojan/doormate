import api from '@/services/api';

export interface ScheduleData {
  userId: string;
  weeklySchedule: boolean[][];
  compatibility?: {
    overall: number;
    lifestyle: number;
    schedule: number;
    budget: number;
    conflicts: string[];
  };
  preferences: {
    lifestyle: string[];
    budget: {
      min: number;
      max: number;
    };
  };
}

export interface User {
  weeklySchedule: boolean[][];
}

export const matchService = {
  async getNextMatchId(): Promise<string | null> {
    try {
      const response = await api.get('/matches/next');
      return response.data.matchId;
    } catch (error) {
      console.error('Error getting next match:', error);
      return null;
    }
  },

  async getUserSchedule(userId: string): Promise<User> {
    const response = await api.get(`/users/${userId}/schedule`);
    return response.data;
  },

  async getMatchProfile(matchId: string): Promise<ScheduleData> {
    const response = await api.get(`/matches/${matchId}`);
    return response.data;
  },

  async getScheduleCompatibility(userId: string, matchId: string) {
    const response = await api.get(`/matches/${matchId}/compatibility/${userId}`);
    return response.data;
  }
};