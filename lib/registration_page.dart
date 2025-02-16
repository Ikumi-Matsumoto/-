import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;

class RegistrationPage extends StatefulWidget{
  @override
  _RegistrationPageState createState() => new _RegistrationPageState();
}
class _RegistrationPageState extends State<RegistrationPage> {
  final ApiService apiService = ApiService();

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
    appBar: AppBar(
    backgroundColor: Color(0xFFD9D9D9),
    title: Text("初回登録"),
    ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: userNameController,
              decoration: InputDecoration(labelText: '名前'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'パスワード'),
              obscureText: true,
            ),
            SizedBox(height: 20),
        SizedBox(
          width: 200,
          height: 80,// 幅を調整
          child:
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFFD9D9D9)),
              ),
              onPressed: () async {
                String userName = userNameController.text;
                String password = passwordController.text;

                if (userName.isNotEmpty && password.isNotEmpty) {
                  if (userName.isNotEmpty && password.isNotEmpty) {
                    final response = await http.get(Uri.parse('http://localhost:8000/users/'));
                    print(response.body);
                    try {
                      Map<String, dynamic> data = {
                        'username': userName,
                        'password': password,
                      };
                      final response = await apiService.sendPostRequest(data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Response: ${response.toString()}')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      print("errer:${e}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all fields')),
                    );
                  }

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields')),
                  );
                }
              },
              child: Text(
                "登録",
                style: TextStyle(
                  fontSize: 25,
                  color:Color(0xFF000000),
                ),
              ),
            ),
        )
          ],
        ),
      ),
    );
  }
}


