import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maya/services/auth_service.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<dynamic> _todos = [];
  final TextEditingController _addController = TextEditingController();
final TextEditingController _editController = TextEditingController();
  int? _editingTodoId;

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final uid = await AuthService().getCurrentUserUid();
    final response = await http.get(Uri.parse('https://hqonrzuh2j.execute-api.ap-south-1.amazonaws.com/default/gettodos?uid=$uid'));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _todos = responseData['model'];
      });
    } else {
      _showError('Failed to load todos');
    }
  }

  Future<void> _addTodo() async {
    final uid = await AuthService().getCurrentUserUid();
    if (_addController.text.isEmpty) {
      return;
    }
    
    final response = await http.post(
      Uri.parse('https://hqonrzuh2j.execute-api.ap-south-1.amazonaws.com/default/createtodo'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'uid': uid, 'text': _addController.text}),
    );

    if (response.statusCode == 201) {
      _addController.clear();
      FocusScope.of(context).unfocus(); 
      _fetchTodos();
      _showTemporaryMessage('Added');
    } else {
      _showError('Failed to add todo');
    }
  }

  Future<void> _deleteTodo(int id) async {
    final uid = await AuthService().getCurrentUserUid();
    final response = await http.delete(
      Uri.parse('https://hqonrzuh2j.execute-api.ap-south-1.amazonaws.com/default/deletetodos'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'uid': uid, 'id': id}),
    );

    if (response.statusCode == 204) {
      _fetchTodos();
      _showTemporaryMessage("Deleted");
    } else {
      _showError('Failed to delete todo');
    }
  }

  Future<void> _updateTodo() async {
    if (_editingTodoId == null || _editController.text.isEmpty) {
      return;
    }

    final uid = await AuthService().getCurrentUserUid();
    final response = await http.put(
      Uri.parse('https://hqonrzuh2j.execute-api.ap-south-1.amazonaws.com/default/updatetodo'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'uid': uid, 'id': _editingTodoId, 'text': _editController.text}),
    );

    if (response.statusCode == 200) {
      _editController.clear();
      FocusScope.of(context).unfocus();
      //_editingTodoId = null;
      _fetchTodos();
      _showTemporaryMessage('Updated');
    } else {
      _showError('Failed to update todo');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showTemporaryMessage(String message) {
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 120.0, // Adjust position as needed
        left: MediaQuery.of(context).size.width * 0.2,
        right: MediaQuery.of(context).size.width * 0.2,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
              shape: BoxShape.rectangle,
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize:13),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    // Insert the overlay entry
    overlay.insert(overlayEntry);

    // Log overlay insertion
    print('Overlay message shown: $message');

    Future.delayed(Duration(seconds: 1), () {
      overlayEntry.remove();
      
      // Log overlay removal
      print('Overlay message removed');
    });
  }

  void _showEditDialog(int todoId, String currentText) {
    _editingTodoId = todoId;
    _editController.text = currentText;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: TextField(
            controller: _editController,
            decoration: const InputDecoration(
              labelText: 'Todo Text',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateTodo();
              },
              child: const Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        automaticallyImplyLeading: true,
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _addController,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Add a new task',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 197, 85, 109),
                      width: 1.0,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.black87),
                onFieldSubmitted: (value) => _addTodo(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: _addTodo,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color.fromARGB(255, 197, 85, 109),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  final todo = _todos[index];
                  final todoText = todo['text'] ?? 'No task description';
                  final todoId = (todo['id'] ?? 0) as int;

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Color.fromARGB(255, 197, 85, 109), width: 1),
                    ),
                    child: ListTile(
                      key: ValueKey(todoId),
                      title: Text(
                        todoText,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(todoId, todoText),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () async => await _deleteTodo(todoId),
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
      ),
    );
  }
}
