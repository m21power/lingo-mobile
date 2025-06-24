import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lingo/features/auth/presentation/pages/otp_page.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _redirectToTelegram() async {
    final Uri tgUrl = Uri.parse('tg://resolve?domain=lingo_service_bot');
    final Uri httpsUrl = Uri.parse('https://t.me/lingo_service_bot');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OtpPage(Username: usernameController.text),
      ),
    );

    try {
      if (await canLaunchUrl(tgUrl)) {
        await launchUrl(tgUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(httpsUrl)) {
        await launchUrl(httpsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch Telegram')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  bool isWakingUp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          print("Current state: $state");
          if (state is WakeUpLoadingState) {
            setState(() {
              isWakingUp = true;
            });
          } else {
            setState(() {
              isWakingUp = false;
            });
          }
          if (state is WakeUpSuccessState) {
            _redirectToTelegram();
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "Welcome to Lingo 🚀",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 4.0,
                              color: Colors.black54,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Connect with peers and sharpen your communication skills through real-time language practice.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: '@TelegramUsername',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: Colors.white70,
                          ),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your Telegram username';
                          }
                          if (!RegExp(
                            r'^@?[a-zA-Z0-9_]{5,}$',
                          ).hasMatch(value)) {
                            return 'Invalid Telegram username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: isWakingUp
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton.icon(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(WakeUpEvent());
                                  }
                                },
                                icon: const Icon(Icons.telegram),
                                label: const Text("Continue with Telegram"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E88E5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  textStyle: const TextStyle(fontSize: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "You'll receive an OTP after tapping 'Start' in Telegram.",
                        style: TextStyle(color: Colors.white60),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
