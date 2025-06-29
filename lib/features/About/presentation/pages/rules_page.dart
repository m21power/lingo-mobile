import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  void _launchTelegram() async {
    final Uri telegramUrl = Uri.parse('https://t.me/jmbtalks');
    if (await canLaunchUrl(telegramUrl)) {
      await launchUrl(telegramUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Telegram dark
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Practice Rules',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const RuleItem(
              number: 1,
              text:
                  'You will be paired daily with someone who wants to improve their communications skill — just like you!',
            ),
            const RuleItem(
              number: 2,
              text:
                  'Try your best to talk with your assigned partner every day. You can talk about anything!',
            ),
            const RuleItem(
              number: 3,
              text:
                  'If you miss a practice, it counts as a **miss**. Once your missed average goes above 75%, daily pairing will stop.',
            ),
            const RuleItem(
              number: 4,
              text:
                  'If you can’t join on a certain day, you **must** let your partner know through the chat.',
            ),
            const RuleItem(
              number: 5,
              text:
                  'This is a respectful learning community. Be polite and supportive while chatting.',
            ),
            const SizedBox(height: 20),

            const Text(
              'If you’d like to practice more, go to the Alert page and tap Pair Me. If someone else is also looking to practice, we’ll match you instantly!',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.lightGreen,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20),
            const Text(
              'Let\'s grow together, one conversation at a time! 🌍💬',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.tealAccent,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 30),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'If your daily pairing has stopped, tap the button below to contact our team.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent[700],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.send),
                label: const Text(
                  'Contact Us on Telegram',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onPressed: _launchTelegram,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class RuleItem extends StatelessWidget {
  final int number;
  final String text;

  const RuleItem({super.key, required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: const TextStyle(
              color: Colors.tealAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
