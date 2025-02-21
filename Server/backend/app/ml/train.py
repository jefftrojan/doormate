import tensorflow as tf
import numpy as np
from sklearn.preprocessing import StandardScaler
import joblib

def create_model():
    model = tf.keras.Sequential([
        tf.keras.layers.Dense(64, activation='relu', input_shape=(8,)),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Dense(32, activation='relu'),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Dense(16, activation='relu'),
        tf.keras.layers.Dense(1, activation='sigmoid')
    ])
    
    model.compile(
        optimizer='adam',
        loss='binary_crossentropy',
        metrics=['accuracy']
    )
    return model

def train_model(X_train, y_train, epochs=50):
    model = create_model()
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X_train)
    
    model.fit(
        X_scaled, y_train,
        epochs=epochs,
        validation_split=0.2,
        verbose=1
    )
    
    # Save model and scaler
    model.save('models/roommate_matching_model.h5')
    joblib.dump(scaler, 'models/feature_scaler.pkl')
    
    return model, scaler