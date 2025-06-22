import 'package:equatable/equatable.dart';

abstract class AchievementEvent extends Equatable {
  const AchievementEvent();

  @override
  List<Object> get props => [];
}

class LoadAchievements extends AchievementEvent {}

