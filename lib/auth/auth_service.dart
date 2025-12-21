import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  Future<User?> loginWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();

      await googleSignIn.signOut(); // 🔥 paksa reset akun sebelumnya

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error registering: $e');
      return null;
    }
  }

  Future<void> logout() async {
    final googleSignIn = GoogleSignIn();

    await googleSignIn.signOut(); // logout biasa
    await googleSignIn.disconnect(); // 🔥 PUTUS AKUN TOTAL

    await _auth.signOut();
  }
}
