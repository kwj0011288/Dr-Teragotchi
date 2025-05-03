import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://cb07-64-92-84-106.ngrok-free.app";

  Future<Map<String, dynamic>> postOnboarding(
      String uuid, String nickname) async {
    final url = Uri.parse('$baseUrl/onboarding');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uuid': uuid, 'nickname': nickname}),
    );

    if (response.statusCode == 500 || response.statusCode == 200) {
      print("worked");
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to post onboarding: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> postMessage(
      String message, String userUuid, String emotion) async {
    final url = Uri.parse('$baseUrl/chat');

    final payload = {
      'message': message,
      'uuid': userUuid,
      'emotion': emotion,
    };

    print("📤 Sending POST to $url");
    print("📦 JSON Payload: ${jsonEncode(payload)}");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 500) {
        final decoded = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(decoded);

        print("✅ Response Data: $responseData");

        return {
          'response': responseData['response'] ?? '',
          'emotion': responseData['emotion'],
          'animal': responseData['animal'],
          'points': responseData['points'],
          'isFifth': responseData['isFifth'] ?? false,
        };
      } else {
        print("❌ Failed with status code: ${response.statusCode}");
        throw Exception('Failed to post message: ${response.statusCode}');
      }
    } catch (e) {
      print("🔥 Error occurred: $e");
      throw Exception('Error posting message: $e');
    }
  }

  Future<Map<String, dynamic>> getUser(String uuid) async {
    final url = Uri.parse('$baseUrl/user/$uuid');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch user: ${response.statusCode}');
      }
    } catch (e) {
      print("Error occurred: $e");
      throw Exception('Error fetching user: $e');
    }
  }

  Future<List<Map<String, String>>> getDiaryDates(String uuid) async {
    final url = Uri.parse('$baseUrl/diary/dates?uuid=$uuid');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        assert(() {
          print("Diary dates: $responseData");
          return true;
        }());

        return responseData
            .map<Map<String, String>>((entry) => {
                  'date': entry['date'].toString(),
                  'summary': entry['summary'].toString(),
                  'emotion': entry['emotion'].toString(),
                })
            .toList();
      } else {
        throw Exception(
          'Failed to fetch diary dates (status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print("Error occurred: $e");
      throw Exception('Error fetching diary dates: $e');
    }
  }

  Future<Map<String, dynamic>> generateDiary(String uuid) async {
    final url = Uri.parse('$baseUrl/diary/generate?uuid=$uuid');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uuid': uuid}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'message': responseData['message'],
          'date': responseData['date'],
          'summary': responseData['summary'],
          'emotion': responseData['emotion'],
        };
      } else {
        throw Exception(
          'Failed to generate diary (status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print("Error occurred: $e");
      throw Exception('Error generating diary: $e');
    }
  }

  Future<void> updateUserPoints(String uuid, int points) async {
    final url = Uri.parse('$baseUrl/user/update/points');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uuid': uuid, 'points': points}),
      );

      if (response.statusCode == 200) {
        print("✅ Points updated successfully");
      } else {
        throw Exception(
          'Failed to update user points (status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print("Error occurred: $e");
      throw Exception('Error updating user points: $e');
    }
  }

  Future<void> updateUserLevel(String uuid, int animalLevel) async {
    final url = Uri.parse('$baseUrl/user/update/level/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uuid': uuid, 'animal_level': animalLevel}),
      );

      if (response.statusCode == 200) {
        log("✅ User level updated successfully");
      } else {
        throw Exception(
          'Failed to update user level (status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      log("Error occurred: $e");
      throw Exception('Error updating user level: $e');
    }
  }

  Future<void> updateUserName(String uuid, String newNickname) async {
    final url = Uri.parse('$baseUrl/user/update/name/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uuid': uuid, 'nickname': newNickname}),
      );

      if (response.statusCode == 200) {
        log("✅ User name updated successfully");
      } else {
        throw Exception(
          'Failed to update user name (status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      log("Error occurred: $e");
      throw Exception('Error updating user name: $e');
    }
  }

  Future<Map<String, dynamic>> deleteUser(String uuid) async {
    final url = Uri.parse('$baseUrl/user/$uuid');

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to delete user (status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      log("Error occurred: $e");
      throw Exception('Error deleting user: $e');
    }
  }
}
