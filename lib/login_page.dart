import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          } else if (state is AuthEmailVerificationSent) {
            Navigator.pop(context); // Close the loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Verification email sent! Check your inbox."),
              ),
            );
          } else if (state is AuthSuccess) {
            Navigator.pop(context); // Close the loading dialog
            Navigator.pushReplacementNamed(context, '/chatPage');
          } else if (state is AuthFailure) {
            Navigator.pop(context); // Close the loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Welcome Back!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Enter your email",
                    prefixIcon: Icon(Icons.email, color: Colors.white),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    String email = _emailController.text;
                    if (email.isNotEmpty) {
                      context.read<AuthBloc>().add(SendEmailVerification(email));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a valid email")),
                      );
                    }
                  },
                  child: const Text("Send Verification Email"),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(SignInWithGoogle());
                  },
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text("Sign in with Google"),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(SignInWithFacebook());
                  },
                  icon: const Icon(Icons.facebook, color: Colors.white),
                  label: const Text("Sign in with Facebook"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}