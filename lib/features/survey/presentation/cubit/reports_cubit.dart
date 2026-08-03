import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/survey/domain/entities/survey.dart';
import 'package:myboss_mobile/features/survey/domain/usecases/survey_usecases.dart';

class ReportsState extends Equatable {
  const ReportsState({this.isLoading = false, this.report, this.error, this.scope = 'squad'});
  final bool isLoading;
  final SurveyReport? report;
  final Failure? error;
  final String scope;

  ReportsState copyWith({bool? isLoading, SurveyReport? report, Failure? error, bool clearError = false, String? scope}) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      report: report ?? this.report,
      error: clearError ? null : (error ?? this.error),
      scope: scope ?? this.scope,
    );
  }

  @override
  List<Object?> get props => [isLoading, report, error, scope];
}

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit(this._getSurveyReportUseCase) : super(const ReportsState());
  final GetSurveyReportUseCase _getSurveyReportUseCase;

  Future<void> load(String scope, {String? id}) async {
    emit(state.copyWith(isLoading: true, clearError: true, scope: scope));
    final response = await _getSurveyReportUseCase(scope, id: id);
    if (response.failure != null) {
      emit(state.copyWith(isLoading: false, error: response.failure));
      return;
    }
    emit(state.copyWith(isLoading: false, report: response.report));
  }
}
