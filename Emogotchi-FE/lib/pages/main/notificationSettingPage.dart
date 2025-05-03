import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationSettingsPage extends StatefulWidget {
  final BuildContext? closeContext;

  const NotificationSettingsPage({super.key, this.closeContext});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _allNotificationsEnabled = true;
  bool _soundNotificationsEnabled = false;

  TimeOfDay? _firstTime;
  TimeOfDay? _secondTime;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await flutterLocalNotificationsPlugin.initialize(settings);

    // 🔔 iOS 알림 권한 요청
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? firstHour = prefs.getInt('first_hour');
    int? firstMinute = prefs.getInt('first_minute');
    int? secondHour = prefs.getInt('second_hour');
    int? secondMinute = prefs.getInt('second_minute');

    if (firstHour != null && firstMinute != null) {
      setState(() {
        _firstTime = TimeOfDay(hour: firstHour, minute: firstMinute);
      });
    }
    if (secondHour != null && secondMinute != null) {
      setState(() {
        _secondTime = TimeOfDay(hour: secondHour, minute: secondMinute);
      });
    }
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final now = DateTime.now();
    TimeOfDay initialTime = _firstTime ?? TimeOfDay.now();

    if (_firstTime != null && _secondTime != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('first_hour', _firstTime!.hour);
      await prefs.setInt('first_minute', _firstTime!.minute);
      await prefs.setInt('second_hour', _secondTime!.hour);
      await prefs.setInt('second_minute', _secondTime!.minute);
    }

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(
                  now.year,
                  now.month,
                  now.day,
                  initialTime.hour,
                  initialTime.minute,
                ),
                use24hFormat: false,
                onDateTimeChanged: (DateTime newDate) {
                  TimeOfDay selected = TimeOfDay.fromDateTime(newDate);
                  setState(() {
                    _firstTime = selected;
                    _secondTime = TimeOfDay(
                      hour: (selected.hour + 8) % 24,
                      minute: selected.minute,
                    );
                  });
                },
              ),
            ),
            CupertinoButton(
                child: const Text(
                  "Done",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 20),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();

                  if (_firstTime != null && _secondTime != null) {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setInt('first_hour', _firstTime!.hour);
                    await prefs.setInt('first_minute', _firstTime!.minute);
                    await prefs.setInt('second_hour', _secondTime!.hour);
                    await prefs.setInt('second_minute', _secondTime!.minute);

                    _scheduleNotification(_firstTime!,
                        id: 0, title: 'Good Morning ☀️');
                    _scheduleNotification(_secondTime!,
                        id: 1, title: 'How are you feeling today? 💬');
                  }
                })
          ],
        ),
      ),
    );
  }

  Future<void> _scheduleNotification(TimeOfDay time,
      {required int id, required String title}) async {
    final now = DateTime.now();
    final scheduledDate = tz.TZDateTime.local(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    final tz.TZDateTime finalSchedule =
        scheduledDate.isBefore(tz.TZDateTime.now(tz.local))
            ? scheduledDate.add(const Duration(days: 1))
            : scheduledDate;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      'Your scheduled notification body here', // Replace with the desired notification body
      finalSchedule,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'Emogotchi',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'fromNotification', // ✨ payload 설정
    );
  }

  void _showTurnOffDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Turn off Notifications?'),
        content: Column(
          children: [
            const SizedBox(height: 10),
            Image.asset('assets/penguin/penguin_sad.png', height: 100),
            const SizedBox(height: 10),
            const Text("Your SoulMate wants to be with you!"),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Turn Off'),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _allNotificationsEnabled = false;
              });
            },
          ),
        ],
      ),
    );
  }

  // ✅ Test Notification Function
  void _sendTestNotification() {
    final now = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    flutterLocalNotificationsPlugin.zonedSchedule(
        999,
        'Test Notification',
        'This is a test 🚀',
        now,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Channel',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'fromNotification');
  }

  Widget _buildTimeDisplay(String label, TimeOfDay? time) {
    return Opacity(
      opacity: _allNotificationsEnabled ? 1 : 0.4,
      child: IgnorePointer(
        ignoring: !_allNotificationsEnabled,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            Text(
              time != null ? time.format(context) : "--:--",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Transform.scale(
        scale: 1.2,
        child: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green,
        ),
      ),
    );
  }

  Future<void> setNotifications() async {
    if (_firstTime != null && _secondTime != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('first_hour', _firstTime!.hour);
      await prefs.setInt('first_minute', _firstTime!.minute);
      await prefs.setInt('second_hour', _secondTime!.hour);
      await prefs.setInt('second_minute', _secondTime!.minute);

      await _scheduleNotification(_firstTime!, id: 0, title: 'Good Morning ☀️');
      await _scheduleNotification(_secondTime!,
          id: 1, title: 'How are you feeling today? 💬');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림이 성공적으로 설정되었습니다!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시간을 먼저 설정해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background/park.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // ✅ 둥글게
      ),
      child: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: 0, top: 0, bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(widget.closeContext ?? context).pop();
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.withOpacity(0.5),
                        child: Center(
                          child:
                              Icon(Icons.close, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Notification",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                _buildCustomSwitch(
                  title: "All Notifications",
                  value: _allNotificationsEnabled,
                  onChanged: (val) {
                    if (!val) {
                      _showTurnOffDialog();
                    } else {
                      setState(() => _allNotificationsEnabled = true);
                    }
                  },
                ),
                const Divider(color: Colors.white),
                Opacity(
                  opacity: _allNotificationsEnabled ? 1 : 0.4,
                  child: IgnorePointer(
                    ignoring: !_allNotificationsEnabled,
                    child: _buildCustomSwitch(
                      title: "Notification Sound",
                      value: _soundNotificationsEnabled,
                      onChanged: (val) =>
                          setState(() => _soundNotificationsEnabled = val),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Opacity(
                  opacity: _allNotificationsEnabled ? 1 : 0.4,
                  child: IgnorePointer(
                    ignoring: !_allNotificationsEnabled,
                    child: Column(
                      children: [
                        const Center(
                          child: Text(
                            "Start your Day with Emogotchi!",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () => _showTimePicker(context),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: _buildTimeDisplay(
                                "First Time Received", _firstTime),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: _buildTimeDisplay(
                              "Second Time Received", _secondTime),
                        ),
                        const SizedBox(height: 30),
                        const SizedBox(height: 20),
                        Center(
                          child: Image.asset(
                            'assets/penguin/penguin_eye_close.png',
                            height: 100,
                          ),
                        ),
                        CupertinoButton(
                          color: Colors.white.withOpacity(0.7),
                          // onPressed: _allNotificationsEnabled
                          //     ? _sendTestNotification
                          //     : null,
                          onPressed: _allNotificationsEnabled
                              ? setNotifications
                              : null,

                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          child: const Text(
                            "Send Test Notification",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
