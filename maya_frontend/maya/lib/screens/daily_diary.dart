import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_quill/quill_delta.dart';
import 'package:maya/main.dart';
import 'package:maya/services/auth_service.dart';

class DailyDiaryScreen extends StatefulWidget {
  const DailyDiaryScreen({Key? key}) : super(key: key);

  @override
  _DailyDiaryScreenState createState() => _DailyDiaryScreenState();
}

class _DailyDiaryScreenState extends State<DailyDiaryScreen> {
  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  List<DiaryEntry> _entries = [];
  String _searchQuery = '';
   DiaryEntry? _selectedEntry;

  void _addEntry(String entry, String title) async {

    String apiUrl = 'https://hqonrzuh2j.execute-api.ap-south-1.amazonaws.com/default/savediaryentry';

    Map<String, dynamic> postData = {
      'uid': user?.uid,
      'title': title,
      'entry': entry,
    };
    print(jsonEncode(postData));
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(postData),
      );
      if (response.statusCode == 201) {
        print("Diary Entry saved successfully");
        _fetchEntries();
      } else {
        print("Failed to save Diary Entry. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error saving Diary Entry: $e");
    }
    print("Diary Entry Saved: $entry");
  }
 
  Future<void> _fetchEntries() async {
    final uid = await AuthService().getCurrentUserUid();
    String apiUrl = 'https://hqonrzuh2j.execute-api.ap-south-1.amazonaws.com/default/getdiaryentries?uid=$uid';

    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<dynamic> entriesJson = data['model'];
        setState(() {
          _entries = entriesJson.map((json) => DiaryEntry.fromJson(json)).toList();
        });
      } else {
        print("Failed to fetch entries. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching entries: $e");
    }
  }
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  List<DiaryEntry> get _filteredEntries {
    if (_searchQuery.isEmpty) {
      return _entries;
    }
    return _entries.where((entry) =>
      entry.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      entry.entry.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      entry.date.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }
  void _showEntryDetails(DiaryEntry entry) {
    setState(() {
      _selectedEntry = entry;
    });
  }

   void _closeEntryDetails() {
    setState(() {
      _selectedEntry = null;
    });
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Diary'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DiarySearchDelegate(
                  entries: _entries,
                  onQueryChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 12.0,
              childAspectRatio: 0.75,
            ),
            itemCount: _filteredEntries.length,
            itemBuilder: (context, index) {
              final entry = _filteredEntries[index];
              return NoteCard(
                title: entry.title,
                date: entry.date,
                entry: entry.entry,
                onTap: () => _showEntryDetails(entry),
              );
            },
          ),
          if (_selectedEntry != null) ...[
            GestureDetector(
              onTap: _closeEntryDetails,
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedEntry!.title,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'Playfair Display',
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedEntry!.date,
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontFamily: 'Playfair Display',
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          QuillEditor.basic(
                            configurations: QuillEditorConfigurations(
                              controller: QuillController(
                                document: Document.fromDelta(Delta.fromJson(jsonDecode(_selectedEntry!.entry) as List)),
                                selection: const TextSelection.collapsed(offset: 0),
                                readOnly: true,
                              ),
                              scrollable: true,
                              padding: const EdgeInsets.all(8.0),
                              autoFocus: false,
                              showCursor: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEntryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }





  void _showEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16.0),
          child: DiaryEntryDialog(
            onSave: _addEntry,
          ),
        ),
      ),
    );
  }

}
class NoteCard extends StatelessWidget {
  final String title;
  final String date;
  final String entry;
  final VoidCallback onTap;

  const NoteCard({
    Key? key,
    required this.title,
    required this.date,
    required this.entry,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Note card with custom painter
          CustomPaint(
            painter: NotePainter(),
            child: Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Playfair Display',
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontFamily: 'Playfair Display',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Pin
          Positioned(
            left: 12,
            top: -10,
            child: Transform.rotate(
              angle: -0.5, // Rotate the pin to appear at an angle
              child: Icon(
                Icons.push_pin,
                color: Colors.red,
                size: 24.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow[100]!
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = Radius.circular(8.0);

    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);

    // Add texture
    final texturePaint = Paint()
      ..color = Colors.yellow[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), texturePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}


class DiaryEntryDialog extends StatefulWidget {
  final Function(String,String) onSave;

  const DiaryEntryDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  _DiaryEntryDialogState createState() => _DiaryEntryDialogState();
}

class _DiaryEntryDialogState extends State<DiaryEntryDialog> {
  final quill.QuillController _controller = quill.QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _toolbarScrollController = ScrollController();
  TextEditingController _titleController = TextEditingController();

@override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }
  void _saveEntry() {
  String entry = _serializeContent();
  String title = _titleController.text.trim(); 
  if (entry.isNotEmpty && title.isNotEmpty) {
    widget.onSave(entry, title); 
    Navigator.of(context).pop();
  } else {
    // You can show a dialog, snackbar, or handle it as per your app's logic
  }
}
String _serializeContent() {
  return jsonEncode(_controller.document.toDelta().toJson());
}

@override
Widget build(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextField(
        controller: _titleController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: 'Title',
          border: OutlineInputBorder(),
          
        ),
      ),
      SizedBox(height: 16),
      Expanded(
        child: SingleChildScrollView(
          child: _buildTextEditor(),
        ),
      ),
      SizedBox(height: 16),
      _buildEditingOptions(),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: _saveEntry,
        child: const Text('Save Entry'),
      ),
    ],
  );
}


Widget _buildTextEditor() {
  return quill.QuillEditor.basic(
 //focusNode: _focusNode,
  scrollController: _scrollController,
  configurations: QuillEditorConfigurations(
    controller: _controller,
    scrollable: true,
    padding: const EdgeInsets.all(8.0),
    autoFocus: true,
    enableInteractiveSelection: true,
    enableSelectionToolbar: true,
    minHeight: 300, // Example of setting minHeight
    maxHeight: 800, // Example of setting maxHeight
    keyboardAppearance: Brightness.light,
    textCapitalization: TextCapitalization.sentences,
    enableMarkdownStyleConversion: true,
    embedBuilders: [], // Example of setting embedBuilders
    linkActionPickerDelegate: defaultLinkActionPickerDelegate,
    detectWordBoundary: true,
    isOnTapOutsideEnabled: true,
    textInputAction: TextInputAction.newline,
    readOnlyMouseCursor: SystemMouseCursors.text,
    // Add more configurations as needed
  ),
);
}

Widget _buildEditingOptions() {
  Color chablisColor = Color(0xFFFFF1F1);
  return Container(
    decoration: BoxDecoration(
      color: chablisColor,
      borderRadius: BorderRadius.circular(8.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    ),
    padding: const EdgeInsets.all(8.0),
    height: 100,
    child: SingleChildScrollView(
      controller: _toolbarScrollController,
      scrollDirection: Axis.vertical,
      child: quill.QuillSimpleToolbar(
        configurations: quill.QuillSimpleToolbarConfigurations(
          showAlignmentButtons: true,
          controller: _controller,
          toolbarIconAlignment: WrapAlignment.spaceEvenly,
          buttonOptions: const quill.QuillSimpleToolbarButtonOptions(
            base: QuillToolbarBaseButtonOptions(
              iconSize: 15,
              iconButtonFactor: 1.4,
            ),
          ),
        ),
      ),
    ),
  );
}

  
}

class DiarySearchDelegate extends SearchDelegate {
  final List<DiaryEntry> entries;
  final ValueChanged<String> onQueryChanged;

  DiarySearchDelegate({required this.entries, required this.onQueryChanged});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onQueryChanged(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onQueryChanged(query);
    return _buildFilteredEntries();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    onQueryChanged(query);
    return _buildFilteredEntries();
  }

  Widget _buildFilteredEntries() {
    final filteredEntries = entries.where((entry) {
      return entry.title.toLowerCase().contains(query.toLowerCase()) ||
             entry.entry.toLowerCase().contains(query.toLowerCase()) ||
             entry.date.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredEntries.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredEntries[index].title),
          subtitle: Text(filteredEntries[index].entry),
          trailing: Text(filteredEntries[index].date),
        );
      },
    );
  }
}

class DiaryEntry {
  final int id;
  final String uid;
  final String title;
  final String entry;
  final String date;
  final String dateUpdatedAt;

  DiaryEntry({
    required this.id,
    required this.uid,
    required this.title,
    required this.entry,
    required this.date,
    required this.dateUpdatedAt,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'],
      uid: json['uid'],
      title: json['title'],
      entry: json['entry'],
      date: json['date'],
      dateUpdatedAt: json['dateUpdatedAt'],
    );
  }
}
