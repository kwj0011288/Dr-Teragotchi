import 'package:emogotchi/pages/onboard/chatpage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emogotchi/provider/emotion_provider.dart';

class EmotionPage extends StatefulWidget {
  const EmotionPage({Key? key}) : super(key: key);

  @override
  State<EmotionPage> createState() => _EmotionPageState();
}

class _EmotionPageState extends State<EmotionPage> {
  final emotions = [
    {
      'image': 'assets/emoji/angry.png',
      'label': 'Angry',
      'color': const Color.fromARGB(255, 255, 197, 197),
    },
    {
      'image': 'assets/emoji/sad.png',
      'label': 'Sad',
      'color': const Color.fromARGB(255, 185, 209, 250),
    },
    {
      'image': 'assets/emoji/happy.png',
      'label': 'Happy',
      'color': const Color.fromARGB(255, 244, 237, 177),
    },
    {
      'image': 'assets/emoji/anxious.png',
      'label': 'Anxious',
      'color': const Color.fromARGB(255, 221, 116, 239),
    },
    {
      'image': 'assets/emoji/neutral.png',
      'label': 'Neutral',
      'color': const Color.fromARGB(255, 212, 193, 193),
    },
  ];

  void _navigateToChat(BuildContext context, String selectedEmotion) async {
    print('➡️ Navigating to Chat with emotion: $selectedEmotion');
    Provider.of<EmotionProvider>(context, listen: false)
        .setEmotion(selectedEmotion);

    await Future.delayed(const Duration(milliseconds: 300));
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) =>
            ChatPage(isInit: true, emotion: selectedEmotion),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            children: [
              const Text(
                'How are you feeling today?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.9,
                  physics: const BouncingScrollPhysics(),
                  children: emotions.map((emotion) {
                    return GestureDetector(
                      onTap: () =>
                          _navigateToChat(context, emotion['label'] as String),
                      child: Container(
                        decoration: BoxDecoration(
                          color: emotion['color'] as Color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (emotion['color'] as Color).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              emotion['image'] as String,
                              height: 100,
                              width: 100,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              emotion['label'] as String,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
