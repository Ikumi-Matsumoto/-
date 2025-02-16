import 'package:flutter/material.dart';
import 'thread_view.dart';
import 'api_service.dart';
import 'registration_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PostRequestDemo(),
    );
  }
}

class PostRequestDemo extends StatefulWidget {
  @override
  _PostRequestDemoState createState() => _PostRequestDemoState();
}

class _PostRequestDemoState extends State<PostRequestDemo> {
  final ApiService apiService = ApiService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFD9D9D9),
        title: Text("ログイン"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '名前'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'パスワード'),
              obscureText: true, // パスワード入力を隠す
            ),
            SizedBox(height: 20),
            if (_errorMessage.isNotEmpty) // エラーがあるときだけ表示
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 80,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFFD9D9D9)),
                ),
                onPressed: () async {
                  String username = nameController.text.trim();
                  String password = passwordController.text.trim();

                  if (username.isNotEmpty && password.isNotEmpty) {
                    try {
                      final token = await apiService.sendGetTokenRequest(username, password);
                      if (token != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ログイン成功！')),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ThreadView(authToken: token)),
                        );
                      } else {
                        setState(() {
                          _errorMessage = "認証エラー: ユーザー名かパスワードが間違っています";
                        });
                      }
                    } catch (e) {
                      setState(() {
                        _errorMessage = "サーバーエラー: $e";
                      });
                      print("エラー: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('エラー: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('全てのフィールドを入力してください。')),
                    );
                  }
                },
                child: Text(
                  "ログイン",
                  style: TextStyle(fontSize: 25, color: Color(0xFF000000)),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 80,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFFD9D9D9)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationPage()),
                  );
                },
                child: Text(
                  "初回登録",
                  style: TextStyle(fontSize: 25, color: Color(0xFF000000)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
