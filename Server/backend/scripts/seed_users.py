import asyncio
import random
from datetime import datetime
from bson import ObjectId
from pymongo import MongoClient
import bcrypt
import sys
import os

# Update this path to point to your app directory
sys.path.append(os.path.abspath("."))

# MongoDB connection string - update with your actual connection string
MONGO_URL = "mongodb+srv://admin:admin123@cluster0.d0ili.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
DB_NAME = "doormate"  

# Sample data
FIRST_NAMES = ["Alex", "Jordan", "Taylor", "Morgan", "Casey", "Riley", "Avery", "Quinn", 
               "Skylar", "Dakota", "Reese", "Finley", "Kai", "Sage", "Charlie", "Blake"]

LAST_NAMES = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
              "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Lee"]

# Universities in Kigali, Rwanda
UNIVERSITIES = [
    "University of Rwanda (UR)",
    "African Leadership University (ALU)",
    "Carnegie Mellon University Africa (CMU Africa)",
    "Mount Kenya University (MKU) Rwanda",
    "Adventist University of Central Africa (AUCA)",
    "University of Kigali (UoK)",
    "Rwanda Polytechnic (RP)",
    "Kigali Independent University (ULK)",
    "University of Tourism Technology and Business Studies (UTB)",
    "Institut Catholique de Kabgayi (ICK)"
]

INTERESTS = ["Reading", "Gaming", "Cooking", "Sports", "Music", "Art", "Travel", "Movies", 
             "Photography", "Hiking", "Dancing", "Writing", "Technology", "Fashion", "Yoga", "History"]

MAJORS = ["Computer Science", "Business", "Engineering", "Biology", "Psychology", "English",
          "Mathematics", "Chemistry", "Economics", "Art", "Physics", "Sociology", "History", "Medicine"]

STUDY_HABITS = ["Casual", "Moderate", "Intense"]
SOCIAL_LEVELS = ["Very Private", "Balanced", "Very Social"]
WAKE_UP_TIMES = ["5:00 AM", "6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "Later"]
SLEEP_TIMES = ["9:00 PM", "10:00 PM", "11:00 PM", "12:00 AM", "1:00 AM", "2:00 AM", "Later"]

# Areas in Kigali
AREAS = ["Nyarugenge", "Kacyiru", "Kimihurura", "Gacuriro", "Gikondo", "Kimironko", "Remera", "Kicukiro"]

PROFILE_IMAGES = [
    "https://randomuser.me/api/portraits/men/1.jpg",
    "https://randomuser.me/api/portraits/women/1.jpg",
    "https://randomuser.me/api/portraits/men/2.jpg",
    "https://randomuser.me/api/portraits/women/2.jpg",
    "https://randomuser.me/api/portraits/men/3.jpg",
    "https://randomuser.me/api/portraits/women/3.jpg",
    "https://randomuser.me/api/portraits/men/4.jpg",
    "https://randomuser.me/api/portraits/women/4.jpg",
    "https://randomuser.me/api/portraits/men/5.jpg",
    "https://randomuser.me/api/portraits/women/5.jpg",
]

def generate_random_user():
    """Generate random user data"""
    first_name = random.choice(FIRST_NAMES)
    last_name = random.choice(LAST_NAMES)
    email = f"{first_name.lower()}.{last_name.lower()}@example.com"
    
    # Hash a simple password
    password = "password123"
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    
    # Select a university
    university = random.choice(UNIVERSITIES)
    
    # Generate user profile
    profile = {
        "fullName": f"{first_name} {last_name}",
        "email": email,
        "university": university,
        "major": random.choice(MAJORS),
        "yearOfStudy": random.randint(1, 4),
        "interests": random.sample(INTERESTS, random.randint(2, 5)),
        "bio": f"Hi, I'm {first_name}! I'm studying at {university} and looking for a roommate in Kigali.",
        "profilePhoto": random.choice(PROFILE_IMAGES),
        "phoneNumber": f"+250{random.randint(700000000, 799999999)}",  # Rwanda phone format
    }
    
    # Generate preferences
    preferences = {
        "lifestyle": {
            "cleanliness": random.randint(1, 5),
            "noiseLevel": random.uniform(10, 90),
            "studyHabits": random.choice(STUDY_HABITS),
            "socialLevel": random.choice(SOCIAL_LEVELS),
            "wakeUpTime": random.choice(WAKE_UP_TIMES),
            "sleepTime": random.choice(SLEEP_TIMES)
        },
        "location": {
            "preferredArea": random.choice(AREAS),
            "maxDistance": random.uniform(1, 20),
            "budget": random.randint(100000, 500000),  # Budget in Rwandan Francs
            "hasTransportation": random.choice([True, False])
        }
    }
    
    # Create user document
    user = {
        "_id": ObjectId(),
        "email": email,
        "password": hashed_password,
        "profile": profile,
        "preferences": preferences,
        "isActive": True,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
        "confirmed_matches": [],
        "saved_listings": []
    }
    
    return user

async def seed_database(num_users=20):
    """Seed the database with sample users"""
    client = MongoClient(MONGO_URL)
    db = client[DB_NAME]
    
    # Check if there are already users
    existing_count = db.users.count_documents({})
    print(f"Found {existing_count} existing users in the database")
    
    # Generate and insert users
    users = [generate_random_user() for _ in range(num_users)]
    
    if users:
        result = db.users.insert_many(users)
        print(f"Successfully inserted {len(result.inserted_ids)} new users")
    
    client.close()
    print("Database seeding completed!")

if __name__ == "__main__":
    # Run the seed function
    asyncio.run(seed_database(20))  # Create 20 sample users