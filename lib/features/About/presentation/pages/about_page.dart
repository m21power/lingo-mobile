import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  void _launchTelegram() async {
    const telegramUrl = 'https://t.me/JmbTalks'; // your channel
    if (await canLaunchUrl(Uri.parse(telegramUrl))) {
      await launchUrl(
        Uri.parse(telegramUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15),
        child: ListView(
          children: [
            const Text(
              textAlign: TextAlign.center,
              "Welcome to Lingo 👋",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Lingo helps you grow your communication skills by matching you with peers who share similar interests. Whether it's preparing for interviews, boosting fluency, or meaningful conversations — you’ll always have someone to practice with.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "✨ Features",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "🚀 Daily AI-powered partner matching\n🧠 Smart reminders to keep you consistent\n💬 Real-time chat & feedback\n🌍 Connect with people across the globe",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              "Join My Telegram channel 📢",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Stay up to date with the latest news, feature drops, and improvements from Lingo by joining our Telegram channel.",
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _launchTelegram,
                icon: const Icon(Icons.telegram, color: Colors.white),
                label: const Text(
                  "Join Channel",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
