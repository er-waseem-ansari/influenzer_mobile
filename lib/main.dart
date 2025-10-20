import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:influenzer_mobile/core/config/service_locator.dart';
import 'package:influenzer_mobile/data/repositories/auth_repository.dart';

import 'firebase_options.dart';
import 'data/data_sources/local/user_local_service.dart';
import 'presentation/bloc/auth/auth_bloc.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Setup dependency injection
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC Provider
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: getIt<AuthRepository>(),
            userLocal: getIt<UserLocalService>(),
          )..add(const CheckAuthStatusEvent()), // Check auth on startup
        ),
        // Add more BLoC providers here as needed
      ],
      child: MaterialApp(
        title: 'Influenzer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // TODO: Replace with your routing/navigation setup
        home: const AuthCheckScreen(),
      ),
    );
  }
}

/// Auth Check Screen - Checks authentication status and navigates accordingly
class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStatusChecked) {
          if (state.isLoggedIn) {
            // Navigate to home screen (TODO: Replace with your home screen)
            print('✅ User is logged in: ${state.userRole}');
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          } else {
            // Navigate to login screen (TODO: Replace with your login screen)
            print('❌ User is not logged in');
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
          }
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}