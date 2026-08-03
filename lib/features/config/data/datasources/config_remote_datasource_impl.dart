import 'package:myboss_mobile/core/network/dio_client.dart';
import 'package:myboss_mobile/features/config/data/datasources/config_remote_datasource.dart';

class ConfigRemoteDataSourceImpl implements ConfigRemoteDataSource {
  const ConfigRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<List<dynamic>> getBuildings() async {
    final response = await _client.config.get('/config/buildings');
    return response.data as List<dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getEmployeeSettings() async {
    final response = await _client.config.get('/config/employee-settings');
    return response.data as Map<String, dynamic>;
  }
}
