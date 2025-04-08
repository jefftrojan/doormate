import tensorflow as tf
import joblib
import numpy as np
from typing import Dict, List
import os

class MatchingModel:
    def __init__(self):
        try:
            # Try to load the trained model and scaler
            self.model = tf.keras.models.load_model('roommate_matching_model.h5')
            self.scaler = joblib.load('feature_scaler.pkl')
            self.use_ml_model = True
            print("ML model loaded successfully!")
        except Exception as e:
            # If model loading fails, use fallback similarity-based matching
            print(f"Failed to load ML model: {e}. Using fallback matching algorithm.")
            self.use_ml_model = False
            # Define weights for fallback algorithm
            self.weights = {
                'cleanliness': 0.25,
                'noiseLevel': 0.20,
                'studyHabits': 0.15,
                'sleepSchedule': 0.15,
                'socialLevel': 0.15,
                'budget': 0.10,
            }

    def preprocess_preferences(self, preferences: Dict) -> np.ndarray:
        """Transform user preferences into model input features"""
        features = [
            preferences.get('cleanliness', 3),
            preferences.get('noiseLevel', 50),
            preferences.get('budget', 1000),
            self._encode_study_habits(preferences.get('studyHabits', 'afternoon')),
        ]
        return self.scaler.transform([features])

    def _encode_study_habits(self, habit: str) -> int:
        """Encode string study habits into numeric values for the model"""
        habits_map = {'morning': 0, 'afternoon': 1, 'night': 2}
        return habits_map.get(habit.lower(), 1)

    def predict_compatibility(self, user_prefs: Dict, other_prefs: Dict) -> float:
        """Predict compatibility between two users based on their preferences"""
        if not user_prefs or not other_prefs:
            return 0.5  # Default score if preferences are missing
            
        try:
            if self.use_ml_model:
                # Use the ML model for prediction
                user_features = self.preprocess_preferences(user_prefs)
                other_features = self.preprocess_preferences(other_prefs)
                
                # Combine features for prediction
                combined_features = np.concatenate([user_features, other_features], axis=1)
                compatibility_score = self.model.predict(combined_features)[0][0]
                return float(compatibility_score)
            else:
                # Use fallback algorithm
                return self._calculate_fallback_compatibility(user_prefs, other_prefs)
        except Exception as e:
            print(f"Error in compatibility prediction: {e}")
            # Fallback to rule-based compatibility if ML prediction fails
            return self._calculate_fallback_compatibility(user_prefs, other_prefs)
    
    def _calculate_fallback_compatibility(self, user_prefs: Dict, other_prefs: Dict) -> float:
        """Fallback method for calculating compatibility if ML model fails"""
        # Calculate similarity for each preference type
        similarity_scores = []
        
        # Cleanliness (1-5 scale)
        if 'cleanliness' in user_prefs and 'cleanliness' in other_prefs:
            user_clean = user_prefs['cleanliness']
            other_clean = other_prefs['cleanliness']
            # Perfect match if exactly same, decreasing score as difference increases
            clean_similarity = 1.0 - (abs(user_clean - other_clean) / 4.0)
            similarity_scores.append(('cleanliness', clean_similarity))
        
        # Noise tolerance (percentage 0-100)
        if 'noiseLevel' in user_prefs and 'noiseLevel' in other_prefs:
            user_noise = user_prefs['noiseLevel']
            other_noise = other_prefs['noiseLevel']
            # Calculate similarity based on difference
            noise_similarity = 1.0 - (abs(user_noise - other_noise) / 100.0)
            similarity_scores.append(('noiseLevel', noise_similarity))
        
        # Study habits (string categories)
        if 'studyHabits' in user_prefs and 'studyHabits' in other_prefs:
            user_study = str(user_prefs['studyHabits']).lower()
            other_study = str(other_prefs['studyHabits']).lower()
            
            # Perfect match for same study habits
            study_similarity = 1.0 if user_study == other_study else 0.3
            similarity_scores.append(('studyHabits', study_similarity))
        
        # Budget range
        if 'budget' in user_prefs and 'budget' in other_prefs:
            try:
                user_budget = float(user_prefs['budget'])
                other_budget = float(other_prefs['budget'])
                
                # Normalize by $500 difference (higher difference = lower similarity)
                budget_diff = abs(user_budget - other_budget)
                budget_similarity = max(0, 1.0 - (budget_diff / 500.0))
                similarity_scores.append(('budget', budget_similarity))
            except (ValueError, TypeError):
                pass
        
        # Calculate weighted average
        total_weight = 0.0
        weighted_sum = 0.0
        
        for feature, score in similarity_scores:
            weight = self.weights.get(feature, 0.1)  # Default weight if not specified
            weighted_sum += score * weight
            total_weight += weight
        
        # If we couldn't calculate any scores, return neutral 0.5
        if total_weight == 0:
            return 0.5
            
        # Return weighted average
        return weighted_sum / total_weight