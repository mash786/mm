import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart'; // Import flutter_webview_plugin

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube API Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoListScreen(),
    );
  }
}

class VideoListScreen extends StatefulWidget {
  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final String apiKey = 'AIzaSyBKyby9EZK3YxXUjyFqMQMt5natjCsFzZQ'; // Your YouTube Data API Key
  final String channelId = 'UCK1XCJqEEFft5lj6zhfiEZA'; // Your Channel ID

  List<dynamic> _videos = [];

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&maxResults=10&type=video&key=$apiKey'));

      if (response.statusCode == 200) {
        setState(() {
          _videos = json.decode(response.body)['items'];
        });
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      print('Error fetching videos: $e');
    }
  }

  void _playVideo(String videoId) {
    // Launch the WebView to play the video
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoId: videoId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube API Demo'),
      ),
      body: ListView.builder(
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.network(
              _videos[index]['snippet']['thumbnails']['default']['url'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            title: Text(_videos[index]['snippet']['title']),
            onTap: () {
              _playVideo(_videos[index]['id']['videoId']);
            },
          );
        },
      ),
    );
  }
}

class VideoPlayerScreen extends StatelessWidget {
  final String videoId;

  const VideoPlayerScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold( // Use WebviewScaffold instead of WebView
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      url: 'https://www.youtube.com/embed/$videoId', // Load the video URL
    );
  }
}
