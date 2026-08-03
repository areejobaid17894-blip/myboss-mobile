import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/squad_usecases.dart';

sealed class CreateSquadState extends Equatable {
  const CreateSquadState();

  @override
  List<Object?> get props => [];
}

class CreateSquadInitial extends CreateSquadState {
  const CreateSquadInitial();
}

class CreateSquadSubmitting extends CreateSquadState {
  const CreateSquadSubmitting();
}

class CreateSquadSuccess extends CreateSquadState {
  const CreateSquadSuccess(this.squad);
  final Squad squad;

  @override
  List<Object?> get props => [squad];
}

class CreateSquadError extends CreateSquadState {
  const CreateSquadError(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class CreateSquadCubit extends Cubit<CreateSquadState> {
  CreateSquadCubit(this._createSquadUseCase) : super(const CreateSquadInitial());

  final CreateSquadUseCase _createSquadUseCase;

  Future<void> submit({
    required String name,
    required String badge,
    required String leaderId,
    required String leaderFirstName,
    required String leaderLastName,
    required String governorate,
    String? building,
  }) async {
    emit(const CreateSquadSubmitting());
    final response = await _createSquadUseCase(
      name: name,
      badge: badge,
      leaderId: leaderId,
      leaderFirstName: leaderFirstName,
      leaderLastName: leaderLastName,
      governorate: governorate,
      building: building,
    );
    if (response.failure != null) {
      emit(CreateSquadError(response.failure!));
      return;
    }
    emit(CreateSquadSuccess(response.squad!));
  }
}
