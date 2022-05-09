import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_hishabee/Constants/Constant.dart';
import 'package:test_hishabee/Model/OfflineTasksList.dart';
import 'package:test_hishabee/Model/Tasks.dart';
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'dart:io';

part '../event/tasks_event.dart';
part '../state/tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc() : super(TasksInitial()) {
    on<TasksEvent>((event, emit) async {
      if (event is getTasks) {
        emit.call(TasksLoading());
        final db = Localstore.instance;
        try {
          final result = await InternetAddress.lookup('example.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            var response = await http.get(Uri.parse("$api/task"), headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer ${prefs.get("token")}"
            });
            Tasks res = Tasks.fromJson(jsonDecode(response.body));
            var t = await db.collection('todos').get();

            if (t != null) {
              if (t.length < jsonDecode(response.body)['data'].length) {
                t.clear();
                for (int i = 0;
                    i < jsonDecode(response.body)['data'].length;
                    i++) {
                  final id = jsonDecode(response.body)['data'][i]['_id'];
                  db.collection('todos').doc(id).set({
                    'id': jsonDecode(response.body)['data'][i]['_id'],
                    'description': jsonDecode(response.body)['data'][i]
                        ['description'],
                    'completed': jsonDecode(response.body)['data'][i]
                        ['completed']
                  });
                }
              }
            } else {
              for (int i = 0;
                  i < jsonDecode(response.body)['data'].length;
                  i++) {
                final id = jsonDecode(response.body)['data'][i]['_id'];
                db.collection('todos').doc(id).set({
                  'id': jsonDecode(response.body)['data'][i]['_id'],
                  'description': jsonDecode(response.body)['data'][i]
                      ['description'],
                  'completed': jsonDecode(response.body)['data'][i]['completed']
                });
              }
            }

            emit.call(TasksLoaded(res, response.statusCode));
          }
        } on SocketException catch (_) {
          final items = await db.collection('todos').get();
          items?.forEach((key, value) {
            print("object");
            OfflineTasksList.completed = [];
            OfflineTasksList.id = [];
            OfflineTasksList.description = [];
            OfflineTasksList.completed.add(value['completed']);
            OfflineTasksList.id.add(value['id']);
            OfflineTasksList.description.add(value['description']);
          });
          emit.call(TasksLoadedNoInternet());
        }
      }

      if (event is deleteTasks) {
        emit.call(TasksLoading());
        final db = Localstore.instance;
        try {
          final result = await InternetAddress.lookup('example.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            var response =
                await http.delete(Uri.parse("$api/task/${event.id}"), headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer ${prefs.get("token")}"
            });
            response = await http.get(Uri.parse("$api/task"), headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer ${prefs.get("token")}"
            });
            Tasks res = Tasks.fromJson(jsonDecode(response.body));
            emit.call(TasksLoaded(res, response.statusCode));
          }
        } on SocketException catch (_) {
          for (int i = 0; i < OfflineTasksList.id.length; i++) {
            if (OfflineTasksList.id[i] == event.id) {
              final db = Localstore.instance;
              db.collection('todos').doc("/todos/${event.id}").delete();
            }
          }
        }
      }

      if (event is addtasks) {
        emit.call(TasksLoading());
        final prefs = await SharedPreferences.getInstance();
        var response = await http.post(Uri.parse("$api/task"),
            body: jsonEncode({"description": event.description}),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer ${prefs.get("token")}"
            });
        response = await http.get(Uri.parse("$api/task"), headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${prefs.get("token")}"
        });
        Tasks res = Tasks.fromJson(jsonDecode(response.body));
        emit.call(TasksLoaded(res, response.statusCode));
      }
    });
  }
}
