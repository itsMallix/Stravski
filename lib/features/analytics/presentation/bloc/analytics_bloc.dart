import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/stats_entity.dart';
import '../../domain/usecases/get_weekly_stats_usecase.dart';
import '../../domain/usecases/get_monthly_stats_usecase.dart';
import '../../../../core/error/failures.dart';

// ─── Events ───────────────────────────────────────────────────────────────────
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class WeeklyStatsRequested extends AnalyticsEvent {
  final String userId;
  const WeeklyStatsRequested({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class MonthlyStatsRequested extends AnalyticsEvent {
  final String userId;
  const MonthlyStatsRequested({required this.userId});
  @override
  List<Object?> get props => [userId];
}

// ─── States ───────────────────────────────────────────────────────────────────
abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsStatsLoaded extends AnalyticsState {
  final StatsEntity stats;
  final bool isWeekly;
  const AnalyticsStatsLoaded({required this.stats, required this.isWeekly});
  @override
  List<Object?> get props => [stats, isWeekly];
}

class AnalyticsError extends AnalyticsState {
  final String message;
  const AnalyticsError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetWeeklyStatsUseCase getWeeklyStatsUseCase;
  final GetMonthlyStatsUseCase getMonthlyStatsUseCase;

  AnalyticsBloc({
    required this.getWeeklyStatsUseCase,
    required this.getMonthlyStatsUseCase,
  }) : super(const AnalyticsInitial()) {
    on<WeeklyStatsRequested>(_onWeekly);
    on<MonthlyStatsRequested>(_onMonthly);
  }

  Future<void> _onWeekly(
      WeeklyStatsRequested event, Emitter<AnalyticsState> emit) async {
    emit(const AnalyticsLoading());
    try {
      final stats =
          await getWeeklyStatsUseCase(userId: event.userId);
      emit(AnalyticsStatsLoaded(stats: stats, isWeekly: true));
    } on Failure catch (e) {
      emit(AnalyticsError(message: e.message));
    }
  }

  Future<void> _onMonthly(
      MonthlyStatsRequested event, Emitter<AnalyticsState> emit) async {
    emit(const AnalyticsLoading());
    try {
      final stats =
          await getMonthlyStatsUseCase(userId: event.userId);
      emit(AnalyticsStatsLoaded(stats: stats, isWeekly: false));
    } on Failure catch (e) {
      emit(AnalyticsError(message: e.message));
    }
  }
}
