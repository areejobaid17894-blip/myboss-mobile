import 'package:dio/dio.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/core/network/dio_error_mapper.dart';
import 'package:myboss_mobile/features/survey/data/datasources/survey_remote_datasource.dart';
import 'package:myboss_mobile/features/survey/data/survey_schema_cache.dart';
import 'package:myboss_mobile/features/survey/domain/entities/survey.dart';
import 'package:myboss_mobile/features/survey/domain/repositories/survey_repository.dart';

class SurveyRepositoryImpl implements SurveyRepository {
  const SurveyRepositoryImpl(this._remoteDataSource, this._schemaCache);

  final SurveyRemoteDataSource _remoteDataSource;
  final SurveySchemaCache _schemaCache;

  @override
  Future<({Failure? failure, List<DynamicSurvey> surveys})> listSurveys() async {
    try {
      final data = await _remoteDataSource.listSurveys();
      final catalog = data
          .where((item) => item['isActive'] != false)
          .map(DynamicSurvey.fromJson)
          .toList();

      final hydrated = <DynamicSurvey>[];
      for (final survey in catalog) {
        if (survey.segment.isEmpty) continue;
        final full = await getActiveSurvey(survey.segment);
        hydrated.add(full.survey ?? survey);
      }

      await _schemaCache.saveCatalog(hydrated);
      return (failure: null, surveys: hydrated);
    } on DioException catch (e) {
      final cached = await _schemaCache.listAll();
      if (cached.isNotEmpty) {
        return (failure: null, surveys: cached);
      }
      return (failure: mapDioError(e), surveys: <DynamicSurvey>[]);
    } catch (_) {
      final cached = await _schemaCache.listAll();
      if (cached.isNotEmpty) {
        return (failure: null, surveys: cached);
      }
      return (failure: const ServerFailure(), surveys: <DynamicSurvey>[]);
    }
  }

  @override
  Future<({Failure? failure, DynamicSurvey? survey})> getActiveSurvey(String segment) async {
    try {
      final data = await _remoteDataSource.getActiveSurvey(segment);
      final survey = DynamicSurvey.fromJson(data);
      await _schemaCache.saveSchema(survey);
      return (failure: null, survey: survey);
    } on DioException catch (e) {
      final cached = await _schemaCache.getBySegment(segment);
      if (cached != null && cached.questions.isNotEmpty) {
        return (failure: null, survey: cached);
      }
      return (failure: mapDioError(e), survey: cached);
    } catch (_) {
      final cached = await _schemaCache.getBySegment(segment);
      if (cached != null && cached.questions.isNotEmpty) {
        return (failure: null, survey: cached);
      }
      return (failure: const ServerFailure(), survey: cached);
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
