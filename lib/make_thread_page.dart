import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'thread_view.dart';

class MakeThreadPage extends StatefulWidget {
  final String authToken;

  MakeThreadPage({required this.authToken});

  @override
  State<MakeThreadPage> createState() => _MakeThreadPageState();
}

class _MakeThreadPageState extends State<MakeThreadPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  bool isSecret = false;

  void post() async {
    final String title = _titleController.text;
    final String text = _postController.text;

    // スレッド作成リクエスト
    final thread = {
      'title': title,
    };
    const String threadUrl = 'http://localhost:8000/threads/';
    const String postUrl = 'http://localhost:8000/posts/';

    try {
      print("🔵 スレッド作成リクエスト送信: $thread");
      final response1 = await http.post(
      Uri.parse(threadUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.authToken}',
      },
      body: json.encode(thread),
      );

      print("🟢 スレッド作成レスポンス: ${response1.statusCode} - ${response1.body}");

      if (response1.statusCode == 200) {
      final responseBody = json.decode(response1.body);
      final thread_id = responseBody['id'];

      print("✅ スレッド作成成功: ID=$thread_id");

      // 投稿作成リクエスト
      final post = {
        'thread_id': thread_id,
        'is_secret': isSecret,
        'post_num': 0,
        'text': text,
      };

      try {
        print("🔵 投稿作成リクエスト送信: $post");
        final response3 = await http.post(
        Uri.parse(postUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.authToken}',
        },
        body: json.encode(post),
        );

        print("🟢 投稿作成レスポンス: ${response3.statusCode} - ${response3.body}");

        if (response3.statusCode == 200) {
          final responseBody = json.decode(response3.body);
          print("✅ 投稿作成成功: $responseBody");

          // スレッドページに遷移
          Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => ThreadView(authToken: widget.authToken),
            ),
          );
        } else {
        print("❌ 投稿作成失敗: ${response3.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('投稿作成失敗: ${response3.body}')),
        );
        }
      } catch (e, stackTrace) {
        print("🔥 投稿作成中にエラー発生: $e");
        print(stackTrace);
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('投稿作成中にエラー発生: $e')),
        );
      }
      } else {
      print("❌ スレッド作成失敗: ${response1.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('スレッド作成失敗: ${response1.body}')),
      );
      }
    } catch (e, stackTrace) {
      print("🔥 ネットワークエラー: $e");
      print(stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ネットワークエラー: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('スレッドを作成する'),
        backgroundColor: Colors.grey,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Column(
            children: [
              Text('新しいスレッドを作成', style: TextStyle(fontSize: 18.0)),
              SizedBox(height: 20.0),
              TextField(
                controller: _titleController,
                maxLength: 30,
                decoration: InputDecoration(
                  labelText: 'タイトルを入力',
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                controller: _postController,
                keyboardType: TextInputType.multiline,
                maxLines: 10,
                maxLength: 140,
                decoration: InputDecoration(
                  labelText: '投稿内容を入力',
                  border: OutlineInputBorder(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isSecret,
                    onChanged: (bool? newValue) {
                      setState(() {
                        isSecret = newValue ?? false;
                      });
                    },
                  ),
                  Text('匿名で投稿する')
                ],
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty && _postController.text.isNotEmpty) {
                    post();
                  }
                },
                child: Text('投稿', style: TextStyle(fontSize: 22.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
