class Tasks {
  int count;
  List<TasksList> data;

  Tasks({required this.count, required this.data});

  factory Tasks.fromJson(Map<String, dynamic> json) => Tasks(
        count: json["count"],
        data: List<TasksList>.from(
            json["data"].map((x) => TasksList.fromJson(x))),
      );
}

class TasksList {
  String description, id;
  bool completed;
  TasksList(
      {required this.completed, required this.description, required this.id});

  factory TasksList.fromJson(Map<String, dynamic> json) => TasksList(
      completed: json["completed"],
      description: json["description"] ?? "",
      id: json["_id"] ?? "");
}
