

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

  @HiveField(3)
  DateTime createdAt;


  Todo({required this.id, required this.title, this.done = false, required this.createdAt,});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      done: json['done'],
      createdAt: json['createdAt'],
    );
  }

  Todo copyWith({
    var id,
    String? title,
    bool? done,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

