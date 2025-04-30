part of 'home_bloc.dart';

@immutable
abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  const HomeLoaded();
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
}