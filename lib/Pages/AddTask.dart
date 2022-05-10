import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hishabee/Bloc/bloc/tasks_bloc.dart';

class AddTask extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController descriptionController = new TextEditingController();
  final bloc = TasksBloc();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Tasks"),
      ),
      body: Container(
          padding: const EdgeInsets.all(50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Enter Task Description"),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: descriptionController,
              ),
              const SizedBox(
                height: 20,
              ),
              BlocProvider(
                create: (context) => bloc,
                child: BlocListener(
                  listener: (BuildContext context, state) {
                    if (state is TasksLoaded ||
                        state is TasksLoadedNoInternet) {
                      Navigator.pop(context);
                    }
                  },
                  bloc: bloc,
                  child: BlocBuilder(
                    bloc: bloc,
                    builder: (BuildContext context, state) {
                      if (state is TasksInitial || state is TasksLoaded) {
                        return addButton(context);
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ),
              )
            ],
          )),
    );
  }

  addButton(BuildContext context) {
    return TextButton(
        style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
        onPressed: () {
          if (descriptionController.text == "") {
            Scaffold.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.red,
              content: Text("Description can't be empty"),
            ));
          } else {
            bloc.add(addtasks(descriptionController.text));
          }
        },
        child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 10, bottom: 10),
            decoration: BoxDecoration(
                color: Colors.blueAccent.shade400,
                borderRadius: BorderRadius.circular(10)),
            child: const Text(
              "Continue",
              style: TextStyle(color: Colors.white),
            )));
  }
}
