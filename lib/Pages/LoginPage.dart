import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_hishabee/Bloc/bloc/authentication_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hishabee/Pages/HomePage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  final bloc = AuthenticationBloc();

  @override
  Future<void> initState() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.get("token") != null) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => HomePage()));
    }
    emailController.text = "muh.nurali43@gmail.com";
    passController.text = "12345678";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
            padding: const EdgeInsets.all(50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: emailController,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: passController,
                  obscureText: true,
                ),
                const SizedBox(
                  height: 20,
                ),
                BlocProvider(
                  create: (context) => bloc,
                  child: BlocListener(
                    listener: (BuildContext context, state) {
                      if (state is AuthenticationLoaded) {
                        if (state.statusCode == 200) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => HomePage()));
                        }
                      }
                    },
                    bloc: bloc,
                    child: BlocBuilder(
                      bloc: bloc,
                      builder: (BuildContext context, state) {
                        if (state is AuthenticationInitial ||
                            state is AuthenticationLoaded) {
                          return loginButton();
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }

  loginButton() {
    return TextButton(
        style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
        onPressed: () {
          bloc.add(login(emailController.text, passController.text));
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
