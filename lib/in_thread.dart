import 'package:flutter/material.dart';
import 'api_service.dart'; // APIを利用するためにインポート
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';


class In_ThreadPage extends StatefulWidget {
  final String username;
  final String password;
  final String threadId;
  final String title;
  const In_ThreadPage(this.username,this.password,this.threadId,this.title, {Key? key})
      : super(key: key);
  @override
  _In_ThreadPageState createState() => _In_ThreadPageState();
}

class _In_ThreadPageState extends State<In_ThreadPage> {
  final ApiService apiService = ApiService();
  List<dynamic> filteredPosts = [];
  Timer? _timer;
  final TextEditingController messageController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      MessageGetter(widget.threadId); // 3秒ごとに最新メッセージを取得
    });
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
        // List filteredPosts = postList.where((post) => post["thread_id"] == int.parse(thread_id)).toList();
        // print(filteredPosts);
        setState(() {
          filteredPosts = postList.where((post) => post["thread_id"] == int.parse(thread_id)).toList();
        });
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




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFD9D9D9),
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
        filteredPosts.isEmpty?
        Center(child: Text("会話なし"))
        :SizedBox(
          height: 600, // 適当な高さを設定
          child: ListView.builder(
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(filteredPosts[index]["text"]),
                subtitle: Text("投稿ID: ${filteredPosts[index]["user_id"]}"),
              );
            },
          ),
        ),
            new Divider(height: 1.0),
            Container(
              margin: EdgeInsets.only(bottom: 20.0, right: 10.0, left: 10.0),
              child: Row(
                children: <Widget>[
                  new Flexible(
                    child: new TextField(
                      controller: this.messageController,
                          decoration: InputDecoration(labelText: 'メッセージ'),
                    ),
                  ),
                  new Container(
                    child: new ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Color(0xFFD9D9D9)),
                      ),
                      onPressed: () async {
                        String message = messageController.text;
                        if (message.isNotEmpty && widget.password.isNotEmpty) {
                          try {
                            Map<String, dynamic> data2 = {
                              "thread_id": widget.threadId,
                              "is_secret": false,
                              "post_num": 0,
                              "text":message,
                            };
                            String response = await apiService.MessageCreater(data2);
                            print(response);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Response: ${response.toString()}')),
                            );
                            messageController.text='';
                          } catch (e) {
                            setState(() {});
                            print("errer:${e}");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('errer${e}')),
                            );
                          }
                          // await authenticateUser(context, name, password);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('全てのフィールドを入力してください。')),
                          );
                        }
                      },
                      child: Text(
                        "投稿",
                        style: TextStyle(
                          fontSize: 25,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
