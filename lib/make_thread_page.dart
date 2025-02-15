import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MakeThreadPage extends StatefulWidget {
  const MakeThreadPage({
    super.key,
    required this.user_id,
  });

  final String user_id;

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

    // スレッドを作成
    final thread = {
      'title': title,
    };

    const String apiUrl = 'http://10.0.2.2:8000/posts/';

    try {
      final response1 = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(thread),
      );

      if (response1.statusCode == 201) {
        final responseBody = json.decode(response1.body);
        print('Thread created: $responseBody');

        // スレッドIDを取得
        final thread_id = responseBody['id'];

        // 投稿を作成
        final post = {
          'thread_id': thread_id,
          'is_secret': isSecret,
          'post_num': 0,
          'text': text,
        };

        // 現在の最大のpost_numを取得
        final response2 = await http.get(Uri.parse('http://10.0.2.2:8000/posts/?thread_id=${thread_id}'));
        if (response2.statusCode == 200) {
          final List<dynamic> posts = json.decode(response2.body);
          int maxPostNum = 0;
          for (var post in posts) {
          if (post['post_num'] > maxPostNum) {
            maxPostNum = post['post_num'];
          }
          }
          post['post_num'] = maxPostNum + 1;
        } else {
          print('Failed to fetch posts: ${response2.body}');
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch posts: ${response2.body}')),
          );
          return;
        }

        try {
          final response3 = await http.post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(post),
          );

          if (response3.statusCode == 201) {
            final responseBody = json.decode(response3.body);
            print('Post created: $responseBody');

            // スレッドのページに遷移
            Navigator.push(context,
              MaterialPageRoute(
                builder: (context) => MakeThreadPage(
                      user_id: '',
                )
              )
            );
          } else {
            print('Failed to create post: ${response3.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed to create post: ${response3.body}')),
            );
          }
        } catch (e) {
          print('Error occurred: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error occurred: $e')),
          );
        }
      } else {
        print('Failed to create thread: ${response1.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('スレッドの作成に失敗しました。')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('エラーが発生しました。ネットワークを確認してください。')));
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
            Text(
              '新しいスレッドを作成',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(
              height: 20.0,
            ),
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
                    }),
                Text('匿名で投稿する')
              ],
            ),
            SizedBox(
              height: 30.0,
            ),
            ElevatedButton(
              onPressed: () {
                if ((_titleController.text.length >= 1) &&
                    (_postController.text.length >= 1)) {
                  post();
                } else {
                  null;
                }
              },
              child: Text(
                '投稿',
                style: TextStyle(
                  fontSize: 22.0,
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MakeThreadPage(user_id: 'user'),
  ));
}
