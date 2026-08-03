abstract class ConfigRemoteDataSource {
  Future<List<dynamic>> getBuildings();
  Future<Map<String, dynamic>> getEmployeeSettings();
}
