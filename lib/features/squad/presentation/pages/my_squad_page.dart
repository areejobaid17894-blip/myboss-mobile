import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/localization/locale_cubit.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';
import 'package:myboss_mobile/features/squad/presentation/cubit/my_squad_cubit.dart';

class MySquadPage extends StatelessWidget {
  const MySquadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionManager>();
    final userId = session.currentUser?.id;

    return BlocProvider(
      create: (_) => getIt<MySquadCubit>()..load(userId ?? ''),
      child: const _MySquadView(),
    );
  }
}

class _MySquadView extends StatelessWidget {
  const _MySquadView();

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionManager>();
    final userId = session.currentUser?.id ?? '';
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mySquadTitle),
        actions: [
          const LanguageToggleButton(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.refresh,
            onPressed: () => context.read<MySquadCubit>().load(userId),
          ),
        ],
      ),
      body: BlocConsumer<MySquadCubit, MySquadState>(
        listener: (context, state) {
          if (state.squad != null) {
            session.setSquad(state.squad);
          } else if (state.notInSquad) {
            session.setSquad(null);
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.squad == null && !state.notInSquad) {
            return const Center(child: CircularProgressIndicator(color: AppColors.orange));
          }
          if (state.squad != null && !state.notInSquad) {
            final squad = state.squad!;
            final isLeader = squad.isLeader(userId);

            return RefreshIndicator(
              color: AppColors.orange,
              onRefresh: () => context.read<MySquadCubit>().load(userId),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (state.error != null) ...[
                    AppErrorView(failure: state.error!, onRetry: () => context.read<MySquadCubit>().load(userId)),
                    const SizedBox(height: 16),
                  ],
                  _SquadHeader(squad: squad, l10n: l10n),
                  const SizedBox(height: 24),
                  Text(l10n.members(squad.members.length), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...squad.members.map((m) => _MemberTile(
                        member: m,
                        leaderLabel: l10n.leader,
                        canRemove: isLeader && !m.isLeader,
                        isRemoving: state.removingMemberId == m.userId,
                        removeLabel: l10n.removeMember,
                        onRemove: () => _confirmRemoveMember(context, squad: squad, member: m, leaderId: userId, l10n: l10n),
                      )),
                  if (isLeader) ...[
                    const SizedBox(height: 24),
                    Text(l10n.joinRequests(squad.pendingRequests.length), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    if (squad.pendingRequests.isEmpty)
                      Text(l10n.noJoinRequests, style: const TextStyle(color: AppColors.grey600))
                    else
                      ...squad.pendingRequests.map((r) => _JoinRequestTile(
                            request: r,
                            isResponding: state.respondingRequestId == r.id,
                            onAccept: () => context.read<MySquadCubit>().respond(requestId: r.id, leaderId: userId, accept: true),
                            onDecline: () => context.read<MySquadCubit>().respond(requestId: r.id, leaderId: userId, accept: false),
                          )),
                  ],
                  const SizedBox(height: 28),
                  _LeaveSquadSection(
                    squad: squad,
                    userId: userId,
                    isLeader: isLeader,
                    isLeaving: state.isLeaving,
                    l10n: l10n,
                  ),
                ],
              ),
            );
          }

          return _NoSquadView(
            l10n: l10n,
            hasPendingJoinRequest: state.hasPendingJoinRequest,
            pendingSquadName: state.joinStatus?.squadName,
            onRefresh: () => context.read<MySquadCubit>().load(userId),
          );
        },
      ),
    );
  }
}

Future<void> _confirmRemoveMember(
  BuildContext context, {
  required Squad squad,
  required SquadMember member,
  required String leaderId,
  required AppLocalizations l10n,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.removeMemberConfirmTitle),
      content: Text(l10n.removeMemberConfirmMessage(member.displayName)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.logOutConfirmNo)),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.removeMemberConfirmYes, style: const TextStyle(color: AppColors.error)),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  await context.read<MySquadCubit>().removeMember(
        squadId: squad.id,
        leaderId: leaderId,
        memberId: member.userId,
      );
}

class _SquadHeader extends StatelessWidget {
  const _SquadHeader({required this.squad, required this.l10n});

  final Squad squad;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.orangeLight, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18)),
            child: Text(squad.badge, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(squad.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${squad.squadCode} · ${squad.governorate}', style: const TextStyle(color: AppColors.grey600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  l10n.squadTarget(squad.surveyTarget),
                  style: const TextStyle(color: AppColors.orangeDark, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.leaderLabel,
    this.canRemove = false,
    this.isRemoving = false,
    this.removeLabel,
    this.onRemove,
  });

  final SquadMember member;
  final String leaderLabel;
  final bool canRemove;
  final bool isRemoving;
  final String? removeLabel;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: member.isLeader ? AppColors.orange : AppColors.grey200,
            child: Icon(member.isLeader ? Icons.star_rounded : Icons.person_rounded, color: member.isLeader ? AppColors.white : AppColors.grey600, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                if (member.building != null)
                  Text(member.building!, style: const TextStyle(color: AppColors.grey600, fontSize: 12)),
              ],
            ),
          ),
          if (member.isLeader)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(leaderLabel, style: const TextStyle(color: AppColors.orangeDark, fontWeight: FontWeight.w600, fontSize: 12)),
            )
          else if (canRemove)
            isRemoving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orange))
                : IconButton(
                    icon: const Icon(Icons.person_remove_rounded, color: AppColors.error),
                    tooltip: removeLabel,
                    onPressed: onRemove,
                  ),
        ],
      ),
    );
  }
}

class _JoinRequestTile extends StatelessWidget {
  const _JoinRequestTile({
    required this.request,
    required this.isResponding,
    required this.onAccept,
    required this.onDecline,
  });

  final SquadJoinRequest request;
  final bool isResponding;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                if (request.building != null)
                  Text(request.building!, style: const TextStyle(color: AppColors.grey600, fontSize: 12)),
              ],
            ),
          ),
          if (isResponding)
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orange))
          else ...[
            IconButton(
              icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
              onPressed: onAccept,
            ),
            IconButton(
              icon: const Icon(Icons.cancel_rounded, color: AppColors.error),
              onPressed: onDecline,
            ),
          ],
        ],
      ),
    );
  }
}

class _NoSquadView extends StatelessWidget {
  const _NoSquadView({
    required this.l10n,
    required this.onRefresh,
    this.hasPendingJoinRequest = false,
    this.pendingSquadName,
  });

  final AppLocalizations l10n;
  final VoidCallback onRefresh;
  final bool hasPendingJoinRequest;
  final String? pendingSquadName;

  @override
  Widget build(BuildContext context) {
    final title = hasPendingJoinRequest ? l10n.pendingJoinRequestTitle : l10n.noSquadTitle;
    final description = hasPendingJoinRequest
        ? l10n.pendingJoinRequestBody(pendingSquadName ?? '')
        : l10n.noSquadDesc;
    final icon = hasPendingJoinRequest ? Icons.hourglass_top_rounded : Icons.groups_rounded;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.orangeLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(icon, size: 56, color: AppColors.orange),
                const SizedBox(height: 16),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(description, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.grey600, height: 1.45, fontSize: 15)),
                if (!hasPendingJoinRequest) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.servicesLockedDesc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.grey600, height: 1.4, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          if (hasPendingJoinRequest)
            OutlinedButton(
              onPressed: onRefresh,
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
              child: Text(l10n.refresh),
            )
          else ...[
            BossPrimaryButton(
              label: l10n.joinSquad,
              onPressed: () => context.push('/squad/join'),
            ),
          ],
        ],
      ),
    );
  }
}

class _LeaveSquadSection extends StatelessWidget {
  const _LeaveSquadSection({
    required this.squad,
    required this.userId,
    required this.isLeader,
    required this.isLeaving,
    required this.l10n,
  });

  final Squad squad;
  final String userId;
  final bool isLeader;
  final bool isLeaving;
  final AppLocalizations l10n;

  Future<void> _confirmLeave(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.leaveSquadConfirmTitle),
        content: Text(l10n.leaveSquadConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.logOutConfirmNo)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.leaveSquadConfirmYes, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    if (isLeader) {
      await _showTransferDialog(context);
      return;
    }

    final ok = await context.read<MySquadCubit>().leaveSquad(squadId: squad.id, userId: userId);
    if (!context.mounted) return;
    if (ok) {
      getIt<SessionManager>().setSquad(null);
      context.go('/squad/hub');
    }
  }

  Future<void> _showTransferDialog(BuildContext context) async {
    final candidates = squad.members.where((m) => m.userId != userId).toList();
    if (candidates.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.transferLeaderNoMembers)));
      return;
    }

    String? selectedId = candidates.first.userId;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.transferLeaderTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.transferLeaderMessage),
              const SizedBox(height: 16),
              ...candidates.map((member) => RadioListTile<String>(
                    value: member.userId,
                    groupValue: selectedId,
                    onChanged: (value) => setState(() => selectedId = value),
                    title: Text(member.displayName),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  )),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.logOutConfirmNo)),
            TextButton(
              onPressed: selectedId == null ? null : () => Navigator.pop(ctx, true),
              child: Text(l10n.transferLeaderConfirm),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || selectedId == null || !context.mounted) return;
    final ok = await context.read<MySquadCubit>().transferAndLeave(
          squadId: squad.id,
          leaderId: userId,
          newLeaderId: selectedId!,
        );
    if (!context.mounted) return;
    if (ok) {
      getIt<SessionManager>().setSquad(null);
      context.go('/squad/hub');
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLeaving ? null : () => _confirmLeave(context),
      icon: isLeaving
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.logout_rounded, color: AppColors.error),
      label: Text(l10n.leaveSquad, style: const TextStyle(color: AppColors.error)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
      ),
    );
  }
}
