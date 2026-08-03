import 'package:myboss_mobile/core/network/dio_client.dart';
import 'package:myboss_mobile/features/survey/data/datasources/survey_remote_datasource.dart';

class SurveyRemoteDataSourceImpl implements SurveyRemoteDataSource {
  const SurveyRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<List<Map<String, dynamic>>> listSurveys() async {
    final response = await _client.survey.get('/surveys/catalog');
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getActiveSurvey(String segment) async {
    final response = await _client.survey.get('/surveys/active/$segment');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> submitResponse({
    required String surveyId,
    required String squadId,
    required String userId,
    required String governorate,
    required List<Map<String, dynamic>> answers,
    bool anonymous = false,
  }) async {
    final response = await _client.survey.post('/responses', data: {
      'surveyId': surveyId,
      'squadId': squadId,
      'userId': userId,
      'governorate': governorate,
      'answers': answers,
      'anonymous': anonymous,
    });
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getSquadProgress(String squadId, {int target = 50}) async {
    final response = await _client.survey.get(
      '/responses/progress/$squadId',
      queryParameters: {'target': target},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getReport(String scope, {String? id}) async {
    final response = await _client.survey.get(
      '/responses/reports/$scope',
      queryParameters: {if (id != null) 'id': id},
    );
    return response.data as Map<String, dynamic>;
  }
}
