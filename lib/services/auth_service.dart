import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with Email and Password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('Attempting to sign in with Email: $email');
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException signing in: ${e.message}');
      return null;
    } catch (e) {
      print('Error signing in with email and password: $e');
      return null;
    }
  }

  // Register with Email and Password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      print('Attempting to register with Email: $email');
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException registering: ${e.message}');
      return null;
    } catch (e) {
      print('Error registering with email and password: $e');
      return null;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Attempting to sign in with Google...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        print('Google sign in canceled by user.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      print('Google Sign-In successful, UserCredential obtained for: ${userCredential.user?.email}');
      return userCredential; // Return the UserCredential
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during Google Sign-In: ${e.message}');
      return null;
    } catch (e) {
      // Handle other errors, e.g., network issues, or specific GoogleSignIn errors
      print('Error during Google Sign-In: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('Attempting to sign out');
      await _googleSignIn.signOut(); // Sign out from Google, if previously signed in
      await _firebaseAuth.signOut(); // Sign out from Firebase
      print('Sign out successful');
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
