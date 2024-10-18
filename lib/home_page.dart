

import 'package:banapresso_todo_exam/todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TextEditingController titleTextController = TextEditingController();
  List<Todo> todoList = [];
  var uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("banapresso todo exam"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView(
              children: todoList.map((item) {
                return ListTile(
                  key: ValueKey(item.id),
                  title: Text(item.title),
                  subtitle: Text(item.done.toString()),
                );
              }).toList(),
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = todoList.removeAt(oldIndex);
                  todoList.insert(newIndex, item);
                });
              },
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {

                    todoList.forEach((element) {
                      print("todoList : ${element.title}");
                    });
                  });
                },
                child: Icon(Icons.telegram),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    todoList.clear();
                  });
                },
                child: Icon(Icons.delete),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Add new task"),
                content: TextField(
                  autofocus: true,
                  controller: titleTextController,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      var todo = Todo(title: titleTextController.text, id: uuid.v4());
                      todoList.add(todo);
                      titleTextController.clear();
                      Navigator.pop(context);
                      setState(() {

                      });
                    },
                    child: Text("Add"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}












