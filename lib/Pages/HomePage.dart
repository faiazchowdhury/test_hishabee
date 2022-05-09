import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hishabee/Bloc/bloc/tasks_bloc.dart';
import 'package:test_hishabee/Model/OfflineTasksList.dart';
import 'package:test_hishabee/Pages/AddTask.dart';

import '../Model/Tasks.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final bloc = TasksBloc();
  final updateBloc = TasksBloc();

  @override
  void initState() {
    bloc.add(getTasks());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BuildContext ctx = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var res = await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddTask()));
          if (res != null) {
            bloc.add(getTasks());
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent.shade400,
      ),
      body: BlocProvider(
        create: (context) => bloc,
        child: BlocListener(
          bloc: bloc,
          listener: (context, state) {
            if (state is TasksLoaded) {
              if (state.statusCode == 200) {
                // ignore: deprecated_member_use
                Scaffold.of(context).showSnackBar(const SnackBar(
                  content: Text("Successful"),
                ));
              } else {
                Scaffold.of(context).showSnackBar(const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text("Something went wrong"),
                ));
              }
            }
          },
          child: BlocBuilder(
            bloc: bloc,
            builder: (context, state) {
              if (state is TasksInitial || state is TasksLoading) {
                return CircularProgressIndicator();
              } else if (state is TasksLoaded) {
                return taskList(state.response);
              } else if (state is TasksLoadedNoInternet) {
                return taskListNoInternet();
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  taskListNoInternet() {
    return ListView.builder(
      itemCount: OfflineTasksList.completed.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 0,
                  child: Icon(OfflineTasksList.completed[index]
                      ? Icons.check_circle
                      : Icons.circle_outlined),
                ),
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(OfflineTasksList.description[index]),
                    )),
                Expanded(
                    flex: 0,
                    child: GestureDetector(
                        onTap: () {
                          bloc.add(deleteTasks(OfflineTasksList.id[index]));
                        },
                        child: Icon(Icons.delete))),
              ],
            ),
          ),
        );
      },
    );
  }

  taskList(Tasks response) {
    return ListView.builder(
      itemCount: response.count,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 0,
                  child: Icon(response.data[index].completed
                      ? Icons.check_circle
                      : Icons.circle_outlined),
                ),
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(response.data[index].description),
                    )),
                Expanded(
                    flex: 0,
                    child: GestureDetector(
                        onTap: () {
                          bloc.add(deleteTasks(response.data[index].id));
                        },
                        child: Icon(Icons.delete))),
              ],
            ),
          ),
        );
      },
    );
  }
}
