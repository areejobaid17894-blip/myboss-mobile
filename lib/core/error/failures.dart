import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({this.code});

  /// Stable backend error code used for localized client messages.
  final String? code;

  @override
  List<Object?> get props => [code];
}

class ServerFailure extends Failure {
  const ServerFailure({super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.code});
}

class AuthFailure extends Failure {
  const AuthFailure({super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.code});
}

class CacheFailure extends Failure {
  const CacheFailure({super.code});
}
