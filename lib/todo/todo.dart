

import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo {
  @HiveField(0)
  var id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool done;


  Todo({required this.id, required this.title, this.done = false,});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      done: json['done'],
    );
  }

  Todo copyWith({
    var id,
    String? title,
    bool? done,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
    );
  }
}

