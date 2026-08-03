import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/config/domain/entities/building.dart';
import 'package:myboss_mobile/features/config/domain/repositories/config_repository.dart';

class GetBuildingsUseCase {
  const GetBuildingsUseCase(this._repository);

  final ConfigRepository _repository;

  Future<({Failure? failure, List<Building>? buildings})> call() {
    return _repository.getBuildings();
  }
}
