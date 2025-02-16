import 'package:flutter/material.dart';
import 'api_service.dart'; // APIを利用するためにインポート
import 'package:http/http.dart' as http;
import 'in_thread.dart'; // APIを利用するためにインポート
import 'dart:convert';
import 'dart:async';

class Create_ThreadPage extends StatefulWidget {
  final String username;
  final String password;
  const Create_ThreadPage(this.username,this.password, {Key? key})
      : super(key: key);
  @override
  _Create_ThreadPageState createState() => _Create_ThreadPageState();
}

class _Create_ThreadPageState extends State<Create_ThreadPage> {
  String _message = "Loading...";
  List<dynamic> threadsList = [];
  Timer? _timer;
  final ApiService apiService = ApiService();
  final TextEditingController threadnameController = TextEditingController();


  @override
  void initState() {
    super.initState();
    fetchHelloMessage();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      ThreadGetter(); // 3秒ごとに最新メッセージを取得
    });
  }

  Future<void> fetchHelloMessage() async {
    try {
      String message = await helloRequester();
      if (message == "errer") {
        showErrorDialog();
      } else {
        setState(() {
          _message = message;
        });
      }
    } catch (error) {
      showErrorDialog();
    }
  }

  Future<List<dynamic>> ThreadGetter() async {
    try {
      var postsUri = 'http://localhost:8000/threads/'; // 実際のAPIのURLに変更
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
        List<Map<String, dynamic>> threads = List<Map<String, dynamic>>.from(decoded["thread"]);

        setState(() {
          threadsList = threads;
        });
        // print(postList[0]['thread_id'].runtimeType);
        // List filteredPosts = postList.where((post) => post["thread_id"] == int.parse(thread_id)).toList();
        print(threadsList);
        return threadsList;
      } else {
        print("Failed to fetch messages: ${response.body}");
        throw Exception(response.statusCode);

      }
    }catch(e){
      throw Exception('Error occurred: $e');
      // return ('エラー${e}');

    }
  }

  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("認証に失敗しました。再ログインをお願いします。"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    ).then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFD9D9D9),
        title: Text('スレッド'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            threadsList.isEmpty?
            Center(child: Text("スレッドなし"))
                :SizedBox(
              height: 500, // 適当な高さを設定
              child: ListView.builder(
                itemCount: threadsList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(threadsList[index]["title"]),
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
                    child:TextField(
                      controller: this.threadnameController,
                      decoration: InputDecoration(labelText: 'スレッドの名前'),
                    ),
                  ),
                  new  SizedBox(
                    width:150,
                    height: 80,// 幅を調整
                    child:ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Color(0xFFD9D9D9)),
                      ),
                      onPressed: () async {
                        String title = threadnameController.text;
                        if (widget.username.isNotEmpty && widget.password.isNotEmpty&&title.isNotEmpty) {
                          try {
                            Map<String, dynamic> data2 = {
                              'title': title,
                            };
                            String response = await apiService.ThreadCreater(data2);
                            print(response);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Response: ${response.toString()}')),
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  In_ThreadPage(widget.username,
                                      widget.password,
                                      response,
                                      title)),
                            );


                          } catch (e) {
                            setState(() {
                            });
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
                        "スレッド作成",
                        style: TextStyle(
                          fontSize: 25,
                          color:Color(0xFF000000),
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
