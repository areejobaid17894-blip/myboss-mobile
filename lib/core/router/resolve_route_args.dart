import 'package:myboss_mobile/features/auth/domain/entities/user.dart';

class ResolveRouteArgs {
  const ResolveRouteArgs({required this.authUser});

  final User authUser;
}
