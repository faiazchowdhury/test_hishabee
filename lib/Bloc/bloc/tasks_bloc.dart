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
                  await db.collection('todos').doc(id).set({
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
                await db.collection('todos').doc(id).set({
                  'id': jsonDecode(response.body)['data'][i]['_id'],
                  'description': jsonDecode(response.body)['data'][i]
                      ['description'],
                  'completed': jsonDecode(response.body)['data'][i]['completed']
                });
              }
            }
            await updateLocalData();
            emit.call(TasksLoaded(res, response.statusCode));
          }
        } on SocketException catch (_) {
          await updateLocalData();
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
            await db.collection('todos').doc("/todos/${event.id}").delete();
            Tasks res = Tasks.fromJson(jsonDecode(response.body));
            emit.call(TasksLoaded(res, response.statusCode));
          }
        } on SocketException catch (_) {
          await db.collection('todos').doc(event.id).delete();
          String id = db.collection('todos').doc().id;
          await db
              .collection('sync')
              .doc(id)
              .set({'action': "delete", 'id': event.id});
          await updateLocalData();
          emit.call(TasksLoadedNoInternet());
        }
      }

      if (event is addtasks) {
        emit.call(TasksLoading());
        final db = Localstore.instance;
        try {
          final result = await InternetAddress.lookup('example.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            var response = await http.post(Uri.parse("$api/task"),
                body: jsonEncode({"description": event.description}),
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Bearer ${prefs.get("token")}"
                });
            await db
                .collection('todos')
                .doc(jsonDecode(response.body)['data']['_id'])
                .set({
              'id': jsonDecode(response.body)['data']['_id'],
              'description': jsonDecode(response.body)['data']['description'],
              'completed': jsonDecode(response.body)['data']['completed']
            });
            response = await http.get(Uri.parse("$api/task"), headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer ${prefs.get("token")}"
            });
            Tasks res = Tasks.fromJson(jsonDecode(response.body));
            emit.call(TasksLoaded(res, response.statusCode));
          }
        } on SocketException catch (_) {
          String id = db.collection('todos').doc().id;
          await db.collection('sync').doc(id).set(
              {'action': "add", 'id': id, 'description': event.description});
          await db.collection('todos').doc(id).set(
              {'id': id, 'description': event.description, 'completed': false});
          await updateLocalData();
          emit.call(TasksLoadedNoInternet());
        }
      }

      if (event is syncTasks) {
        print("syncing");
        final db = Localstore.instance;
        try {
          final result = await InternetAddress.lookup('example.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            final items = await db.collection('sync').get();
            final prefs = await SharedPreferences.getInstance();
            items?.forEach((key, value) async {
              if (value['action'] == "add") {
                var response = await http.post(Uri.parse("$api/task"),
                    body: jsonEncode({"description": value['description']}),
                    headers: {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer ${prefs.get("token")}"
                    });
                await db
                    .collection('todos')
                    .doc(jsonDecode(response.body)['data']['_id'])
                    .set({
                  'id': jsonDecode(response.body)['data']['_id'],
                  'description': jsonDecode(response.body)['data']
                      ['description'],
                  'completed': jsonDecode(response.body)['data']['completed']
                });
                await db.collection('todos').doc("${key}").delete();
              } else {
                var response = await http
                    .delete(Uri.parse("$api/task/${value['id']}"), headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Bearer ${prefs.get("token")}"
                });
              }
              await db.collection('sync').doc(key).delete();
            });
          }
        } on SocketException catch (_) {}
      }
    });
  }

  updateLocalData() async {
    final db = Localstore.instance;
    final items = await db.collection('todos').get();
    OfflineTasksList.completed = [];
    OfflineTasksList.id = [];
    OfflineTasksList.description = [];
    items?.forEach((key, value) {
      OfflineTasksList.completed.add(value['completed']);
      OfflineTasksList.id.add(value['id']);
      OfflineTasksList.description.add(value['description']);
    });
    print(OfflineTasksList.completed);
  }
}
