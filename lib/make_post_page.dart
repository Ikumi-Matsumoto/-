import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'post_view.dart';

class MakePostPage extends StatefulWidget {
  final int thread_id;
  final String authToken;

  MakePostPage({required this.thread_id, required this.authToken});

  @override
  State<MakePostPage> createState() => _MakePostPageState();
}

class _MakePostPageState extends State<MakePostPage> {
  final TextEditingController _controller = TextEditingController();
  bool isSecret = false;

  void post() async {
    final String text = _controller.text;

    final post = {
      'thread_id': widget.thread_id,
      'is_secret': isSecret,
      'post_num': 0,
      'text': text,
    };

    const String apiUrl = 'http://localhost:8000/posts/';

    debugPrint("📤 投稿開始: $post");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.authToken}', // ✅ 認証トークンを追加
        },
        body: json.encode(post),
      );

      debugPrint("📩 サーバー応答: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        debugPrint("✅ 投稿成功: $responseBody");

        // スレッドのページに遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PostView(thread_id: widget.thread_id, authToken: widget.authToken),
          ),
        );
      } else {
        debugPrint("❌ 投稿失敗 (ステータスコード: ${response.statusCode}): ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('投稿に失敗しました: ${response.body}')),
        );
      }
    } catch (e, stacktrace) {
      debugPrint("🚨 エラー発生: $e\n$stacktrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スレッドに投稿する'),
        backgroundColor: Colors.grey,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const Text(
                '投稿先スレッド: スレッドタイトル',
                style: TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.multiline,
                maxLines: 10,
                maxLength: 140,
                decoration: const InputDecoration(
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
                      }),
                  const Text('匿名で投稿する')
                ],
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    post();
                  } else {
                    debugPrint("⚠️ 投稿内容が空です");
                  }
                },
                child: const Text(
                  '投稿',
                  style: TextStyle(
                    fontSize: 22.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
