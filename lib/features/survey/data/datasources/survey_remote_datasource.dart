abstract class SurveyRemoteDataSource {
  Future<List<Map<String, dynamic>>> listSurveys();

  Future<Map<String, dynamic>> getActiveSurvey(String segment);

  Future<Map<String, dynamic>> submitResponse({
    required String surveyId,
    required String squadId,
    required String userId,
    required String governorate,
    required List<Map<String, dynamic>> answers,
    bool anonymous = false,
  });

  Future<Map<String, dynamic>> getSquadProgress(String squadId, {int target = 50});

  Future<Map<String, dynamic>> getReport(String scope, {String? id});
}
