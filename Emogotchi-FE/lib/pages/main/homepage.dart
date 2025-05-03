import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:emogotchi/api/api.dart';
import 'package:emogotchi/components/home_chat.dart';
import 'package:emogotchi/pages/onboard/chatpage.dart';
import 'package:emogotchi/provider/background_provider.dart';
import 'package:emogotchi/provider/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _moveAnimation;
  late Animation<double> _tiltAnimation;
  late String selectedMessage;
  late AnimationController _plusOneController;
  late AnimationController _levelUpController;
  late Animation<double> _levelUpFade;
  bool showMinusTwenty = false;
  late AnimationController _minusTwentyController;
  late Animation<double> _minusTwentyFade;
  late AnimationController _riceShakeController;
  late Animation<double> _riceShakeAnimation;

  /* ------------------------------ */
  late String animalType;
  late String animalMood;
  int points = 0;
  int level = 0;
  int riceLevel = 0;
  int streak = 0;
  String uuid = '';
  bool _isEyeOpen = true;
  Timer? _blinkTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isReady = false;

  /* ------------------------------ */
  bool showPlusOne = false;
  bool showLevelUp = false;

  bool showFallingRice = false;
  double riceProgress = 0.0;

  bool _firstJumpDone = false;

  /* ------------------------------ */
  late AnimationController _evolutionJumpController;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  late ConfettiController _leftConfettiController;
  late ConfettiController _rightConfettiController;
  late ConfettiController _bottomfettiController;
  bool _showEvolvedAnimal = false;

  final List<String> background = [
    'assets/background/airport.png',
    'assets/background/lake.png',
    'assets/background/mountain.png',
    'assets/background/park.png',
    'assets/background/school.png',
  ];
  List<String> aniamlMessages = [
    "It's okay to not be okay. You’re doing your best and that’s enough",
    "You are not alone. I'm here with you always",
    "Even small steps are progress. Be proud of yourself",
    "Your feelings are valid. It’s okay to feel everything you're feeling",
    "You’ve made it through 100 percent of your worst days. You’re stronger than you think",
    "Just for today breathe. That’s more than enough",
    "There’s no rush. You can take your time to heal",
    "You are more than your sadness. There’s light in you too",
    "Some days are hard. Be gentle with yourself today",
    "You don’t have to carry everything all at once",
    "Your presence matters even if you can’t see it right now",
    "It’s brave to ask for help. You deserve support",
    "Rest is not a weakness. It’s part of being human",
    "The world is better with you in it. Don’t forget that",
    "You are worthy of love care and kindness",
    "Take things one breath one moment at a time",
    "You are not a burden. Your pain is real and so is your courage",
    "Healing isn’t linear and that’s perfectly okay",
    "Your story isn’t over. This is just one chapter",
    "You’ve come so far. That matters even if you can’t see it yet",
  ];

  int getRandomInt() {
    return Random().nextInt(background.length);
  }

  @override
  void initState() {
    super.initState();
    _plusOneController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _levelUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _levelUpFade = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _levelUpController,
      curve: Curves.easeOut,
    ));

    _minusTwentyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _minusTwentyFade =
        Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _minusTwentyController,
      curve: Curves.easeOut,
    ));

    _evolutionJumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 4 * pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeOutQuart),
    );
    _leftConfettiController =
        ConfettiController(duration: const Duration(seconds: 4));
    _rightConfettiController =
        ConfettiController(duration: const Duration(seconds: 4));
    _bottomfettiController =
        ConfettiController(duration: const Duration(seconds: 4));

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _riceShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _riceShakeAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _riceShakeController, curve: Curves.elasticIn),
    );

    _setupAnimation();
    _setup();
  }

  Future<void> _setup() async {
    final prefs = await SharedPreferences.getInstance();
    uuid = prefs.getString('uuid') ?? '';
    riceLevel = prefs.getInt('riceLevel') ?? 0;
    riceProgress =
        prefs.getDouble('riceProgress') ?? (riceLevel / 10); // 👈 fallback
    _showEvolvedAnimal = prefs.getBool('evolved_$uuid') ?? false; // ✅ 추가
    print('📦 로컬에서 불러온 uuid: $uuid');

    if (uuid.isNotEmpty) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final response = await ApiService().getUser(uuid.trim());

      userProvider.setUserData(
        uuid: response['uuid'] ?? uuid,
        emotion: response['animal_emotion'] ?? userProvider.emotion,
        animal: response['animal_type'] ?? userProvider.animalType,
        animalLevel:
            response['animal_level']?.toString() ?? userProvider.animalLevel,
        points: response['points'] ?? userProvider.points,
        userName: response['nickname'] ?? userProvider.userName,
        isNotified: response['is_notified'] ?? userProvider.isNotified,
      );

      setState(() {
        animalMood = response['animal_emotion'] ?? 'neutral';
        animalType = response['animal_type'] ?? 'penguin';
        points = response['points'] ?? 0;
        level = int.tryParse(response['animal_level']?.toString() ?? '') ?? 1;
        _isReady = true; // ✅ 준비 완료 표시
      });
      _fadeController.forward(); // ✅ fade 시작
    }
  }

  void _setupAnimation() {
    final bgProvider = Provider.of<BackgroundProvider>(context, listen: false);

    if (bgProvider.selectedBackground == null) {
      final randomBg = background[getRandomInt()];
      bgProvider.setBackground(randomBg);
    }

    selectedMessage = aniamlMessages[Random().nextInt(aniamlMessages.length)];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _moveAnimation = Tween<double>(begin: 0, end: 16).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    _tiltAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _triggerRiceEffect() async {
    setState(() {
      riceLevel++;
      riceProgress = riceLevel / 10;
      showPlusOne = true;
      showFallingRice = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('riceLevel', riceLevel); // ✅ riceLevel 저장
    await prefs.setDouble('riceProgress', riceProgress); // ✅ riceProgress 저장

    // +1 애니메이션
    _plusOneController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => showPlusOne = false);
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => showFallingRice = false);
    });

    // 🎯 만약 10 이상 되면 초기화 + 레벨업
    if (riceLevel >= 10 || riceProgress >= 1.0) {
      setState(() {
        riceLevel = 0;
        riceProgress = 0.0;
        level += 1;
        showLevelUp = true;
      });

      await prefs.setInt('riceLevel', 0);
      await prefs.setDouble('riceProgress', 0.0);

      try {
        await ApiService().updateUserLevel(uuid.trim(), level);
        print("🎉 서버에 레벨 업데이트 완료: $level");
      } catch (e) {
        print("❌ 서버 레벨 업데이트 실패: $e");
      }
      _levelUpController.forward(from: 0); // ⭐️ 애니메이션 시작

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => showLevelUp = false);
      });
    }

    // 수정
    if (level == 5 && !_showEvolvedAnimal) {
      final prefs = await SharedPreferences.getInstance();
      final hasEvolved = prefs.getBool('evolved_$uuid') ?? false;

      if (!hasEvolved) {
        _playEvolutionAnimation();
      }
    }

    print("🍚 riceLevel: $riceLevel");
    print("📊 riceProgress: $riceProgress");
    print("⬆️ level: $level");
  }

  void _playEvolutionAnimation() async {
    // 🥚 알 점프 2번
    for (int i = 0; i < 2; i++) {
      await _evolutionJumpController.forward();
      await _evolutionJumpController.reverse();
    }

    // ✅ 여기서 1초 대기 → 이미지 변경 (이전에는 순서가 애매했음)
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _showEvolvedAnimal = true;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('evolved_$uuid', true); // ✅ 저장
    // 🎉 confetti & 회전
    _leftConfettiController.play();
    _rightConfettiController.play();
    _bottomfettiController.play();

    await _rotationController.forward(from: 0);
    await _rotationController.reverse();

    // 🐣 캐릭터 점프 2번
    for (int i = 0; i < 2; i++) {
      await _evolutionJumpController.forward();
      await _evolutionJumpController.reverse();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_controller.isAnimating && _firstJumpDone) {
      _controller.forward().then((_) {
        _controller.repeat(reverse: true);
      });
    }

    final userInfoProvider = Provider.of<UserProvider>(context, listen: false);
    final rawMood = userInfoProvider.getEmotion;
    final rawType = userInfoProvider.getAnimalType;

    animalMood = (rawMood.isEmpty) ? 'neutral' : rawMood;
    animalType = (rawType.isEmpty) ? 'penguin' : rawType;
    points = userInfoProvider.getPoints;

    print('animalType: $animalType');
    print('animalMood: $animalMood');
    print('points: $points');

    if (animalMood == 'neutral' && _blinkTimer == null) {
      _startBlinking();
    }

    if (uuid.isNotEmpty) {
      ApiService().getUser(uuid).then((response) {
        print('User data: $response');
        userInfoProvider.setUserData(
          uuid: response['uuid'] ?? uuid,
          emotion: response['animal_emotion'] ?? userInfoProvider.emotion,
          animal: response['animal_type'] ?? userInfoProvider.animalType,
          animalLevel: response['animal_level']?.toString() ??
              userInfoProvider.animalLevel,
          points: response['points'] ?? userInfoProvider.points,
          userName: response['nickname'] ?? userInfoProvider.userName,
          isNotified: response['is_notified'] ?? userInfoProvider.isNotified,
        );
        setState(() {
          animalMood = response['animal_emotion'] ?? 'neutral';
          animalType = response['animal_type'] ?? 'penguin';
          points = response['points'] ?? 0;
        });
      });
    }
  }

  void startAnimalAnimation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.forward().then((_) {
          _controller.repeat(reverse: true);
          setState(() {
            _firstJumpDone = true;
          });
        });
      }
    });
  }

  void _startBlinking() {
    void blink() {
      if (!mounted) return;

      // 눈 상태 바꾸기
      setState(() {
        _isEyeOpen = !_isEyeOpen;
      });

      // 눈 감았다가 빠르게 뜨기 (200~300ms 후 다시 깜빡임 시작)
      Future.delayed(
          Duration(
              milliseconds: _isEyeOpen ? Random().nextInt(3000) + 2000 : 150),
          () {
        blink();
      });
    }

    blink(); // 처음 호출
  }

  Widget _animalImage({bool animated = true}) {
    String imagePath;

    // ✅ 진화 여부 정확하게 판단
    bool isEvolved = level >= 5 || _showEvolvedAnimal;
    if (!isEvolved) {
      if (animalMood == 'neutral') {
        final eyeState = _isEyeOpen ? 'eye_open' : 'eye_close';
        imagePath = 'assets/${animalType}_egg/${animalType}_egg_$eyeState.png';
      } else {
        imagePath =
            'assets/${animalType}_egg/${animalType}_egg_${animalMood}.png';
      }
    } else if (animalMood == 'neutral') {
      final eyeState = _isEyeOpen ? 'eye_open' : 'eye_close';
      imagePath = 'assets/$animalType/${animalType}_$eyeState.png';
    } else {
      imagePath = 'assets/$animalType/${animalType}_${animalMood}.png';
    }

    final image = Image.asset(imagePath, fit: BoxFit.contain);

    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!isEvolved)
            // 알 상태 → 점프 애니메이션만
            AnimatedBuilder(
              animation: _evolutionJumpController,
              builder: (context, _) {
                double bounce = sin(_controller.value * pi * 2); // 주기적인 bounce
                double jumpOffset = -12 * bounce.abs(); // 절댓값으로 위로만 튀도록
                return Transform.translate(
                  offset: Offset(0, jumpOffset),
                  child: image,
                );
              },
            )
          else
            // 진화 상태 → 회전만
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, _) {
                double rotationAngle = _rotationAnimation.value;
                return Transform.rotate(
                  angle: rotationAngle,
                  child: image,
                );
              },
            ),

          // 🎉 Confetti
          Align(
            alignment: Alignment.bottomCenter,
            child: ConfettiWidget(
              confettiController: _bottomfettiController,
              blastDirection: pi / 2,
              emissionFrequency: 0.6,
              numberOfParticles: 8,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.3,
              colors: const [Colors.orange, Colors.pink, Colors.yellow],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: ConfettiWidget(
              confettiController: _leftConfettiController,
              blastDirection: -pi / 2,
              emissionFrequency: 0.6,
              numberOfParticles: 8,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.3,
              colors: const [Colors.orange, Colors.pink, Colors.yellow],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ConfettiWidget(
              confettiController: _rightConfettiController,
              blastDirection: -pi / 2,
              emissionFrequency: 0.6,
              numberOfParticles: 8,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.3,
              colors: const [Colors.orange, Colors.pink, Colors.yellow],
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedCharacterWrapper(Widget child) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([_evolutionJumpController, _rotationController]),
      builder: (context, _) {
        double jumpOffset = -20 * _evolutionJumpController.value;
        double rotationAngle = _rotationAnimation.value;

        return Transform.translate(
          offset: Offset(0, jumpOffset),
          child: Transform.rotate(
            angle: rotationAngle,
            child: child,
          ),
        );
      },
    );
  }

  Widget _flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return _animalImage(animated: false);
  }

  @override
  void dispose() {
    // 애니메이션 중지 후 dispose
    _controller.stop();
    _controller.dispose();
    _plusOneController.dispose();
    _levelUpController.dispose();
    _minusTwentyController.dispose();
    _evolutionJumpController.dispose();
    _rotationController.dispose();
    _leftConfettiController.dispose();
    _rightConfettiController.dispose();
    _bottomfettiController.dispose();
    _blinkTimer?.cancel();
    _fadeController.dispose(); // 👈 이것도 잊지 말기
    _riceShakeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedBackground =
        Provider.of<BackgroundProvider>(context).selectedBackground ??
            'assets/background/airport.png';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            selectedBackground,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      height: 45,
                      width: 220,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox(
                              width: 200,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: riceProgress,
                                  minHeight: 15,
                                  backgroundColor: Colors.grey.withOpacity(0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.orangeAccent),
                                ),
                              ),
                            ),
                            if (showPlusOne)
                              Positioned(
                                right: -50,
                                top: 5,
                                child: AnimatedBuilder(
                                  animation: _plusOneController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity:
                                          Tween<double>(begin: 1.0, end: 0.0)
                                              .animate(_plusOneController),
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin:
                                              const Offset(0, 0.5), // 아래에서 시작
                                          end: const Offset(0, -1), // 위로 올라감
                                        ).animate(CurvedAnimation(
                                          parent: _plusOneController,
                                          curve: Curves.easeOut,
                                        )),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "+1",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              left: -8,
                              top: -8,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor:
                                    Colors.yellowAccent.withOpacity(0.7),
                                child: Image.asset('assets/homepage/rice.png',
                                    height: 30, width: 30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    StatusButton(false, level, false),
                    if (showLevelUp)
                      FadeTransition(
                        opacity: _levelUpFade,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            "+1",
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    StatusButton(true, points, true),
                    if (showMinusTwenty)
                      FadeTransition(
                        opacity: _minusTwentyFade,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            "-40",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                StatusButton(true, streak, false),
              ],
            ),
          ),
          Positioned(
            bottom: 295,
            left: 0,
            right: 0,
            child: points >= 40
                ? (_isReady)
                    ? FadeTransition(
                        opacity: _fadeAnimation,
                        child: Center(
                          child: GestureDetector(
                            onTap: () async {
                              HapticFeedback.mediumImpact();
                              if (points >= 20 && riceLevel < 10) {
                                setState(() {
                                  points -= 40;
                                  showMinusTwenty = true;
                                });

                                _riceShakeController.forward(from: 0); // 떨림 시작

                                _minusTwentyController.forward(from: 0);
                                Future.delayed(
                                    const Duration(milliseconds: 800), () {
                                  if (mounted)
                                    setState(() => showMinusTwenty = false);
                                });

                                _triggerRiceEffect();
                                try {
                                  await ApiService()
                                      .updateUserPoints(uuid.trim(), points);
                                } catch (e) {
                                  print("❌ 포인트 업데이트 실패: $e");
                                }
                              }
                            },
                            child: AnimatedBuilder(
                              animation: _riceShakeController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    sin(_riceShakeAnimation.value * pi * 2) * 8,
                                    0,
                                  ),
                                  child: child,
                                );
                              },
                              child: Image.asset(
                                'assets/homepage/rice.png',
                                height: 110,
                                width: 100,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink()
                : (_isReady)
                    ? FadeTransition(
                        opacity: _fadeAnimation,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            startAnimalAnimation();
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                settings: RouteSettings(
                                  name: '/chatpage',
                                  arguments: {
                                    'emotion': '',
                                  },
                                ),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        ChatPage(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return FadeTransition(
                                      opacity: animation, child: child);
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 500),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: HomeChatBubble(text: selectedMessage),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
          ),
          Positioned(
            bottom: 115,
            left: 0,
            right: 0,
            child: Center(
              child: Hero(
                tag: 'penguinHero',
                flightShuttleBuilder: _flightShuttleBuilder,
                child: _isReady
                    ? FadeTransition(
                        opacity: _fadeAnimation,
                        child: _animalImage(),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget StatusButton(bool isStreak, int value, bool isCoin) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: isStreak
                ? Colors.orangeAccent.withOpacity(0.7)
                : Colors.blue.withOpacity(0.7),
            child: isCoin
                ? Image.asset(
                    'assets/emoji/coin.png',
                    height: 30,
                    width: 30,
                  )
                : isStreak
                    ? Image.asset(
                        'assets/homepage/streak.png',
                        height: 30,
                        width: 30,
                      )
                    : const Text(
                        'LV',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
          ),
          const SizedBox(width: 4),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
