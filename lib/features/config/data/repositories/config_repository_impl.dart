import 'package:dio/dio.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/core/network/dio_error_mapper.dart';
import 'package:myboss_mobile/features/config/data/datasources/config_remote_datasource.dart';
import 'package:myboss_mobile/features/config/domain/entities/building.dart';
import 'package:myboss_mobile/features/config/domain/entities/employee_settings.dart';
import 'package:myboss_mobile/features/config/domain/repositories/config_repository.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  const ConfigRepositoryImpl(this._remoteDataSource);

  final ConfigRemoteDataSource _remoteDataSource;

  @override
  Future<({Failure? failure, List<Building>? buildings})> getBuildings() async {
    try {
      final data = await _remoteDataSource.getBuildings();
      final buildings = data.map((e) => Building.fromJson(e as Map<String, dynamic>)).toList();
      return (failure: null, buildings: buildings);
    } on DioException catch (e) {
      return (failure: mapDioError(e), buildings: null);
    } catch (_) {
      return (failure: const ServerFailure(), buildings: null);
    }
  }

  @override
  Future<({Failure? failure, EmployeeSettings? settings})> getEmployeeSettings() async {
    try {
      final data = await _remoteDataSource.getEmployeeSettings();
      return (failure: null, settings: EmployeeSettings.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), settings: null);
    } catch (_) {
      return (failure: const ServerFailure(), settings: null);
    }
  }
}
