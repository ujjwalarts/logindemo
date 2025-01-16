import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';


class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendSignInLinkToEmail(String email) async {
    // Updated ActionCodeSettings with your details
    ActionCodeSettings actionCodeSettings = ActionCodeSettings(
      url: 'https://ujjwalism.page.link/qbvQ?email=$email', // Your Dynamic Link
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
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut(); // Clear any previous session.
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) return; // User canceled the sign-in.

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);

    if (userCredential.user != null) {
      print('Google sign-in successful: ${userCredential.user!.email}');
    }
  } catch (e) {
    print('Google sign-in failed: $e');
    rethrow;
  }
}


  //Facebook Sign-In
Future<void> signInWithFacebook() async {
  try {
    // Trigger the Facebook login flow
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      // Retrieve the access token using `toJson()`
      final Map<String, dynamic>? accessTokenData = result.accessToken?.toJson();

      if (accessTokenData != null && accessTokenData['token'] != null) {
        // Extract the token from the access token data
        final String token = accessTokenData['token'];

        // Use the token to create a Facebook AuthCredential
        final OAuthCredential credential = FacebookAuthProvider.credential(token);

        // Sign in to Firebase with the Facebook credential
        final UserCredential userCredential = await _auth.signInWithCredential(credential);

        print('User signed in with Facebook: ${userCredential.user}');
      } else {
        print('Failed to retrieve access token from Facebook.');
      }
    } else {
      print('Facebook login failed: ${result.message}');
    }
  } catch (e) {
    print('Error during Facebook login: $e');
    rethrow;
  }
}

 /// Handle Dynamic Links and Sign-In
  // Future<bool> retrieveDynamicLinkAndSignIn({required bool fromColdState}) async {
  //   try {
  //     // Retrieve stored email
  //     final prefs = await SharedPreferences.getInstance();
  //     String email = prefs.getString('passwordLessEmail') ?? '';
  //     if (email.isEmpty) {
  //       print('No email stored for passwordless login');
  //       return false;
  //     }

  //     // Retrieve dynamic link
  //     PendingDynamicLinkData? dynamicLinkData;
  //     Uri? deepLink;

  //     if (fromColdState) {
  //       dynamicLinkData = await FirebaseDynamicLinks.instance.getInitialLink();
  //       deepLink = dynamicLinkData?.link;
  //     } else {
  //       dynamicLinkData = await FirebaseDynamicLinks.instance.onLink.first;
  //       deepLink = dynamicLinkData.link;
  //     }

  //     if (deepLink != null) {
  //       bool isValidLink = _auth.isSignInWithEmailLink(deepLink.toString());

  //       // Optional: Handle iOS clipboard if link is invalid
  //       // if (!isValidLink && Platform.isIOS) {
  //       //   ClipboardData? data = await Clipboard.getData('text/plain');
  //       //   if (data != null) {
  //       //     String clipboardLink = Uri.parse(data.text ?? '').queryParameters['link'] ?? '';
  //       //     isValidLink = _auth.isSignInWithEmailLink(clipboardLink);
  //       //     if (isValidLink) {
  //       //       deepLink = Uri.parse(clipboardLink);
  //       //     }
  //       //   }
  //       // }

  //       // Sign in with the email link if valid
  //       if (isValidLink) {
  //         await _auth.signInWithEmailLink(
  //           email: email,
  //           emailLink: deepLink.toString(),
  //         );
  //         print('Passwordless sign-in successful');
  //         return true;
  //       } else {
  //         print('Invalid email sign-in link');
  //         return false;
  //       }
  //     } else {
  //       print('No dynamic link found');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Error during dynamic link sign-in: $e');
  //     return false;
  //   }
  // }

}
