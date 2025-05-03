// OnboardingScreen - without background or Scaffold
import 'dart:async';
import 'package:flutter/material.dart';

class Onboarding1 extends StatefulWidget {
  const Onboarding1({Key? key}) : super(key: key);

  @override
  State<Onboarding1> createState() => _Onboarding1State();
}

class _Onboarding1State extends State<Onboarding1>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  double _scrollSpeed = 1.5;
  final List<String> _characters = [
    'assets/penguin/penguin_happy.png',
    'assets/pig/pig_happy.png',
    'assets/tiger/tiger_happy.png',
    'assets/dog/dog_happy.png',
    'assets/hamster/hamster_happy.png',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent / 2);
    });
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.offset + _scrollSpeed);
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (_scrollController.offset >= maxScroll - 10) {
          _scrollController.jumpTo(maxScroll / 2);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final repeatedCharacters = List.generate(
      50,
      (index) => _characters[index % _characters.length],
    );

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Set up your spirit animal \nwith just a few messages!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Spiritual Animal is here to help you',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Color.fromRGBO(242, 242, 243, 0.702),
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildEmotionBubble('Sadness'),
                _buildEmotionBubble('depression'),
                _buildEmotionBubble('Angry'),
                _buildEmotionBubble('Anxiety'),
                _buildEmotionBubble('Happiness'),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 250,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: repeatedCharacters.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _buildCharacter(repeatedCharacters[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionBubble(String text) {
    late final AnimationController controller;
    late final Animation<Offset> animation;

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0),
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(controller);

    return GestureDetector(
      onTap: () async {
        await controller.forward();
        await controller.reverse();
      },
      child: SlideTransition(
        position: animation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacter(String imagePath,
      {double height = 250, double width = 250}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        imagePath,
        height: height,
        width: width,
        fit: BoxFit.cover,
      ),
    );
  }
}
