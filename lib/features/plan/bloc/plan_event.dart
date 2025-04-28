part of 'plan_bloc.dart';

@immutable
abstract class PlanEvent {}

class NextStep extends PlanEvent {}

class PreviousStep extends PlanEvent {}