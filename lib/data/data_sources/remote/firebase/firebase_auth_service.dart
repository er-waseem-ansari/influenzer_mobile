import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseAuthService {
  Future<String> signInWithGoogle();
  Future<String> signInWithPhone(PhoneAuthCredential credential);
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String, int?) onCodeSent,
    required Function(String) onCodeAutoRetrievalTimeout,
  });
  User? getCurrentUser();
  Future<void> signOut();
}

class FirebaseAuthServiceImpl implements FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isGoogleSignInInitialized = false;
  GoogleSignInAccount? _currentUser;

  FirebaseAuthServiceImpl() {
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      print('Failed to initialize Google Sign-In: $e');
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  @override
  Future<String> signInWithGoogle() async {
    try {
      // Ensure Google Sign-In is initialized
      await _ensureGoogleSignInInitialized();

      // 1. Authenticate with Google (replaces signIn() in v7)
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email'],
      );

      // Store current user for state management
      _currentUser = googleUser;

      // 2. Get authorization for Firebase scopes
      final authClient = googleUser.authorizationClient;
      final authorization = await authClient.authorizationForScopes(['email']);

      if (authorization == null) {
        throw Exception('Failed to get authorization');
      }

      // 3. Get authentication (now synchronous in v7)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 4. Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Sign in to Firebase with the Google credential
      final UserCredential userCredential =
      await _firebaseAuth.signInWithCredential(credential);

      // 6. Get Firebase ID token
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      return idToken;

    } on GoogleSignInException catch (e) {
      _currentUser = null;
      throw Exception(
          'Google Sign-In error: ${e.code.name} - ${e.description ?? "Unknown error"}');
    } on FirebaseAuthException catch (e) {
      _currentUser = null;
      throw Exception('Firebase auth error: ${e.message}');
    } catch (e) {
      _currentUser = null;
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<String> signInWithPhone(PhoneAuthCredential credential) async {
    try {
      final UserCredential userCredential =
      await _firebaseAuth.signInWithCredential(credential);

      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      return idToken;

    } on FirebaseAuthException catch (e) {
      throw Exception('Phone sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Phone sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String, int?) onCodeSent,
    required Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
    _currentUser = null;
  }
}