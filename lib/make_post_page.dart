import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MakePostPage extends StatefulWidget {
  const MakePostPage({
    super.key,
    required this.thread_id,
    required this.user_id,
  });

  final String thread_id;
  final String user_id;

  @override
  State<MakePostPage> createState() => _MakePostPageState();
}

class _MakePostPageState extends State<MakePostPage> {
  final TextEditingController _controller = TextEditingController();
  bool isSecret = false;

  void post() async {
    // 入力内容を投稿
    final String text = _controller.text;

    // 投稿を作成
    final post = {
      'thread_id' : widget.thread_id,
      'is_secret' : isSecret,
      'post_num' : 0,
      'text' : text,
    };

    const String apiUrl = 'http://10.0.2.2:8000/post/';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type' : 'application/json'},
        body: json.encode(post),
      );

      if (response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        print('Post created: $responseBody');

        // スレッドのページに遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MakePostPage(thread_id: '', user_id: '',)
          )
        );
      } else {
        print('Failed to create post: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('スレッドに投稿する'),
        backgroundColor: Colors.grey,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Column(
            children: [
              Text('投稿先スレッド: スレッドタイトル',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 20.0,),
              TextField(
                controller: _controller,
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
                    }
                  ),
                  Text('匿名で投稿する')
                ],
              ),
              SizedBox(height: 30.0,),
              ElevatedButton(
                onPressed: () {
                  if (_controller.text.length >= 1) {
                    post();
                  } else {null;}
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
        )
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MakePostPage(thread_id: 'thread', user_id: 'user'),
  ));
}
