// filepath: lib/features/home/bloc/home_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // Inietta qui eventuali repository/servizi necessari per caricare i dati
  // final YourDataRepository _repository;

  HomeBloc(/*{required YourDataRepository repository}*/) : super(HomeLoaded()) {
    on<LoadHomeData>((event, emit) async {
      
    });
  }
}