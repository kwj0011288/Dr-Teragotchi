import 'package:emogotchi/api/api.dart';
import 'package:emogotchi/pages/onboard/emotionpage.dart';
import 'package:emogotchi/provider/uuid_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';

class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final TextEditingController _nameController = TextEditingController();
  late String _uuid = '';

  @override
  void initState() {
    super.initState();
    _initializeUuid(); // 여기서 uuid 받아오고 바로 setState
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

      // 에러 다이얼로그 표시 등 UI 반영
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

  void _handleNext() {
    if (_nameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.background,
            icon: const Icon(
              FeatherIcons.alertTriangle,
              color: Colors.redAccent,
              size: 45,
            ),
            title: const Text(
              'What is your name?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            content: const Text(
              'You must enter your name to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  HapticFeedback.lightImpact();
                },
                child: const Text('OK'),
              )
            ],
          );
        },
      );
      return;
    } else {
      sendUserInfo();
      print("Name: ${_nameController.text}");
      print("UUID: $_uuid");
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                const Text(
                  "What's your soul mate name?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Set name and profile\nthat will be shown to others.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),
                Image.asset(
                  'assets/pig/pig_happy.png',
                  height: 180,
                  width: 180,
                ),
                const SizedBox(height: 40),
                CupertinoTextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  placeholder: "Enter Name",
                  maxLength: 16,
                  padding: const EdgeInsets.all(12),
                  style: const TextStyle(fontSize: 20),
                  placeholderStyle: TextStyle(
                    fontSize: 20,
                    color: theme.colorScheme.outline,
                  ),
                  cursorColor: theme.colorScheme.outline,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                  ),
                  onSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: GestureDetector(
          onTap: _handleNext,
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
