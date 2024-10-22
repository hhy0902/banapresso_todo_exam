

import 'package:banapresso_todo_exam/todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:alarm/alarm.dart';

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
    Alarm.stopAll();
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

  void setAlarm() async {
    // 알람이 현재 활성화되어 있는지 확인
    bool isActive = await Alarm.isRinging(42); // ID 42로 설정된 알람의 상태 확인

    if (isActive) {
      // 알람이 활성화되어 있으면 알람을 정지
      Alarm.stop(42);
      print('알람이 정지되었습니다.');
    } else {

      // 사용자로부터 시간을 선택하도록 요청
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(), // 기본적으로 현재 시간을 보여줌
      );

      if (selectedTime != null) {
        // 선택된 시간을 현재 날짜에 맞게 변환
        DateTime now = DateTime.now();
        DateTime selectedDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        // 만약 선택한 시간이 현재 시간보다 이전이면 다음 날로 설정
        if (selectedDateTime.isBefore(now)) {
          selectedDateTime = selectedDateTime.add(Duration(days: 1));
        }

        // 알람 설정
        final alarmSettings = AlarmSettings(
          id: 42,  // 알람 ID (고유해야 함)
          dateTime: selectedDateTime,  // 사용자가 선택한 시간으로 설정
          assetAudioPath: "assets/alarms/alarm.mp3",  // 알람 소리 파일 경로
          loopAudio: true,  // 소리를 반복할지 여부
          vibrate: true,  // 진동 여부
          fadeDuration: 3.0,  // 알람 소리가 점점 커지도록 하는 페이드인 시간 (초 단위)
          notificationTitle: '알람입니다!',  // 알림 제목
          notificationBody: '선택한 시간입니다!',  // 알림 본문
          enableNotificationOnKill: true,  // 앱 종료 시에도 알림을 표시할지 여부
        );

        Alarm.set(alarmSettings: alarmSettings);
        print('알람이 설정되었습니다: ${selectedDateTime.toString()}');
      }
    }
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    titleTextController.dispose();

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
                              setAlarm();
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












