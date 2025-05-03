import 'package:emogotchi/const/theme/theme.dart';
import 'package:emogotchi/pages/main/homepage.dart';
import 'package:emogotchi/pages/onboard/chatpage.dart';
import 'package:emogotchi/pages/onboard/emotionpage.dart';
import 'package:emogotchi/pages/onboard/nickname.dart';
import 'package:emogotchi/pages/onboard/onboard.dart';
import 'package:emogotchi/pages/onboard/soulmatepage.dart';
import 'package:emogotchi/pages/rootpage.dart';
import 'package:emogotchi/pages/setting/changeNickname.dart';
import 'package:emogotchi/provider/background_provider.dart';
import 'package:emogotchi/provider/emotion_provider.dart';
import 'package:emogotchi/provider/user_provider.dart';
import 'package:emogotchi/provider/uuid_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ✅ navigatorKey 정의
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// ✅ 알림 플러그인 전역 객체
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const settings = InitializationSettings(
  android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  iOS: DarwinInitializationSettings(),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.clear();

  await flutterLocalNotificationsPlugin.initialize(
    settings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final payload = response.payload;
      if (payload == 'fromNotification') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('shouldAutoOpenChat', true);

        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/rootpage',
          (route) => false,
        );
      }
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => DeviceInfoProvider()),
        ChangeNotifierProvider(create: (context) => EmotionProvider()),
        ChangeNotifierProvider(create: (context) => BackgroundProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,

        /// ✅ navigatorKey 추가
        navigatorKey: navigatorKey,

        home: const CheckAuthPage(),
        routes: {
          '/onboard': (context) => const OnboardPage(),
          '/rootpage': (context) => const RootPage(),
          '/homepage': (context) => const HomePage(),
          '/namepage': (context) => const NamePage(),
          '/chatpage': (context) => const ChatPage(),
          '/emotionpage': (context) => const EmotionPage(),
          '/soulmatepage': (context) => SoulmatePage(),
          '/nickname': (context) => const ChangeNicknamePage(),
        },
      ),
    );
  }
}

class CheckAuthPage extends StatelessWidget {
  const CheckAuthPage({Key? key}) : super(key: key);

  Future<Widget> _decideStartPage(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadFromLocal();

    final autoOpenChat = prefs.getBool('shouldAutoOpenChat') ?? false;
    if (autoOpenChat) {
      await prefs.setBool('shouldAutoOpenChat', false);
      return const ChatPage(); // ✅ 바로 ChatPage로 진입
    }

    return userProvider.userName.isNotEmpty
        ? const RootPage()
        : const OnboardPage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _decideStartPage(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return snapshot.data!;
        } else {
          return const OnboardPage();
        }
      },
    );
  }
}
