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
      'title' : title,
    };

    final post = {
      'thread_id' : 0,
      'is_secret' : isSecret,
      'post_num' : 0,
      'text' : text,
    };

    const String apiUrl = 'http://10.0.2.2:8000/thread/';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type' : 'application/json'},
        body: json.encode(thread),
      );

      if (response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        print('Thread created: $responseBody');


        // スレッドのページに遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MakeThreadPage(user_id: widget.user_id,)
          )
        );
      } else {
        print('Failed to create thread: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('スレッドの作成に失敗しました。')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました。ネットワークを確認してください。'))
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
              Text('新しいスレッドを作成',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 20.0,),
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
                    }
                  ),
                  Text('匿名で投稿する')
                ],
              ),
              SizedBox(height: 30.0,),
              ElevatedButton(
                onPressed: () {
                  if ((_titleController.text.length >= 1) && (_postController.text.length >= 1)) {
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
    home: MakeThreadPage(user_id: 'user'),
  ));
}
