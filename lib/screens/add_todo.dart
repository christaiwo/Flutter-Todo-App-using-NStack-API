import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'package:todo/services/todo_services.dart';

import '../utils/snackbar_helper.dart';

class AddTodoPage extends StatefulWidget {
  final Map? todo;

  const AddTodoPage({
    super.key,
    this.todo,
  });

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isEdit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];

      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Todo" : "Add Todo",
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: "Title",
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(hintText: "Description"),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: isEdit ? updateData : submitData,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                isEdit ? "Update" : "submit",
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print("error");

      return;
    }

    final id = todo['_id'];
    final isCompleted = todo['is_completed'];

    final isSuccess = await TodoService.updateTodo(id, body);

    // show success message
    if (isSuccess) {
      ShowSuccessMessage(context, message: 'Udated Successfully');
    } else {
      ShowErrorMessage(context, message: 'Something went wrong ');
    }
  }

  Future<void> submitData() async {
    // submit data
    final isSuccess = await TodoService.addTodo(body);

    // show success message
    if (isSuccess) {
      titleController.text = '';
      descriptionController.text = '';
      ShowSuccessMessage(context, message: 'Creation Success');
    } else {
      ShowErrorMessage(context, message: 'Something went wrong ');
    }
  }

  Map get body {
    // get data
    final title = titleController.text;
    final description = descriptionController.text;
    return {"title": title, "description": description, "is_completed": false};
  }
}
