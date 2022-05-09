part of '../bloc/tasks_bloc.dart';

@immutable
abstract class TasksEvent {}

class getTasks extends TasksEvent {}

class deleteTasks extends TasksEvent {
  final String id;
  deleteTasks(this.id);
}

class addtasks extends TasksEvent {
  final String description;

  addtasks(this.description);
}
