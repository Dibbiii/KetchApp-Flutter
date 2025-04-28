import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'plan_event.dart';
part 'plan_state.dart';

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  PlanBloc() : super(PlanInitial());

  @override
  Stream<PlanState> mapEventToState(
    PlanEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
