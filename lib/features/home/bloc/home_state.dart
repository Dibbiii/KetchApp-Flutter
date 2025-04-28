// filepath: lib/features/home/bloc/home_state.dart
part of 'home_bloc.dart';

@immutable
abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

// Esempio: Stato con i dati caricati
class HomeLoaded extends HomeState {
  // final List<YourDataModel> data; // I dati caricati
  // const HomeLoaded(this.data);
  const HomeLoaded(); // Semplificato per ora
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
}