import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:emogotchi/api/api.dart';

class ChangeNicknamePage extends StatefulWidget {
  final String? uuid;

  const ChangeNicknamePage({Key? key, this.uuid}) : super(key: key);

  @override
  _ChangeNicknamePageState createState() => _ChangeNicknamePageState();
}

class _ChangeNicknamePageState extends State<ChangeNicknamePage> {
  final TextEditingController _nicknameController = TextEditingController();

  void _saveNickname([String? _]) async {
    final newNickname = _nicknameController.text.trim();
    print("New nickname: $newNickname");
    // 닉네임이 비어있지 않고 uuid가 null이 아닐 때만 API 호출
    print("UUID: ${widget.uuid}");
    if (newNickname.isNotEmpty && widget.uuid != null) {
      try {
        await ApiService().updateUserName(widget.uuid!, newNickname);

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Nickname changed to "$newNickname"!')),
        // );
        Navigator.pop(context);
      } catch (e) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to update nickname.')),
        // );
      }
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Please enter a valid nickname.')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background/airport.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30), // ✅ 위쪽 둥글게
        ),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: Column(
                children: [
                  // 닫기 버튼

                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: 0, top: 0, bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.withOpacity(0.5),
                          child: Center(
                            child: Icon(Icons.close,
                                color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Align(
                  //   alignment: Alignment.topRight,
                  //   child: IconButton(
                  //     icon: const Icon(Icons.close,
                  //         color: Colors.white, size: 28),
                  //     onPressed: () => Navigator.pop(context),
                  //   ),
                  // ),
                  const SizedBox(height: 30),
                  const Text(
                    "Change Nickname?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "You can change your nickname here.\nPlease enter a new nickname.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(bottom: bottomInset + 24),
                    child: CupertinoTextField(
                      controller: _nicknameController,
                      textAlign: TextAlign.center,
                      placeholder: "Enter Name",
                      maxLength: 16,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 20),
                      style: const TextStyle(fontSize: 20),
                      placeholderStyle:
                          const TextStyle(fontSize: 20, color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.7),
                      ),
                      onSubmitted: _saveNickname,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }
}
