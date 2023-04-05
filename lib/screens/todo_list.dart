import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:todo/screens/add_todo.dart';
import 'package:http/http.dart' as http;
import 'package:todo/services/todo_services.dart';

import '../utils/snackbar_helper.dart';
import '../widget/todo_card.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text(
                "No Todo Item",
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            child: ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                return TodoCard(
                  index: index,
                  item: item,
                  deleteById: deleteById,
                  navigateEdit: navigateToEditPage,
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        backgroundColor: Colors.transparent,
        label: Icon(
          Icons.add_circle,
          color: Colors.blue,
          size: 40,
        ),
      ),
    );
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );

    Navigator.push(context, route);

    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(builder: (context) => AddTodoPage());

    await Navigator.push(context, route);

    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
    // delete the item
    final isSuccess = await TodoService.deleteById(id);
    if (isSuccess) {
      // remove the item
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      ShowErrorMessage(context, message: "Something went Wrong");
    }
  }

  Future<void> fetchTodo() async {
    final response = await TodoService.fetchTodo();

    if (response != null) {
      // print(response.statusCode);
      setState(() {
        items = response;
      });
    } else {
      ShowErrorMessage(context, message: "Something went Wrong");
    }

    setState(() {
      isLoading = false;
    });
  }
}
