import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'make_post_page.dart';

class PostView extends StatefulWidget {
  final String authToken;
  final int thread_id;

  PostView({required this.authToken, required this.thread_id});

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  List posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/posts/'),
      headers: {
        'Authorization': 'Bearer ${widget.authToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        posts = json.decode(response.body)['post'];
        for (var post in posts) {
          if (post['thread_id'] != widget.thread_id) {
            posts.remove(post);
          }
        }
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
      ),
      body: posts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  leading: Text('${index + 1}'),
                  title: Text(post['text']),
                  subtitle: Text(post['timestamp']),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MakePostPage(authToken: widget.authToken, thread_id: widget.thread_id)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
