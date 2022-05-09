part of '../bloc/authentication_bloc.dart';

@immutable
abstract class AuthenticationEvent {}

class login extends AuthenticationEvent {
  final String email, pass;
  login(this.email, this.pass);
}
