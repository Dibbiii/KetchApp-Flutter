import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'welcome_event.dart';
part 'welcome_state.dart';

class welcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  welcomeBloc() : super(WelcomeInitial()) {
    on<WelcomeEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
