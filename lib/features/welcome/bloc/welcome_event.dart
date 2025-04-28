part of 'welcome_bloc.dart';

@immutable
abstract class WelcomeEvent {}

class LoginClicked extends WelcomeEvent {
  final BuildContext context;

  LoginClicked(this.context) {
    context.push('/login');
  }
}

class RegisterClicked extends WelcomeEvent {
  final BuildContext context;

  RegisterClicked(this.context) {
    context.push('/register');
  }
}