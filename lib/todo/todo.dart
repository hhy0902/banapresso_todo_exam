

class Todo {
  var id;
  String title;
  bool done;

  Todo({required this.id, required this.title, this.done = false});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      done: json['done'],
    );
  }
}




