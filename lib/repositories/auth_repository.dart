import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendSignInLinkToEmail(String email) async {
    // Updated ActionCodeSettings with your details
    ActionCodeSettings actionCodeSettings = ActionCodeSettings(
      url: 'https://ujjwalism.page.link/qbvQ', // Your Dynamic Link
      handleCodeInApp: true,
      iOSBundleId: 'com.example.ios', // Your iOS bundle ID
      androidPackageName: 'com.example.logindemo', // Your Android package name
      androidInstallApp: true,
      androidMinimumVersion: '21', // Minimum Android version
    );

    try {
      // Send the sign-in link to the email
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
      print("Email sent to $email");
    } catch (e) {
      print("Error sending email: $e");
      rethrow;
    }
  }

  Future<User?> signInWithEmailLink(String email, String emailLink) async {
    try {
      // Verify the email link
      if (_auth.isSignInWithEmailLink(emailLink)) {
        // Sign in the user
        UserCredential userCredential = await _auth.signInWithEmailLink(
          email: email,
          emailLink: emailLink,
        );
        return userCredential.user;
      } else {
        print("Invalid email link");
        return null;
      }
    } catch (e) {
      print("Error signing in with email link: $e");
      rethrow;
    }
  }



  // Google Sign-In
  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) return; // User canceled the sign-in.

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
    print('User signed in with Google!');
  }

  // Facebook Sign-In
  Future<void> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = result.accessToken!;
      final AuthCredential credential = FacebookAuthProvider.credential(accessToken.token);

      await _auth.signInWithCredential(credential);
      print('User signed in with Facebook!');
    } else {
      print('Facebook sign-in failed: ${result.message}');
    }
  }
}
