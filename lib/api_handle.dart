import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = new FlutterSecureStorage();


class AuthResponse {
  final String accessToken;

  AuthResponse.fromJson(Map<String, dynamic> json)
      : accessToken = json['access_token'];
}

class HelloResponse {
  final id;

  HelloResponse.fromJson(Map<String, dynamic> json) : id = json['id'];
}

class ApiService {
  final String apiUrl = 'http://10.0.2.2:8000/users/'; // 実際のAPIのURLに変更
  final String apiUrl_token = 'http://10.0.2.2:8000/token/';
  final String threadUrl = 'http://10.0.2.2:8000/threads/'; // スレッド用APIエンドポイント


  Future<Map<String, dynamic>> sendPostRequest(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body); // サーバーのレスポンスを返す
      } else {
        throw Exception('Failed to send data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> sendGetTokenRequest(String data) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl_token),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'accept': 'application/json'
        },
        body: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.body.toString());
        Map<String, dynamic> decoded = json.decode(response.body);
        var loginResponse = AuthResponse.fromJson(decoded);
        print(loginResponse.accessToken);
        await storage.write(key: "accessToken", value: loginResponse.accessToken);
        var accessToken = await storage.read(key: "accessToken");
        return jsonDecode(response.body);
        // サーバーのレスポンスを返す
      } else {
        throw Exception('Failed to send data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  // 新しいスレッドを追加するメソッド
  Future<Map<String, dynamic>> addThread(Map<String, dynamic> threadData) async {
    try {
      // ストレージからアクセストークンを取得
      var accessToken = await storage.read(key: "accessToken");
      if (accessToken == null) {
        throw Exception('アクセストークンが見つかりません。ログインしてください。');
      }

      final response = await http.post(
        Uri.parse(threadUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(threadData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('スレッド作成に失敗しました。ステータスコード: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('スレッド作成中にエラーが発生しました: $e');
    }
  }
}

Future<String> helloRequester() async {
  try {
    print('helloRequester');
    var helloUri = 'http://10.0.2.2:8000/users/user'; // 実際のAPIのURLに変更

    var accessToken = await storage.read(key: "accessToken");
    print('ストレージ${accessToken}');
    final response = await http.get(
      Uri.parse(helloUri),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer ${accessToken}',
      },
    );

    if (response.statusCode == 200) {

      Map<String, dynamic> decoded = json.decode(response.body);
      print('中身${response.body}');
      var helloResponse = HelloResponse.fromJson(decoded);
      return helloResponse.id.toString();


    } else if (response.statusCode == 401 || response.statusCode == 404) {
      print("send refreshTokenRequester");
      return ('errer');
    }
    else {
      throw Exception("Hello Error");
    }
  }catch(e){
    // throw Exception('Error occurred: $e');
    return ('エラー${e}');

  }
}

