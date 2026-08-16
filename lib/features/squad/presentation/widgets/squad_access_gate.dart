import 'package:flutter/material.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/resolve_user_squad_usecase.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/squad_usecases.dart';
import 'package:myboss_mobile/features/squad/presentation/widgets/squad_required_panel.dart';

/// Blocks child content until the user belongs to an active squad.
class SquadAccessGate extends StatefulWidget {
  const SquadAccessGate({super.key, required this.userId, required this.builder});

  final String userId;
  final Widget Function(BuildContext context, Squad squad) builder;

  @override
  State<SquadAccessGate> createState() => _SquadAccessGateState();
}

class _SquadAccessGateState extends State<SquadAccessGate> {
  bool _loading = true;
  Squad? _squad;
  SquadJoinStatus? _joinStatus;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final session = getIt<SessionManager>();
    final cached = session.currentSquad;
    if (cached != null && mounted) {
      setState(() {
        _loading = false;
        _squad = cached;
        _joinStatus = null;
      });
    } else if (mounted) {
      setState(() => _loading = true);
    }

    final squadResponse = await getIt<ResolveUserSquadUseCase>().call(widget.userId);

    if (!mounted) return;

    if (squadResponse.squad != null) {
      session.setSquad(squadResponse.squad);
      setState(() {
        _loading = false;
        _squad = squadResponse.squad;
        _joinStatus = null;
      });
      return;
    }

    if (cached != null) {
      setState(() {
        _loading = false;
        _squad = cached;
        _joinStatus = null;
      });
      return;
    }

    if (squadResponse.confirmedNoSquad) {
      session.markConfirmedNoSquad();
    }

    final statusResponse = await getIt<GetJoinStatusUseCase>().call(widget.userId);
    if (!mounted) return;

    setState(() {
      _loading = false;
      _squad = null;
      _joinStatus = statusResponse.status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.orange));
    }

    if (_squad != null) {
      return widget.builder(context, _squad!);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: SquadRequiredPanel(
        l10n: l10n,
        hasPendingJoinRequest: _joinStatus?.hasPendingJoinRequest ?? false,
        isPendingInvite: _joinStatus?.isPendingInvite ?? false,
        pendingSquadName: _joinStatus?.squadName,
        onRefresh: _load,
      ),
    );
  }
}
