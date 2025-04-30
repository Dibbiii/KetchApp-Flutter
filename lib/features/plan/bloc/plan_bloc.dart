import "package:bloc/bloc.dart";
import "package:meta/meta.dart";

part 'plan_event.dart';
part 'plan_state.dart';

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  PlanBloc() : super(PlanInitial()) {
    on<NextStep>((event, emit) async {});
  }
}
