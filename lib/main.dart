import 'package:flutter/material.dart';
import 'package:test_hishabee/Bloc/bloc/tasks_bloc.dart';
import 'package:test_hishabee/Pages/LoginPage.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await Workmanager().registerPeriodicTask(
    "1",
    "Sync",
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  runApp(const MyApp());
}

void callbackDispatcher() {
  final bloc = TasksBloc();
  Workmanager().executeTask((task, inputData) {
    print("runnung");
    bloc.add(syncTasks());
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
