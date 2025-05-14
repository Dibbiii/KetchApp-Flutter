import 'package:equatable/equatable.dart';

abstract class RankingEvent extends Equatable {
  const RankingEvent();

  @override
  List<Object?> get props => [];
}

class LoadRanking extends RankingEvent {}

class RefreshRanking extends RankingEvent {}

class ChangeRankingFilter extends RankingEvent {
  final RankingFilter filter;

  const ChangeRankingFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

enum RankingFilter { advancements, hours, streak }
