part of '../bloc/tasks_bloc.dart';

@immutable
abstract class TasksState {}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final Tasks response;
  final int statusCode;
  TasksLoaded(this.response, this.statusCode);
}

class TasksLoadedNoInternet extends TasksState {}
