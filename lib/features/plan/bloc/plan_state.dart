part of 'plan_bloc.dart';

@immutable
abstract class PlanState {}

class PlanInitial extends PlanState {}

class PlanLoading extends PlanState {}

class PlanLoaded extends PlanState {}

class PlanError extends PlanState {
  final String message;

  PlanError(this.message);
}
