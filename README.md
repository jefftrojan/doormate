# DoorMate - Housing Matchmaking System for Students in Rwanda

## Project Overview

DoorMate is an AI-powered mobile application designed to address the student housing challenges in Rwanda, particularly in Kigali. The system provides a secure platform for students to find compatible roommates based on factors such as academic schedules, lifestyle preferences, and budget constraints. The application features robust verification mechanisms to ensure user safety and uses AI-driven matching algorithms to improve compatibility between potential roommates.

This project was developed as a BSc. in Software Engineering thesis by Jeffrey Karau Dauda, supervised by David Neza Tuyishimire, and completed in March 2025.

More info on the terms guiding the use of this project is available at https://doormate.xyz/terms-and-conditions

## Key Features

- **User Registration & Verification**: Secure student verification through university email, phone verification, and student ID validation
- **AI-Powered Matching Algorithm**: Smart matching based on compatibility factors like study habits, sleep schedules, and budget
- **Voice Assistant Integration**: AI-powered voice agent to assist with housing searches and roommate recommendations
- **In-App Messaging**: Secure communication channel between potential roommates
- **Property Search**: Location-based housing search with map integration
- **Mobile-First Design**: Cross-platform application optimized for Android and iOS devices

## Technology Stack

### Frontend
- **Framework**: Flutter
- **State Management**: Provider
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences

### Backend
- **Framework**: Python (FastAPI)
- **Database**: MongoDB Atlas
- **Authentication**: JWT
- **Data Validation**: Pydantic

### AI/ML Components
- **Machine Learning**: TensorFlow.js
- **Data Processing**: scikit-learn
- **Vector Search**: PineCone
- **Voice Agent**: Retell AI

### Cloud Services
- **Hosting**: AWS EC2
- **Storage**: AWS S3
- **Monitoring**: AWS CloudWatch
- **Deployment**: Render

## Project Structure

```
doormate/
├── client/                     # Mobile application (Flutter)
│   ├── lib/
│   │   ├── models/             # Data models
│   │   ├── screens/            # UI screens
│   │   ├── services/           # API services
│   │   ├── utils/              # Helper utilities
│   │   ├── widgets/            # Reusable UI components
│   │   └── main.dart           # Application entry point
│   ├── assets/                 # Images, fonts, etc.
│   └── test/                   # Frontend tests
│
├── Server/                     # Backend server (FastAPI)
│   ├── api/                    # API endpoints
│   │   ├── auth.py             # Authentication endpoints
│   │   ├── profiles.py         # Profile management endpoints
│   │   ├── matching.py         # Roommate matching endpoints
│   │   ├── listings.py         # Property listing endpoints
│   │   └── chat.py             # Chat functionality endpoints
│   ├── ModelNotebook/          # Data models
│   ├── services/               # Business logic
│   │   ├── ai_matching.py      # AI matching algorithms
│   │   ├── verification.py     # User verification services
│   │   └── voice_agent.py      # Voice assistant integration
│   ├── utils/                  # Helper utilities
│   ├── tests/                  # Backend tests
│   └── main.py                 # Server entry point
│
└── assets/                     # assets
               
```

## Prerequisites

To run the DoorMate system, you'll need:

1. **Python 3.9+** - For backend development
2. **Flutter SDK** - For mobile application development
3. **MongoDB Atlas Account** - For database hosting
4. **AWS Account** - For cloud services
5. **Node.js v18.x** - For certain development tools

## Installation & Setup

### Backend Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/jefftrojan/doormate.git
   cd doormate/server
   ```

2. **Create and activate a virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**:
   Create a `.env` file in the server directory with the following variables:
   ```
   MONGODB_URI=your_mongodb_connection_string
   JWT_SECRET=your_jwt_secret
   AWS_ACCESS_KEY=your_aws_access_key
   AWS_SECRET_KEY=your_aws_secret_key
   PINECONE_API_KEY=your_pinecone_api_key
   RETELL_API_KEY=your_retell_api_key
   OPENAI_API_KEY=your_openai_api_key

   ```

5. **Run the development server**:
   ```bash
   uvicorn main:app --reload
   ```
   The API server will be accessible at `http://localhost:8000`.

### Frontend Setup

1. **Navigate to the mobile client directory**:
   ```bash
   cd ../client
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Set up environment configuration**:
   Create a `.env` file in the `client` directory with:
   ```
   API_BASE_URL=http://localhost:8000
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   ```

4. **Run the application**:
   ```bash
   flutter run
   ```

## Testing

### Backend Testing

Run backend tests using pytest:
```bash
cd Server/backend
pytest
```

### Frontend Testing

Run Flutter tests:
```bash
cd client
flutter test
```

## API Documentation

The API documentation is available at `http://localhost:8000/docs` when the server is running. This Swagger UI provides a comprehensive overview of all available endpoints with request/response examples.

### Key Endpoints

- **Authentication**:
  - `POST /api/auth/register` - Register a new user
  - `POST /api/auth/login` - Authenticate a user
  - `POST /api/auth/verify` - Verify a user's credentials

- **Profiles**:
  - `GET /api/profiles/{user_id}` - Get user profile
  - `PUT /api/profiles/{user_id}` - Update user profile
  - `POST /api/profiles/preferences` - Set user preferences

- **Matching**:
  - `GET /api/matching/recommendations` - Get roommate recommendations
  - `POST /api/matching/compatibility` - Calculate compatibility between users

- **Properties**:
  - `GET /api/listings` - Get property listings
  - `GET /api/listings/{location}` - Get listings by location

- **Chat**:
  - `GET /api/chat/{match_id}` - Get chat messages
  - `POST /api/chat/{match_id}` - Send a message

## Deployment

### Backend Deployment

1. **Set up AWS EC2 instance**:
   - Launch an EC2 instance with Ubuntu 20.04
   - Configure security groups to allow HTTP/HTTPS traffic

2. **Deploy the FastAPI application**:
   ```bash
   ssh -i your-key.pem ubuntu@your-ec2-instance
   git clone https://github.com/jefftrojamn/doormate.git
   cd doormate/server
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. **Set up Gunicorn and Nginx**:
   - Install and configure Gunicorn as the WSGI server
   - Set up Nginx as a reverse proxy

4. **Configure environment variables**:
   - Add production environment variables to the server

### Frontend Deployment

1. **Build the Flutter application**:
   ```bash
   cd mobile_client_flutter
   flutter build apk --release  # For Android
   flutter build ios --release  # For iOS
   ```

2. **Distribute the application**:
   - Upload APK to Google Play Store
   - Submit iOS build to App Store

## AI Matching Algorithm

The AI matching algorithm is central to DoorMate's functionality, using the following components:

1. **Data Collection**: User preferences including academic schedules, lifestyle preferences, and budget constraints.

2. **Feature Extraction**: Converting raw data into numerical features for the machine learning model.

3. **Compatibility Scoring**: Using collaborative filtering techniques to predict compatibility between potential roommates.

4. **Recommendation Generation**: Presenting the most compatible matches to users based on scoring.

The system continuously improves by incorporating feedback from successful and unsuccessful matches to refine prediction accuracy.

## Security Features

DoorMate implements several security measures:

1. **User Verification**: Multi-factor authentication including university email verification and phone validation.

2. **Data Protection**: Secure data storage with encryption for sensitive information.

3. **Privacy Controls**: Customizable privacy settings allowing users to control their shared information.

4. **Secure Communication**: End-to-end encrypted messaging between potential roommates.

5. **Regular Security Audits**: Continuous vulnerability assessments and penetration testing.

## Troubleshooting

### Common Issues

1. **Database Connection Errors**:
   - Verify MongoDB Atlas connection string in .env file
   - Check network connectivity to MongoDB servers

2. **API Request Failures**:
   - Confirm the backend server is running
   - Verify API base URL in the Flutter application

3. **Authentication Problems**:
   - Check JWT secret configuration
   - Ensure user credentials are correct

4. **AI Services Integration**:
   - Verify API keys for PineCone and Retell AI
   - Check service availability and quotas

### Debug Logging

Enable debug logging in the backend:
```python
# In main.py
import logging
logging.basicConfig(level=logging.DEBUG)
```

Enable verbose logging in Flutter:
```bash
flutter run --verbose
```

## Contributing

To contribute to the DoorMate project:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.



## Acknowledgements

- David Neza Tuyishimire - Project Supervisor
- African Leadership University (ALU)
