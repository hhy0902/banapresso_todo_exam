import 'package:alarm/alarm.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:banapresso_todo_exam/home_page.dart';
import 'package:banapresso_todo_exam/todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';


// 알림 플러그인 인스턴스 생성
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


void main() async {

  // WidgetsFlutterBinding.ensureInitialized()가 필수로 호출되어야 합니다.
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
