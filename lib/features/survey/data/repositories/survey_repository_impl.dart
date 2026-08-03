import 'package:dio/dio.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/core/network/dio_error_mapper.dart';
import 'package:myboss_mobile/features/survey/data/datasources/survey_remote_datasource.dart';
import 'package:myboss_mobile/features/survey/domain/entities/survey.dart';
import 'package:myboss_mobile/features/survey/domain/repositories/survey_repository.dart';

class SurveyRepositoryImpl implements SurveyRepository {
  const SurveyRepositoryImpl(this._remoteDataSource);

  final SurveyRemoteDataSource _remoteDataSource;

  @override
  Future<({Failure? failure, List<DynamicSurvey> surveys})> listSurveys() async {
    try {
      final data = await _remoteDataSource.listSurveys();
      final surveys = data
          .where((item) => item['isActive'] != false)
          .map(DynamicSurvey.fromJson)
          .toList();
      return (failure: null, surveys: surveys);
    } on DioException catch (e) {
      return (failure: mapDioError(e), surveys: <DynamicSurvey>[]);
    } catch (_) {
      return (failure: const ServerFailure(), surveys: <DynamicSurvey>[]);
    }
  }

  @override
  Future<({Failure? failure, DynamicSurvey? survey})> getActiveSurvey(String segment) async {
    try {
      final data = await _remoteDataSource.getActiveSurvey(segment);
      return (failure: null, survey: DynamicSurvey.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), survey: null);
    } catch (_) {
      return (failure: const ServerFailure(), survey: null);
    }
  }

  @override
  Future<({Failure? failure, bool success})> submitResponse({
    required String surveyId,
    required String squadId,
    required String userId,
    required String governorate,
    required List<Map<String, dynamic>> answers,
    bool anonymous = false,
  }) async {
    try {
      await _remoteDataSource.submitResponse(
        surveyId: surveyId,
        squadId: squadId,
        userId: userId,
        governorate: governorate,
        answers: answers,
        anonymous: anonymous,
      );
      return (failure: null, success: true);
    } on DioException catch (e) {
      return (failure: mapDioError(e), success: false);
    } catch (_) {
      return (failure: const ServerFailure(), success: false);
    }
  }

  @override
  Future<({Failure? failure, SquadProgress? progress})> getSquadProgress(
    String squadId, {
    int target = 50,
  }) async {
    try {
      final data = await _remoteDataSource.getSquadProgress(squadId, target: target);
      return (failure: null, progress: SquadProgress.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), progress: null);
    } catch (_) {
      return (failure: const ServerFailure(), progress: null);
    }
  }

  @override
  Future<({Failure? failure, SurveyReport? report})> getReport(String scope, {String? id}) async {
    try {
      final data = await _remoteDataSource.getReport(scope, id: id);
      return (failure: null, report: SurveyReport.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), report: null);
    } catch (_) {
      return (failure: const ServerFailure(), report: null);
    }
  }
}
