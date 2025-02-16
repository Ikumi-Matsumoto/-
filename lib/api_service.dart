import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

final storage = new FlutterSecureStorage();

// class Post {
//   post(this.id, this.thread_id,this.user_id);
//
//   String? id;
//   dynamic? thread_id;
//   dynamic? user_id;
// }


class AuthResponse {
  final String accessToken;

  AuthResponse.fromJson(Map<String, dynamic> json)
      : accessToken = json['access_token'];
}

class HelloResponse {
  final id;

  HelloResponse.fromJson(Map<String, dynamic> json) : id = json['id'];
}

class MessageResponse {
  final id;
  // final text;

  MessageResponse.fromJson(Map<String, dynamic> json) : id = json['id'];

}

class ThreadsResponse {
  final id;

  ThreadsResponse.fromJson(Map<String, dynamic> json) : id = json['id'];
}

class ApiService {
  final String apiUrl = 'http://localhost:8000/users/'; // 実際のAPIのURLに変更
  final String apiUrl_token = 'http://localhost:8000/token/';

  Future<Map<String, dynamic>> sendPostRequest(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body); // サーバーのレスポンスを返す
      }
      if (response.statusCode == 400) {
        throw Exception('このユーザー名は既に使われています。');
      }
      else {
        throw Exception('Failed to send data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<String> MessageCreater(Map<String, dynamic> data) async {
    try {
      print(data);
      var threadsUri = 'http://localhost:8000/posts/'; // 実際のAPIのURLに変更

      var accessToken = await storage.read(key: "accessToken");
      print('ストレージ${accessToken}');

      final response = await http.post(
        Uri.parse(threadsUri),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${accessToken}',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 307) {
        // 307 の場合、リダイレクト先のURLを取得
        print(307!);
        final newUrl = response.headers['location'];
        print(newUrl);
        if (newUrl != null) {
          print('Redirecting to: $newUrl');

          final redirectedResponse = await http.post(
            Uri.parse(newUrl),
            headers: {'accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${accessToken}',
            },

            body: jsonEncode(data),
          );

          print('Redirected response: ${redirectedResponse.body}');
          Map<String, dynamic> decoded = json.decode(response.body);
          var helloResponse = HelloResponse.fromJson(decoded);
          print('スレッドのID${helloResponse.id.toString()}');

          return helloResponse.id.toString();
        } else {
          print('Error: 307 received but no Location header found');
          throw Exception(response.statusCode);
        }
      }

      else if (response.statusCode == 200) {

        Map<String, dynamic> decoded = json.decode(response.body);
        print('中身${response.body}');
        var threadsResponse = ThreadsResponse.fromJson(decoded);
        return threadsResponse.id.toString();


      } else if (response.statusCode == 401 || response.statusCode == 404) {
        print("send refreshTokenRequester");
        return ('errer');
      }
      else {
        print('レスポンスが返ってきている');
        print(response.statusCode);
        print('から？${response.body}');
        Map<String, dynamic> decoded = json.decode(response.body);
        var threadsResponse = ThreadsResponse.fromJson(decoded);
        print('中身${threadsResponse}');
        print(response.body);

        throw Exception(response.statusCode);
      }
    }catch(e){
      // throw Exception('Error occurred: $e');
      print('h');
      return ('エラー${e}');

    }
  }


  Future<List<dynamic>> MessageGetter(String thread_id) async {
    try {
      var postsUri = 'http://localhost:8000/posts/'; // 実際のAPIのURLに変更
      var accessToken = await storage.read(key: "accessToken");
      final response = await http.get(
        Uri.parse(postsUri),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer ${accessToken}',
        },
      );
      if (response.statusCode == 200) {
        Map<String,dynamic> decoded = json.decode(response.body);
        print(decoded);
        List<Map<String, dynamic>> postList = List<Map<String, dynamic>>.from(decoded["post"]);
        print('h${thread_id.runtimeType}');
        print(postList[0]['thread_id'].runtimeType);
        List filteredPosts = postList.where((post) => post["thread_id"] == int.parse(thread_id)).toList();
        print(filteredPosts);
        return filteredPosts;
      } else {
        print("Failed to fetch messages: ${response.body}");
        throw Exception(response.statusCode);

      }
    }catch(e){
      throw Exception('Error occurred: $e');
      // return ('エラー${e}');

    }
  }


  Future<String> ThreadCreater(Map<String, dynamic> data) async {
    try {
      print('threadsRequester');
      print(data);
      var threadsUri = 'http://localhost:8000/threads/'; // 実際のAPIのURLに変更

      var accessToken = await storage.read(key: "accessToken");
      print('ストレージ${accessToken}');

      final response = await http.post(
        Uri.parse(threadsUri),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${accessToken}',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 307) {
        // 307 の場合、リダイレクト先のURLを取得
        print(307!);
        final newUrl = response.headers['location'];
        print(newUrl);
        if (newUrl != null) {
          print('Redirecting to: $newUrl');

          final redirectedResponse = await http.post(
            Uri.parse(newUrl),
            headers: {'accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${accessToken}',
            },

            body: jsonEncode(data),
          );

          print('Redirected response: ${redirectedResponse.body}');
          Map<String, dynamic> decoded = json.decode(response.body);
          var helloResponse = HelloResponse.fromJson(decoded);
          print('スレッドのID${helloResponse.id.toString()}');

          return helloResponse.id.toString();
        } else {
          print('Error: 307 received but no Location header found');
          throw Exception(response.statusCode);
        }
      }

      else if (response.statusCode == 200) {

        Map<String, dynamic> decoded = json.decode(response.body);
        print('中身${response.body}');
        var threadsResponse = ThreadsResponse.fromJson(decoded);
        return threadsResponse.id.toString();


      } else if (response.statusCode == 401 || response.statusCode == 404) {
        print("send refreshTokenRequester");
        return ('errer');
      }
      else {
        print('レスポンスが返ってきている');
        print(response.statusCode);
        print('から？${response.body}');
        Map<String, dynamic> decoded = json.decode(response.body);
        var threadsResponse = ThreadsResponse.fromJson(decoded);
        print('中身${threadsResponse}');
        print(response.body);

        throw Exception(response.statusCode);
      }
    }catch(e){
      // throw Exception('Error occurred: $e');
      print('h');
      return ('エラー${e}');

    }
  }







  Future<String?> sendGetTokenRequest(String username, String password) async {
    final apiUrl = Uri.parse('http://localhost:8000/token/');

    final response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'password',
        'username': username,
        'password': password,
        'scope': '',
        'client_id': '',
        'client_secret': '',
      },
    );

    print('ログインAPIのレスポンス: ${response.body}'); // ← レスポンスを確認

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token']; // トークンを返す
    } else {
      throw Exception('ログインに失敗しました: ${response.body}');
    }
  }
}

Future<String> helloRequester() async {
  try {
    print('helloRequester');
    var helloUri = 'http://localhost:8000/users/user'; // 末尾のスラッシュ削除

    var accessToken = await storage.read(key: "accessToken");

    if (accessToken == null || accessToken.isEmpty) {
      print('アクセストークンがありません');
      return 'エラー: トークンがありません';
    }

    print('ストレージから読んだ: $accessToken');

    final response = await http.get(
      Uri.parse(helloUri),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('レスポンスコード: ${response.statusCode}');
    print('レスポンス内容: ${response.body}');

    if (response.statusCode == 200) {
      Map<String, dynamic> decoded = json.decode(response.body);
      print('レスポンス内容: $decoded');
      var helloResponse = HelloResponse.fromJson(decoded);
      return helloResponse.id.toString();
    } else if (response.statusCode == 401) {
      print("認証エラー: アクセストークンが無効");
      return 'エラー: 認証エラー';
    } else if (response.statusCode == 307) {
      print("リダイレクトエラー: URLを確認してください");
      return 'エラー: リダイレクトエラー';
    } else {
      print('エラー: ${response.statusCode}');
      return 'エラー: 不明なエラー';
    }
  } catch (e) {
    print('例外発生: $e');
    return 'エラー: $e';
  }
}
