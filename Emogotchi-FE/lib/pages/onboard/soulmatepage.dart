import 'dart:async';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:emogotchi/pages/rootpage.dart';
import 'package:flutter/material.dart';
import 'package:emogotchi/provider/user_provider.dart';
import 'package:provider/provider.dart';

class SoulmatePage extends StatefulWidget {
  @override
  State<SoulmatePage> createState() => _SoulmatePageState();
}

class _SoulmatePageState extends State<SoulmatePage> {
  bool _isEyeOpen = true;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(_createFadeRoute());
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.emotion == 'neutral') {
      _blinkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _isEyeOpen = !_isEyeOpen;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  Route _createFadeRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => RootPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 800),
    );
  }

  Widget _animalImage(String animalType, String emotion) {
    String imagePath;
    if (emotion == 'neutral') {
      final eyeState = _isEyeOpen ? 'eye_open' : 'eye_close';
      imagePath = 'assets/${animalType}_egg/${animalType}_egg_$eyeState.png';
    } else {
      imagePath = 'assets/${animalType}_egg/${animalType}_egg_${emotion}.png';
    }

    return SizedBox(
      height: 300,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final userProvider =
        Provider.of<UserProvider>(flightContext, listen: false);
    return _animalImage(userProvider.animalType, userProvider.emotion);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final animalType = userProvider.animalType;
    final emotion = userProvider.emotion;

    return Scaffold(
      body: ColorfulSafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Your soulmate is...',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Hero(
                tag: 'penguinHero',
                flightShuttleBuilder: _flightShuttleBuilder,
                child: _animalImage(animalType, emotion),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
