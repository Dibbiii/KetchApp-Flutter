// filepath: lib/features/home/bloc/home_event.dart
part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

// Esempio: Evento per caricare i dati della home
class LoadHomeData extends HomeEvent {}