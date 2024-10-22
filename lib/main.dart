import 'package:alarm/alarm.dart';
import 'package:banapresso_todo_exam/home_page.dart';
import 'package:banapresso_todo_exam/todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Alarm.init();
  Hive.registerAdapter(TodoAdapter()); // 등록된 어댑터 사용
  await Hive.openBox<Todo>('todoBox'); // Todo 저장소 열기

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}


