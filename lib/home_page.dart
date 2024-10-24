

import 'package:banapresso_todo_exam/todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
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
  // List<Todo> todoList = [];
  Box<Todo> todoBox = Hive.box<Todo>("todoBox");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoBox = Hive.box<Todo>("todoBox");
  }


  void setAlarm(int index) async {
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

        setState(() {
          todoBox.putAt(index, todoBox.values.toList()[index].copyWith(createdAt: selectedDateTime));
        });

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

  String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);  // 24시간 형식
    // return DateFormat('hh:mm:ss a').format(dateTime); // 12시간 형식 (AM/PM)
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
            // ReorderableListView.builder 사용해보기?
            child: ReorderableListView.builder(
              itemCount: todoBox.values.length,
              itemBuilder: (context, index) {

                return Column(
                  key: ValueKey(todoBox.values.toList()[index].id), // String을 Key로 변환
                  children: [
                    ListTile(
                      title: Text(todoBox.values.toList()[index].title),
                      subtitle: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(formatTime(todoBox.values.toList()[index].createdAt),),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                setAlarm(index);
                              });
                            },
                            icon: Icon(Icons.alarm),
                          ),
                          Checkbox(
                            value: todoBox.values.toList()[index].done,
                            onChanged: (value) {
                              setState(() {
                                todoBox.putAt(index, todoBox.values.toList()[index].copyWith(done: value));
                              });
                            },
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                todoBox.deleteAt(index);
                              });
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final oldItem = todoBox.values.toList()[oldIndex];
                final newItem = todoBox.values.toList()[newIndex];
                print("old : ${oldItem.title}");
                print("new : ${newItem.title}");
                todoBox.putAt(newIndex, oldItem);
                todoBox.putAt(oldIndex, newItem);
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
                      print("todoBox : ${element.createdAt}");
                    });

                  });
                },
                child: Icon(Icons.telegram),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {

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
                      var todo = Todo(title: titleTextController.text, id: uuid.v4(), createdAt: DateTime.now());
                      todoBox.add(todo);
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












