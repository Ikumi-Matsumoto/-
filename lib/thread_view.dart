import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'make_thread_page.dart';
import 'post_view.dart';

class ThreadView extends StatefulWidget {
  final String authToken;

  ThreadView({required this.authToken});

  @override
  _ThreadViewState createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadView> {
  List threads = [];

  @override
  void initState() {
    super.initState();
    fetchThreads();
  }

  Future<void> fetchThreads() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/threads/'),
      headers: {
        'Authorization': 'Bearer ${widget.authToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        threads = json.decode(response.body)['thread'];
      });
    } else {
      throw Exception('Failed to load threads');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Threads'),
      ),
      body: threads.isEmpty
          ? Center(child: CircularProgressIndicator())
            : ListView.builder(
              itemCount: threads.length,
              itemBuilder: (context, index) {
              final thread = threads[index];
              return ListTile(
                title: Text(thread['title']),
                subtitle: Text(thread['timestamp']),
                onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => PostView(thread_id: thread['id'], authToken: widget.authToken),
                  ),
                );
                },
              );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MakeThreadPage(authToken: widget.authToken)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
