import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/config/domain/entities/employee_settings.dart';
import 'package:myboss_mobile/features/config/domain/repositories/config_repository.dart';

class GetEmployeeSettingsUseCase {
  const GetEmployeeSettingsUseCase(this._repository);
  final ConfigRepository _repository;

  Future<({Failure? failure, EmployeeSettings? settings})> call() =>
      _repository.getEmployeeSettings();
}
