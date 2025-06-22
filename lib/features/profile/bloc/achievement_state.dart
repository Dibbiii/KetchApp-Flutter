import 'package:equatable/equatable.dart';
import 'package:ketchapp_flutter/models/achievement.dart';

abstract class AchievementState extends Equatable {
  const AchievementState();

  @override
  List<Object> get props => [];
}

class AchievementInitial extends AchievementState {}

class AchievementLoading extends AchievementState {}

class AchievementLoaded extends AchievementState {
  final List<Achievement> achievements;

  const AchievementLoaded(this.achievements);

  @override
  List<Object> get props => [achievements];
}

class AchievementError extends AchievementState {
  final String message;

  const AchievementError(this.message);

  @override
  List<Object> get props => [message];
}

