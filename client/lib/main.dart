import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile_client_flutter/services/api_client.dart';
import 'package:mobile_client_flutter/services/auth_service.dart';
import 'package:mobile_client_flutter/services/preferences_service.dart';
import 'package:mobile_client_flutter/services/listing_service.dart';
import 'package:mobile_client_flutter/services/match_service.dart';
import 'package:mobile_client_flutter/services/ai_assistant_service.dart';
import 'package:mobile_client_flutter/services/messaging_service.dart';
import 'package:mobile_client_flutter/services/agent_service.dart';
import 'package:mobile_client_flutter/services/housing_data_service.dart';
import 'package:mobile_client_flutter/providers/preferences_provider.dart';
import 'package:mobile_client_flutter/providers/profile_provider.dart';
import 'package:mobile_client_flutter/providers/listing_provider.dart';
import 'package:mobile_client_flutter/providers/match_provider.dart';
import 'package:mobile_client_flutter/providers/ai_assistant_provider.dart';
import 'package:mobile_client_flutter/providers/messaging_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/account_settings_screen.dart';
import 'screens/create_listing_screen.dart';
import 'screens/ai_assistant_screen.dart';
import 'screens/agent_chat_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/matches_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/listings_screen.dart';
import 'screens/listing_details_screen.dart';
import 'screens/map_view_screen.dart';
import 'screens/roommate_matching_screen.dart';
import 'utils/map_web_init.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

    // Initialize Maps for Web platform
  MapWebInitializer.ensureInitialized();
  
  // Initialize API client
  final apiClient = ApiClient();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PreferencesProvider(
            PreferencesService(apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(
            AuthService(apiClient),
          ),
        ),
        Provider<ApiClient>(
          create: (context) => apiClient,
        ),
        ProxyProvider<ApiClient, ListingService>(
          update: (context, apiClient, previous) => 
            ListingService(apiClient),
        ),
        ProxyProvider<ApiClient, MatchService>(
          update: (context, apiClient, previous) => 
            MatchService(apiClient),
        ),
        ProxyProvider<ApiClient, AIAssistantService>(
          update: (context, apiClient, previous) => 
            AIAssistantService(apiClient),
        ),
        ProxyProvider<ApiClient, MessagingService>(
          update: (context, apiClient, previous) => 
            MessagingService(apiClient),
        ),
        ChangeNotifierProxyProvider<ListingService, ListingProvider>(
          create: (context) => ListingProvider(
            Provider.of<ListingService>(context, listen: false),
          ),
          update: (context, listingService, previous) => 
            previous ?? ListingProvider(listingService),
        ),
        ChangeNotifierProxyProvider<MatchService, MatchProvider>(
          create: (context) => MatchProvider(
            Provider.of<MatchService>(context, listen: false),
          ),
          update: (context, matchService, previous) => 
            previous ?? MatchProvider(matchService),
        ),
        ChangeNotifierProxyProvider<AIAssistantService, AIAssistantProvider>(
          create: (context) => AIAssistantProvider(
            Provider.of<AIAssistantService>(context, listen: false),
          ),
          update: (context, aiAssistantService, previous) => 
            previous ?? AIAssistantProvider(aiAssistantService),
        ),
        ChangeNotifierProxyProvider<MessagingService, MessagingProvider>(
          create: (context) => MessagingProvider(
            Provider.of<MessagingService>(context, listen: false),
          ),
          update: (context, messagingService, previous) => 
            previous ?? MessagingProvider(messagingService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoorMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5A2B),
          brightness: Brightness.light,
        ),
        primaryColor: const Color(0xFF8B5A2B),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF8B5A2B)),
          titleTextStyle: TextStyle(
            color: Color(0xFF8B5A2B),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5A2B),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF8B5A2B),
            side: const BorderSide(color: Color(0xFF8B5A2B)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF8B5A2B),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF8B5A2B), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color(0xFF8B5A2B),
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: Color(0xFF8B5A2B),
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: Color(0xFF8B5A2B),
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: Color(0xFF8B5A2B),
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: TextStyle(
            color: Color(0xFF8B5A2B),
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF8B5A2B),
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(color: Color(0xFF5D4037)),
          bodyMedium: TextStyle(color: Color(0xFF5D4037)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/email-verification': (context) => const EmailVerificationScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/home': (context) => const HomeScreen(),
        '/account-settings': (context) => const AccountSettingsScreen(),
        '/create-listing': (context) => const CreateListingScreen(),
        '/ai-assistant': (context) => const AIAssistantScreen(),
        '/agent-chat': (context) => const AgentChatScreen(),
        '/preferences': (context) => const PreferencesScreen(),
        '/matches': (context) => const MatchScreen(),
        '/chats': (context) => const ChatListScreen(),
        '/chat': (context) => const ChatScreen(),
        '/listings': (context) => const ListingsScreen(),
        '/map-view': (context) => const MapViewScreen(),
        '/roommate-matching': (context) => const RoommateMatchingScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/listing-details') {
          final String listingId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ListingDetailsScreen(listingId: listingId),
          );
        }
        if (settings.name == '/map-view-neighborhood') {
          final String neighborhood = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => MapViewScreen(initialNeighborhood: neighborhood),
          );
        }
        return null;
      },
    );
  }
}
