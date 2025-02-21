from fastapi import BackgroundTasks
import tensorflow as tf
import numpy as np
from datetime import datetime, timedelta
import joblib
import os

async def save_model_metrics(db, model, X, y, version):
    # Evaluate model
    evaluation = model.evaluate(X, y, verbose=0)
    
    metrics = ModelMetrics(
        version=version,
        accuracy=float(evaluation[1]),
        loss=float(evaluation[0]),
        validation_accuracy=float(evaluation[1]),  # Using same data for demo
        validation_loss=float(evaluation[0]),
        training_samples=len(X)
    )
    
    await db.model_metrics.insert_one(metrics.dict())

# Update retrain_model function
async def retrain_model(db):
    try:
        # Get training data from feedback
        training_data = await db.matching_data.find({
            "feedback_rating": {"$exists": True},
            "created_at": {"$gte": datetime.utcnow() - timedelta(days=30)}
        }).to_list(length=1000)

        if len(training_data) < 100:
            return False

        # Prepare features and labels
        X = []
        y = []
        for data in training_data:
            features = np.concatenate([
                _extract_features(data["user1_preferences"]),
                _extract_features(data["user2_preferences"])
            ])
            X.append(features)
            y.append(1.0 if data["match_success"] else 0.0)

        X = np.array(X)
        y = np.array(y)

        # Train new model
        model = tf.keras.Sequential([
            tf.keras.layers.Dense(64, activation='relu', input_shape=(X.shape[1],)),
            tf.keras.layers.Dropout(0.2),
            tf.keras.layers.Dense(32, activation='relu'),
            tf.keras.layers.Dense(1, activation='sigmoid')
        ])

        model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
        model.fit(X, y, epochs=50, batch_size=32, validation_split=0.2)

        # Save new model with timestamp
        timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
        model.save(f'models/roommate_matching_model_{timestamp}.h5')

        # Save metrics after successful training
        version = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
        await save_model_metrics(db, model, X, y, version)
        
        return True
    except Exception as e:
        print(f"Model retraining failed: {str(e)}")
        return False

def _extract_features(preferences):
    return np.array([
        preferences.get('cleanliness', 3),
        preferences.get('noiseLevel', 50),
        preferences.get('budget', 1000),
        _encode_study_habits(preferences.get('studyHabits', 'afternoon'))
    ])

def _encode_study_habits(habit):
    habits_map = {'morning': 0, 'afternoon': 1, 'night': 2}
    return habits_map.get(str(habit).lower(), 1)