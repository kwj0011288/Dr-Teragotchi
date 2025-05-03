// TigerPage - Tiger background with name input and transition
import 'package:emogotchi/api/api.dart';
import 'package:emogotchi/pages/onboard/emotionpage.dart';
import 'package:emogotchi/provider/uuid_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';

class Onboarding4 extends StatefulWidget {
  const Onboarding4({super.key});

  @override
  State<Onboarding4> createState() => _Onboarding4State();
}

class _Onboarding4State extends State<Onboarding4> {
  final TextEditingController _nameController = TextEditingController();
  late String _uuid = '';

  @override
  void initState() {
    super.initState();
    _initializeUuid();
  }

  void _initializeUuid() async {
    final deviceInfoProvider =
        Provider.of<DeviceInfoProvider>(context, listen: false);
    await deviceInfoProvider.fetchDeviceUuid();

    if (!mounted) return;

    final fetchedUuid = deviceInfoProvider.uuid;
    if (fetchedUuid != null) {
      setState(() {
        _uuid = fetchedUuid;
      });
      print("Fetched UUID: $_uuid");
    } else {
      print("Failed to get UUID");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void sendUserInfo() async {
    try {
      final apiService = ApiService();
      final result =
          await apiService.postOnboarding(_uuid, _nameController.text);

      print("Onboarding Success: $result");

      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const EmotionPage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e) {
      print("Error sending onboarding data: $e");

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to send info: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showNameRequiredDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('What is your name?'),
        content: Column(
          children: [
            const SizedBox(height: 10),
            Image.asset('assets/penguin/penguin_eye_open.png',
                height: 100), // 🐧 원하는 이미지 경로
            const SizedBox(height: 10),
            const Text('You must enter your name to continue.'),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK', style: TextStyle(color: Colors.black)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showConfirmNameDialog(BuildContext context, String inputName) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoTheme(
        // ⛳ 여기! data가 아니라 직접 theme 매개변수 사용

        data: const CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.black,
          scaffoldBackgroundColor: Colors.white,
          barBackgroundColor: Colors.white,
        ),
        child: CupertinoAlertDialog(
          title: const Text('Is this name correct?'),
          content: Column(
            children: [
              const SizedBox(height: 10),
              Image.asset('assets/penguin/penguin_eye_close.png', height: 100),
              const SizedBox(height: 10),
              Text(
                '"$inputName"',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('No', style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Yes'),
              onPressed: () {
                Navigator.pop(context);
                sendUserInfo();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleNext(String value) {
    if (_nameController.text.trim().isEmpty) {
      HapticFeedback.lightImpact();
      _showNameRequiredDialog(context);

      return;
    }

    final inputName = _nameController.text.trim();

    _showConfirmNameDialog(context, inputName);

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Dismiss the keyboard
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 0.0, vertical: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    "What's your soul mate name?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Set name and profile\nthat will be shown to others.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 50),
                  Image.asset(
                    'assets/emoji/family.png',
                    height: 300,
                    width: 300,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).viewInsets.bottom,
          child: Container(
            padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoTextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  placeholder: "Enter Name",
                  maxLength: 16,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  style: const TextStyle(fontSize: 20),
                  placeholderStyle:
                      const TextStyle(fontSize: 20, color: Colors.black),
                  cursorColor: Colors.black,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.7)),
                  onSubmitted: _handleNext,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
