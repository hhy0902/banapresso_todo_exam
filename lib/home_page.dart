

import 'package:banapresso_todo_exam/todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TextEditingController titleTextController = TextEditingController();
  var uuid = const Uuid();
  List<Todo> todoList = [];
  late Box<Todo> todoBox;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoBox = Hive.box<Todo>("todoBox");
    loadTodos();
  }

  void loadTodos() {
    setState(() {
      todoList = todoBox.values.toList();
    });
  }

  void addTodo() {
    var todo = Todo(
      title: titleTextController.text,
      id: uuid.v4(),
    );
    todoBox.add(todo); // Hive에 저장
    loadTodos(); // 최신화
  }

  void clearTodos() {
    todoBox.clear(); // 저장된 데이터 삭제
    loadTodos();
  }

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
                return Column(
                  key: ValueKey(item.id),
                  children: [
                    ListTile(
                      title: Text(item.title),
                      subtitle: Text(item.done.toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              
                            },
                            icon: Icon(Icons.alarm),
                          ),
                          Checkbox(
                            value: item.done,
                            onChanged: (value) {
                              setState(() {
                                print(value);
                                item.done = value!;
                          
                                // 변경된 값을 Hive의 Box에 저장
                                int index = todoBox.values.toList().indexOf(item);  // 해당 item의 index를 찾아서
                                todoBox.putAt(index, item);  // 해당 index에 있는 값을 업데이트
                          
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                  ],
                );
              }).toList(),
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = todoList.removeAt(oldIndex);
                  todoList.insert(newIndex, item);

                  todoBox.clear(); // 기존 데이터 삭제
                  for (var todo in todoList) {
                    todoBox.add(todo); // 새 순서로 데이터 저장
                  }

                });
              },
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {

                    todoBox.values.forEach((element) {
                      // print("todoBox : ${element.title}");
                      print("todoBox : ${element.done}");
                    });

                    todoList.forEach((element) {
                      // print("todoList : ${element.title}");
                      print("todoList : ${element.done}");
                    });
                  });
                },
                child: Icon(Icons.telegram),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    clearTodos();
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
                      // var todo = Todo(title: titleTextController.text, id: uuid.v4());
                      // todoList.add(todo);
                      addTodo();
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












