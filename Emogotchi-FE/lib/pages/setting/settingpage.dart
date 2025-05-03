import 'dart:ui';

import 'package:emogotchi/api/api.dart';
import 'package:emogotchi/pages/setting/changeNickname.dart';
import 'package:emogotchi/provider/background_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main/notificationSettingPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  final String? nickname;
  final String? animalType;
  final int? level;

  const SettingPage({
    Key? key,
    this.nickname,
    this.animalType,
    this.level,
  }) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? _uuid;

  Widget _buildGridButton(
    BuildContext context,
    String text,
    VoidCallback onPressed, {
    Color? backgroundColor,
    Color? textColor,
    String? imagePath, // 추가: 이미지 경로
  }) {
    return AspectRatio(
      aspectRatio: 1,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.grey[100],
          foregroundColor: textColor ?? Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.all(12),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath,
                width: 60,
                height: 60,
              ),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.2,
                textBaseline: TextBaseline.alphabetic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUuid();
  }

  Widget _buildImage(int level) {
    final imagePath = level < 5
        ? 'assets/${widget.animalType}_egg/${widget.animalType}_egg_happy.png'
        : 'assets/${widget.animalType}/${widget.animalType}_happy.png';

    return Image.asset(
      imagePath,
      height: 200,
      width: 200,
    );
  }

  Future<void> _loadUuid() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _uuid = prefs.getString('uuid');
    });
  }

  // Helper function for the footer links (making them tappable)
  Widget _buildFooterLink(String text, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Delete the account?'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Keep the column compact
            children: [
              // Display an asset image (update the asset path as needed)
              Image.asset(
                'assets/penguin/penguin_sad.png', // Replace with your actual image path
                height: 100, // Adjust the height as needed
              ),
              const SizedBox(height: 10),
              const Text(
                'Do you really want to say\nGoodbye to your soulmate?',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
          actions: <Widget>[
            // Cancel button
            CupertinoDialogAction(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
            // Turn Off button (destructive)
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final uuid = prefs.getString('uuid') ?? '';

                // 🔥 서버에서 유저 삭제 요청
                await ApiService().deleteUser(uuid);

                // 🧼 로컬 데이터 초기화 (필수는 아님, 원하면 유지해도 됨)
                await prefs.clear();

                // ✅ 삭제 후 온보딩 페이지로 이동 (기존 라우트 모두 제거)
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/onboard', (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangeNicknameSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // ← 배경 투명하게
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9, // ← 높이 90%
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ChangeNicknamePage(
            uuid: _uuid,
          ),
        ),
      ),
    );
  }

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastEaseInToSlowEaseOut,
          padding: MediaQuery.of(context).viewInsets,
          child: FractionallySizedBox(
            heightFactor: 0.9,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: const NotificationSettingsPage(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedBackground =
        Provider.of<BackgroundProvider>(context).selectedBackground ??
            'assets/background/airport.png';

    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            selectedBackground,
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // 흐림 정도 조절
            child: Container(
              color: Colors.black.withOpacity(0.05), // 약간 어둡게 (선택 사항)
            ),
          ),
          SafeArea(
            // Keeps content below the status bar
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Spacing from the top
                  const SizedBox(height: 50),

                  // --- Profile Avatar Section ---
                  _buildImage(widget.level ?? 0),
                  const SizedBox(height: 20),
                  Text(
                    widget.nickname ?? '  ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  // Spacing before buttons
                  const SizedBox(height: 30),

                  Expanded(
                    flex: 3,
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1, // 정사각형 유지
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildGridButton(
                          context,
                          'Change\nNickname',
                          () => _showChangeNicknameSheet(context),
                          imagePath: 'assets/penguin_egg/penguin_egg_happy.png',
                          backgroundColor:
                              const Color.fromARGB(255, 210, 235, 244),
                        ),
                        _buildGridButton(
                          context,
                          'Notification',
                          () => _showNotificationSheet(context),
                          imagePath: 'assets/dog_egg/dog_egg_happy.png',
                          backgroundColor:
                              const Color.fromARGB(255, 239, 199, 130),
                        ),
                        _buildGridButton(
                          context,
                          'Support',
                          () async {
                            final Email email = Email(
                              body:
                                  'Hi Emogotchi Team,\n\nI would like to ask about...',
                              subject: 'Support Request',
                              recipients: [
                                'emoguchi5@gmail.com'
                              ], // ← 실제 이메일 주소로 변경
                              isHTML: false,
                            );

                            try {
                              await FlutterEmailSender.send(email);
                            } catch (e) {
                              print('Error sending email: $e');
                            }
                          },
                          imagePath: 'assets/tiger_egg/tiger_egg_happy.png',
                          backgroundColor:
                              const Color.fromARGB(255, 241, 187, 94),
                        ),
                        _buildGridButton(
                          context,
                          'Delete\nAccount',
                          () => _showDeleteAccountConfirmation(context),
                          backgroundColor:
                              const Color.fromARGB(255, 250, 179, 174),
                          textColor: Colors.black,
                          imagePath: 'assets/pig_egg/pig_egg_happy.png',
                        ),
                      ],
                    ),
                  ),

                  // Spacer pushes the footer links to the bottom

                  // // --- Footer Links ---
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 20.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     children: [
                  //       _buildFooterLink('Terms of Service', () {
                  //         // Handle Terms
                  //       }),
                  //       Text(
                  //         '|',
                  //         style: TextStyle(color: Colors.grey[400]),
                  //       ),
                  //       _buildFooterLink('Privacy Policy', () {
                  //         // Handle Privacy
                  //       }),
                  //       Text(
                  //         '|',
                  //         style: TextStyle(color: Colors.grey[400]),
                  //       ),
                  //       _buildFooterLink('Bug Report', () {
                  //         // Handle Bug Report
                  //       }),
                  //       Text(
                  //         '|',
                  //         style: TextStyle(color: Colors.grey[400]),
                  //       ),
                  //       _buildFooterLink('FeedBack', () {
                  //         // Handle Feedback
                  //       }),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
