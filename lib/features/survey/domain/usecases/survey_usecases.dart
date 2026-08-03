import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/survey/domain/entities/survey.dart';
import 'package:myboss_mobile/features/survey/domain/repositories/survey_repository.dart';

class ListSurveysUseCase {
  const ListSurveysUseCase(this._repository);
  final SurveyRepository _repository;

  Future<({Failure? failure, List<DynamicSurvey> surveys})> call() {
    return _repository.listSurveys();
  }
}

class GetActiveSurveyUseCase {
  const GetActiveSurveyUseCase(this._repository);
  final SurveyRepository _repository;

  Future<({Failure? failure, DynamicSurvey? survey})> call(String segment) {
    return _repository.getActiveSurvey(segment);
  }
}

class SubmitSurveyResponseUseCase {
  const SubmitSurveyResponseUseCase(this._repository);
  final SurveyRepository _repository;

  Future<({Failure? failure, bool success})> call({
    required String surveyId,
    required String squadId,
    required String userId,
    required String governorate,
    required List<Map<String, dynamic>> answers,
    bool anonymous = false,
  }) {
    return _repository.submitResponse(
      surveyId: surveyId,
      squadId: squadId,
      userId: userId,
      governorate: governorate,
      answers: answers,
      anonymous: anonymous,
    );
  }
}

class GetSquadProgressUseCase {
  const GetSquadProgressUseCase(this._repository);
  final SurveyRepository _repository;

  Future<({Failure? failure, SquadProgress? progress})> call(String squadId, {int target = 50}) {
    return _repository.getSquadProgress(squadId, target: target);
  }
}

class GetSurveyReportUseCase {
  const GetSurveyReportUseCase(this._repository);
  final SurveyRepository _repository;

  Future<({Failure? failure, SurveyReport? report})> call(String scope, {String? id}) {
    return _repository.getReport(scope, id: id);
  }
}
