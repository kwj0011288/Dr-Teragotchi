import 'package:emogotchi/api/api.dart';
import 'package:emogotchi/pages/main/calendarpage.dart';
import 'package:emogotchi/pages/main/homepage.dart';
import 'package:emogotchi/pages/onboard/chatpage.dart';
import 'package:emogotchi/pages/setting/settingpage.dart';
import 'package:emogotchi/provider/uuid_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 1;
  bool _isChatMode = false;

  bool _isDataReady = false;
  Set<DateTime> _dataAvailableDays = {};
  Map<String, Map<String, String>> _emotionAndSummaryByDate = {};
  String _animalType = 'dog';
  String _nickname = ''; // ✅ 추가
  int _level = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  Future<void> _loadInitialData() async {
    final uuidProvider =
        Provider.of<DeviceInfoProvider>(context, listen: false);
    await uuidProvider.fetchDeviceUuid();
    final uuid = uuidProvider.uuid;

    if (uuid == null || uuid.isEmpty) return;

    final api = ApiService();
    final prefs = await SharedPreferences.getInstance();

    try {
      final entries = await api.getDiaryDates(uuid);
      final Set<DateTime> tempDates = {};
      final Map<String, Map<String, String>> tempData = {};

      for (var entry in entries) {
        final dateString = entry['date']!;
        final parts = dateString.split('-');
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        tempDates.add(date);
        tempData[dateString] = {
          'emotion': entry['emotion']!,
          'summary': entry['summary']!,
        };
      }

      final userInfo = await api.getUser(uuid); // ✅ 닉네임도 받아오기
      final type = userInfo['animal_type'] ?? 'dog';
      final nickname = userInfo['nickname'] ?? '';
      final level = userInfo['level'] ?? 0;

      final shouldAutoOpenChat = prefs.getBool('shouldAutoOpenChat') ?? false;

      setState(() {
        _dataAvailableDays = tempDates;
        _emotionAndSummaryByDate = tempData;
        _animalType = type.toLowerCase();
        _nickname = nickname; // ✅ 저장
        _isDataReady = true;
      });
      if (shouldAutoOpenChat) {
        prefs.setBool('shouldAutoOpenChat', false); // ✅ 리셋

        setState(() {
          _isChatMode = true; // ✅ ChatPage로 전환!
          _currentIndex = 1;
        });
      }
    } catch (e) {
      print("Loading error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isChatPage = _currentIndex == 1 && _isChatMode;

    Widget currentPage;
    if (_currentIndex == 0) {
      if (_isDataReady) {
        currentPage = CalendarPage(
          dataAvailableDays: _dataAvailableDays,
          emotionAndSummaryByDate: _emotionAndSummaryByDate,
          animalType: _animalType,
        );
      } else {
        currentPage = const HomePage();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('잠시만 기다려주세요. 데이터를 불러오는 중입니다.'),
              duration: Duration(seconds: 2),
            ),
          );
        });
      }
    } else if (_currentIndex == 2) {
      currentPage = SettingPage(
        animalType: _animalType,
        nickname: _nickname,
        level: _level,
      );
    } else {
      currentPage = _isChatMode ? const ChatPage() : const HomePage();
    }

    return Scaffold(
      extendBody: true,
      body: currentPage,
      bottomNavigationBar: isChatPage
          ? null
          : SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: (_currentIndex == 0 || _currentIndex == 2)
                      ? Colors.transparent
                      : Colors.transparent,
                ),
                child: BottomNavigationBar(
                  backgroundColor: (_currentIndex == 0 || _currentIndex == 2)
                      ? Colors.transparent
                      : Colors.transparent,
                  elevation: 0,
                  currentIndex: _currentIndex,
                  onTap: (int index) {
                    setState(() {
                      if (index == 1) {
                        if (_currentIndex != 1) {
                          _isChatMode = false;
                        } else {
                          _isChatMode = !_isChatMode;
                        }
                      } else {
                        _isChatMode = false;
                      }
                      _currentIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.black,
                  unselectedItemColor: Colors.black54,
                  iconSize: 30,
                  showUnselectedLabels: false,
                  showSelectedLabels: false,
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(
                        FeatherIcons.calendar,
                        color: Colors.black,
                      ),
                      activeIcon: Icon(
                        FeatherIcons.calendar,
                        color: Colors.white,
                      ),
                      label: '캘린더',
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: (_currentIndex == 0 || _currentIndex == 2)
                              ? Colors.white.withOpacity(0.3)
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            (_currentIndex == 0 || _currentIndex == 2)
                                ? BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  )
                                : BoxShadow(
                                    color: Colors.transparent,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            (_currentIndex == 0 || _currentIndex == 2)
                                ? FeatherIcons.home
                                : FeatherIcons.messageCircle,
                            color: (_currentIndex == 0 || _currentIndex == 2)
                                ? Colors.white.withOpacity(0.5)
                                : Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      label: '홈/일기',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(
                        FeatherIcons.settings,
                        color: Colors.black,
                      ),
                      activeIcon: Icon(
                        FeatherIcons.settings,
                        color: Colors.white,
                      ),
                      label: '설정',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
