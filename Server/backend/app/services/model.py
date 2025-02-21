import tensorflow as tf
import joblib
import numpy as np
from typing import Dict, List

class MatchingModel:
    def __init__(self):
        self.model = tf.keras.models.load_model('models/roommate_matching_model.h5')
        self.scaler = joblib.load('models/feature_scaler.pkl')

    def preprocess_preferences(self, preferences: Dict) -> np.ndarray:
        features = [
            preferences.get('cleanliness', 3),
            preferences.get('noiseLevel', 50),
            preferences.get('budget', 1000),
            self._encode_study_habits(preferences.get('studyHabits', 'afternoon')),
        ]
        return self.scaler.transform([features])

    def _encode_study_habits(self, habit: str) -> int:
        habits_map = {'morning': 0, 'afternoon': 1, 'night': 2}
        return habits_map.get(habit.lower(), 1)

    def predict_compatibility(self, user_prefs: Dict, other_prefs: Dict) -> float:
        user_features = self.preprocess_preferences(user_prefs)
        other_features = self.preprocess_preferences(other_prefs)
        
        # Combine features for prediction
        combined_features = np.concatenate([user_features, other_features], axis=1)
        compatibility_score = self.model.predict(combined_features)[0][0]
        
        return float(compatibility_score)