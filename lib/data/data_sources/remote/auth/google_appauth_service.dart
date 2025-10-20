import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for Google OAuth2 authentication using flutter_appauth
///
/// Handles Google Cloud OAuth2 flow and returns ID token to backend
abstract class GoogleAppAuthService {
  Future<String> signInWithGoogle();
  Future<void> signOut();
}

class GoogleAppAuthServiceImpl implements GoogleAppAuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  /// Google OAuth2 configuration constants
  static const String _redirectUrl = 'com.algolabz.influenzer_mobile://oauth2callback';
  static const String _discoveryUrl =
      'https://accounts.google.com/.well-known/openid-configuration';
  static const String _scopes = 'openid email profile';

  /// Get Google Client ID from .env file
  String get _clientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';

  @override
  Future<String> signInWithGoogle() async {
    try {
      if (_clientId.isEmpty) {
        throw Exception('Google Client ID not configured in .env file');
      }

      // Initiate OAuth2 authorization code flow
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          discoveryUrl: _discoveryUrl,
          scopes: _scopes.split(' '),
          promptValues: ['login'], // Force account selection
        ),
      );

      // Check if authorization was successful
      if (result == null) {
        throw Exception('Google sign-in was cancelled');
      }

      // Extract ID token from result
      final idToken = result.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Failed to get ID token from Google');
      }

      return idToken;
    } on PlatformException catch (e) {
      throw Exception('Google sign-in platform error: ${e.message}');
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _appAuth.token(
        TokenRequest(
          _clientId,
          _redirectUrl,
          discoveryUrl: _discoveryUrl,
        ),
      );
    } catch (e) {
      // Ignore errors on sign out
      print('Error during sign out: $e');
    }
  }
}