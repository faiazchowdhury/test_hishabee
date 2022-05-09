import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:test_hishabee/Constants/Constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

part '../event/authentication_event.dart';
part '../state/authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationInitial()) {
    on<AuthenticationEvent>((event, emit) async {
      if (event is login) {
        emit.call(AuthenticationLoading());
        final prefs = await SharedPreferences.getInstance();
        var response = await http.post(Uri.parse("$api/user/login"),
            body: jsonEncode({"email": event.email, "password": event.pass}),
            headers: {
              "Content-Type": "application/json",
            });
        if (response.statusCode == 200) {
          await prefs.setString("token", json.decode(response.body)['token']);
        }
        print(json.decode(response.body)['token']);
        emit.call(AuthenticationLoaded(response.statusCode));
      }
    });
  }
}
