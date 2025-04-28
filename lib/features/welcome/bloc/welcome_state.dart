part of 'welcome_bloc.dart';

@immutable
abstract class WelcomeState {}

class WelcomeInitial extends WelcomeState {}

class WelcomeLoading extends WelcomeState {}

class WelcomeLoaded extends WelcomeState {
  final String message;
  WelcomeLoaded(this.message);
}

class WelcomeError extends WelcomeState {
  final String errorMessage;
  WelcomeError(this.errorMessage);
}