import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final List<News> _newsList = [];
  final List<String> _categories = [];
  List<String> _selectedCategories = ['all_news'];
  bool _isLoading = false;
  bool _isCategoryLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndNews();
  }

  Future<void> _fetchCategoriesAndNews() async {
    try {
      final url = Uri.parse('https://hqonrzuh2j.execute-api.ap-south-1.amazonaws.com/default/getnews');
      final body = jsonEncode({
        'category': _selectedCategories,
      });
      print(body);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> categoriesJson = jsonResponse['model']['categories'];
        
        // Ensure 'all_news' is included in the categories list
        if (!categoriesJson.contains('all_news')) {
          categoriesJson[0]='all_news';
        }

        setState(() {
          _categories.addAll(categoriesJson.cast<String>());
          _isCategoryLoading = false;
        });

        _fetchNews(); // Fetch news for the default category
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchNews() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });
 
    try {
      final url = Uri.parse('https://hqonrzuh2j.execute-api.ap-south-1.amazonaws.com/default/getnews');
      final body = jsonEncode({
        'category': _selectedCategories,
      });
      print(body);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> newsJson = jsonResponse['model']['data'];
        List<News> newsList = newsJson.map((json) => News.fromJson(json)).toList();
        setState(() {
          _newsList.clear();
          _newsList.addAll(newsList);
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $urlString';
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      if (category == 'all_news') {
        _selectedCategories = ['all_news'];
      } else {
        if (_selectedCategories.contains('all_news')) {
          _selectedCategories = [category];
        } else {
          if (_selectedCategories.contains(category)) {
            _selectedCategories.remove(category);
          } else {
            _selectedCategories.add(category);
          }
        }
      }
      if (_selectedCategories.isEmpty) {
        _selectedCategories = ['all_news'];
      }
      _fetchNews();
    });
  }

  String _formatCategory(String category) {
    // Check if the category is empty or null
    if (category.isEmpty) {
      return '';
    }

    // Capitalize the first letter of each word and keep the rest in lowercase
    return category.split('_').map((word) {
      // Check if the word is not empty before capitalizing
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      } else {
        return '';
      }
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Details'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _isCategoryLoading
                ? Center(child: CircularProgressIndicator())
                : _categories.isEmpty
                    ? Text('No categories available')
                    : Container(
                        height: 50.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            String category = _categories[index];
                            bool isSelected = _selectedCategories.contains(category);
                            return GestureDetector(
                              onTap: () => _onCategoryChanged(category),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 4.0),
                                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue : Color.fromARGB(255, 197, 85, 109),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _formatCategory(category),
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.white,
                                      ),
                                    ),
                                    if (isSelected)
                                      GestureDetector(
                                        onTap: () => _onCategoryChanged(category),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16.0,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
          Expanded(
            child: _newsList.isEmpty && _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _newsList.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _newsList.length) {
                        return Center(child: CircularProgressIndicator());
                      }
                      News news = _newsList[index];
                      return Card(
                        margin: EdgeInsets.all(10.0),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'By ${news.author} | ${news.date} at ${news.time}',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Image.network(news.imageUrl),
                              SizedBox(height: 8),
                              Text(
                                news.content,
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  _launchUrl(news.readMoreUrl);
                                },
                                child: Text('Read More'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class News {
  final String author;
  final String content;
  final String date;
  final String id;
  final String imageUrl;
  final String readMoreUrl;
  final String time;
  final String title;
  final String url;

  News({
    required this.author,
    required this.content,
    required this.date,
    required this.id,
    required this.imageUrl,
    required this.readMoreUrl,
    required this.time,
    required this.title,
    required this.url,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      author: json['author'] as String,
      content: json['content'] as String,
      date: json['date'] as String,
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      readMoreUrl: json['readMoreUrl'] as String,
      time: json['time'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
    );
  }
}
