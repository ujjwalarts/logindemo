// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:logindemo/chat_page.dart';
// import 'bloc/auth_bloc.dart';
// import 'repositories/auth_repository.dart';
// import 'login_page.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   try {
//     // Initialize Firebase with platform-specific options
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     print("Firebase Initialized successfully!");
//   } catch (e) {
//     print("Error initializing Firebase: $e");
//   }

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   final AuthRepository _authRepository = AuthRepository();

//   MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => AuthBloc(_authRepository),
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData.dark().copyWith(
//           primaryColor: Colors.blueAccent,
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//           inputDecorationTheme: const InputDecorationTheme(
//             border: OutlineInputBorder(),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: Colors.blueAccent),
//             ),
//             labelStyle: TextStyle(color: Colors.white),
//           ),
//         ),
//         home: const LoginPage(),
//         routes: {
//           '/chatPage': (context) => const ChatPage(),
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_links/app_links.dart';
import 'package:logindemo/chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc/auth_bloc.dart';
import 'repositories/auth_repository.dart';
import 'login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase Initialized successfully!");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthRepository _authRepository = AuthRepository();

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(_authRepository),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.blueAccent,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
        home: LinkHandler(authRepository: _authRepository),
        routes: {
          '/chatPage': (context) => const ChatPage(),
        },
      ),
    );
  }
}

class LinkHandler extends StatefulWidget {
  final AuthRepository authRepository;
  const LinkHandler({Key? key, required this.authRepository}) : super(key: key);

  @override
  State<LinkHandler> createState() => _LinkHandlerState();
}

class _LinkHandlerState extends State<LinkHandler> {
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _listenToIncomingLinks();
  }

  void _listenToIncomingLinks() async {
    try {
      // Handle the initial link
      final Uri? initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _processDeepLink(initialLink);
      }

      // Listen to subsequent incoming links
      _appLinks.uriLinkStream.listen((Uri? deepLink) {
        if (deepLink != null) {
          _processDeepLink(deepLink);
        }
      }).onError((error) {
        print("Error handling deep link: $error");
      });
    } catch (e) {
      print("Error handling links: $e");
    }
  }

  void _processDeepLink(Uri link) async {
    if (link.path == '/verify-email') {
      // Extract email from shared preferences or another storage mechanism
      final prefs = await SharedPreferences.getInstance();
      String email = prefs.getString('passwordLessEmail') ?? '';

      if (email.isNotEmpty) {
        bool isVerified = await widget.authRepository.verifyEmailLink(email, link as String);
        if (isVerified) {
          Navigator.pushReplacementNamed(context, '/chatPage');
        } else {
          print("Email verification failed");
        }
      } else {
        print("No email stored for verification");
      }
    } else {
      print("Unknown deep link: $link");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}
