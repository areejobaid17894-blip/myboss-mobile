import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/survey/domain/entities/survey.dart';

abstract class SurveyRepository {
  Future<({Failure? failure, List<DynamicSurvey> surveys})> listSurveys();

  Future<({Failure? failure, DynamicSurvey? survey})> getActiveSurvey(String segment);

  Future<({Failure? failure, bool success})> submitResponse({
    required String surveyId,
    required String squadId,
    required String userId,
    required String governorate,
    required List<Map<String, dynamic>> answers,
    bool anonymous = false,
  });

  Future<({Failure? failure, SquadProgress? progress})> getSquadProgress(String squadId, {int target = 50});

  Future<({Failure? failure, SurveyReport? report})> getReport(String scope, {String? id});
}
