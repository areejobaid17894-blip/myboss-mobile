import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/config/domain/entities/building.dart';
import 'package:myboss_mobile/features/config/domain/entities/employee_settings.dart';

abstract class ConfigRepository {
  Future<({Failure? failure, List<Building>? buildings})> getBuildings();
  Future<({Failure? failure, EmployeeSettings? settings})> getEmployeeSettings();
}
