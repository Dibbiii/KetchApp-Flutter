import 'package:flutter_bloc/flutter_bloc.dart';
import 'ranking_event.dart';
import 'ranking_state.dart';
import '../presentation/ranking_page.dart';

class RankingBloc extends Bloc<RankingEvent, RankingState> {
  RankingBloc() : super(RankingInitial()) {
    on<LoadRanking>(_onLoadRanking);
    on<RefreshRanking>(_onRefreshRanking);
    on<ChangeRankingFilter>(_onChangeRankingFilter);
  }

  Future<void> _onLoadRanking(LoadRanking event,
      Emitter<RankingState> emit,) async {
    emit(RankingLoading());
    await Future.delayed(const Duration(seconds: 1));
    // Simula caricamento dati
    emit(RankingLoaded(UserRankData.mockList(), RankingFilter.hours));
  }

  Future<void> _onRefreshRanking(RefreshRanking event,
      Emitter<RankingState> emit,) async {
    emit(RankingLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(RankingLoaded(UserRankData.mockList(), RankingFilter.hours));
  }

  void _onChangeRankingFilter(ChangeRankingFilter event,
      Emitter<RankingState> emit,) {
    if (state is RankingLoaded) {
      final loaded = state as RankingLoaded;
      emit(RankingLoaded(loaded.users, event.filter));
    }
  }
}
