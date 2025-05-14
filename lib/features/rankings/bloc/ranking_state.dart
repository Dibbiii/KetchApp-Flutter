import 'package:equatable/equatable.dart';
import 'package:ketchapp_flutter/features/rankings/bloc/ranking_event.dart';
import '../presentation/ranking_page.dart';

abstract class RankingState extends Equatable {
  const RankingState();

  @override
  List<Object?> get props => [];
}

class RankingInitial extends RankingState {}

class RankingLoading extends RankingState {}

class RankingLoaded extends RankingState {
  final List<UserRankData> users;
  final RankingFilter filter;

  const RankingLoaded(this.users, this.filter);

  @override
  List<Object?> get props => [users, filter];
}

class RankingError extends RankingState {
  final String message;

  const RankingError(this.message);

  @override
  List<Object?> get props => [message];
}
