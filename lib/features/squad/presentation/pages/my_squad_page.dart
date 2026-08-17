import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:myboss_mobile/features/squad/presentation/widgets/squad_join_policy_banner.dart';
import 'package:myboss_mobile/features/config/domain/entities/employee_settings.dart';

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
                  if (isLeader) ...[
                    const SizedBox(height: 16),
                    SquadJoinPolicyBanner(settings: state.settings, compact: true),
                  ],
                  const SizedBox(height: 24),
                  Text(l10n.members(squad.members.length, squad.maxMembers), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
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
                    ...List.generate(
                      squad.pendingInvites.length,
                      (_) => _SlotRow(
                        held: true,
                        label: l10n.heldSlotPending,
                      ),
                    ),
                    ...List.generate(
                      squad.seatsLeft,
                      (_) => _SlotRow(
                        held: false,
                        label: l10n.openSlotInvite,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InviteMemberButton(
                      squad: squad,
                      l10n: l10n,
                      joinClosed: state.employeeJoinClosed,
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.joinRequests(squad.pendingJoinRequests.length), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    if (squad.pendingJoinRequests.isEmpty)
                      Text(l10n.noJoinRequests, style: const TextStyle(color: AppColors.grey600))
                    else
                      ...squad.pendingJoinRequests.map((r) => _JoinRequestTile(
                            request: r,
                            isResponding: state.respondingRequestId == r.id,
                            canAccept: squad.members.length < squad.maxMembers,
                            fullTooltip: l10n.squadFullNoSeats(squad.members.length, squad.maxMembers),
                            onAccept: () => context.read<MySquadCubit>().respond(requestId: r.id, leaderId: userId, accept: true),
                            onDecline: () => context.read<MySquadCubit>().respond(requestId: r.id, leaderId: userId, accept: false),
                          )),
                    const SizedBox(height: 24),
                    Text(l10n.myInvitationsTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(l10n.myInvitationsSub, style: const TextStyle(color: AppColors.grey600, fontSize: 12)),
                    const SizedBox(height: 12),
                    if (squad.pendingInvites.isEmpty)
                      Text(l10n.noPendingInvites, style: const TextStyle(color: AppColors.grey600))
                    else
                      ...squad.pendingInvites.map((r) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(14)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(r.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text(l10n.invitedLabel, style: const TextStyle(color: AppColors.grey600, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: state.cancellingInviteId == r.id
                                      ? null
                                      : () async {
                                          final ok = await context.read<MySquadCubit>().cancelInvite(r.id);
                                          if (!context.mounted || !ok) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(l10n.inviteCancelled)),
                                          );
                                        },
                                  child: state.cancellingInviteId == r.id
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orange),
                                        )
                                      : Text(l10n.cancelInvite, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
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
            isPendingInvite: state.isPendingInvite,
            pendingSquadName: state.joinStatus?.squadName,
            isResponding: state.respondingRequestId != null,
            joinClosed: state.employeeJoinClosed,
            settings: state.settings,
            onRefresh: () => context.read<MySquadCubit>().load(userId),
            onCancelJoinRequest: () => context.read<MySquadCubit>().cancelMyJoinRequest(),
            onAcceptInvite: state.employeeJoinClosed
                ? null
                : () => context.read<MySquadCubit>().respondToInvite(accept: true),
            onRejectInvite: () => context.read<MySquadCubit>().respondToInvite(accept: false),
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
                Text(
                  '${squad.squadCode} · ${squad.governorate} · ${squad.members.length}/${squad.maxMembers}',
                  style: const TextStyle(color: AppColors.grey600, fontSize: 13),
                  textDirection: TextDirection.ltr,
                ),
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
    this.canAccept = true,
    this.fullTooltip,
  });

  final SquadJoinRequest request;
  final bool isResponding;
  final bool canAccept;
  final String? fullTooltip;
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
              icon: Icon(
                Icons.check_circle_rounded,
                color: canAccept ? AppColors.success : AppColors.grey400,
              ),
              onPressed: canAccept ? onAccept : null,
              tooltip: canAccept ? null : fullTooltip,
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

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.held, required this.label});

  final bool held;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
              border: Border.all(
                color: held ? AppColors.orange : AppColors.grey200,
                style: BorderStyle.solid,
              ),
            ),
            child: Text(
              held ? '⏳' : '+',
              style: TextStyle(
                color: held ? AppColors.orangeDark : AppColors.grey600,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: held ? AppColors.orangeDark : AppColors.grey600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteMemberButton extends StatelessWidget {
  const _InviteMemberButton({
    required this.squad,
    required this.l10n,
    this.joinClosed = false,
  });

  final Squad squad;
  final AppLocalizations l10n;
  final bool joinClosed;

  String get _label {
    final seats = squad.seatsLeft;
    if (seats <= 0) return l10n.inviteMemberFull;
    if (seats == 1) return l10n.inviteMemberOne;
    return l10n.inviteMember(seats);
  }

  String? get _hint {
    if (joinClosed) return null;
    final physicalOpen = squad.maxMembers - squad.members.length;
    if (physicalOpen <= 0) return l10n.inviteDisabledFull;
    if (squad.seatsLeft <= 0) return l10n.inviteDisabledPendingHold;
    return null;
  }

  Future<void> _openInviteSheet(BuildContext context) async {
    final cubit = context.read<MySquadCubit>();
    await cubit.loadSuggestedMembers();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: _InviteMembersSheet(squad: squad, l10n: l10n),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final disabled = squad.seatsLeft <= 0 || joinClosed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BossPrimaryButton(
          label: _label,
          onPressed: disabled ? null : () => _openInviteSheet(context),
        ),
        if (_hint != null) ...[
          const SizedBox(height: 8),
          Text(
            _hint!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.grey600, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _InviteMembersSheet extends StatefulWidget {
  const _InviteMembersSheet({required this.squad, required this.l10n});

  final Squad squad;
  final AppLocalizations l10n;

  @override
  State<_InviteMembersSheet> createState() => _InviteMembersSheetState();
}

class _InviteMembersSheetState extends State<_InviteMembersSheet> {
  String _query = '';

  Future<void> _shareCode(BuildContext context) async {
    final squad = widget.squad;
    final l10n = widget.l10n;
    final message = l10n.inviteShareMessage(squad.name, squad.squadCode);
    final code = Uri.encodeQueryComponent(squad.squadCode);
    final base = Uri.base;
    final link = (base.hasScheme && (base.scheme == 'http' || base.scheme == 'https'))
        ? '${base.origin}/squad/join?code=$code'
        : '/squad/join?code=$code';
    await Clipboard.setData(ClipboardData(text: '$message\n$link'));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.inviteCopied)));
  }

  List<SuggestedSquadUser> _filtered(List<SuggestedSquadUser> items) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((user) {
      final name = user.displayName.toLowerCase();
      final email = (user.email ?? '').toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();
  }

  String? _inviteWhy(SuggestedSquadUser user, int seats) {
    if (user.unregistered) return widget.l10n.inviteWhyUnregistered;
    if (user.invited) return widget.l10n.inviteWhyPending;
    if (!user.canInvite && seats <= 0) return widget.l10n.inviteWhyNoSeats;
    return null;
  }

  Widget _badge(SuggestedSquadUser user) {
    final l10n = widget.l10n;
    if (user.unregistered) {
      return _StatusBadge(label: l10n.badgeUnregistered, color: AppColors.grey600, background: AppColors.grey100);
    }
    if (user.invited) {
      return _StatusBadge(label: l10n.invitedLabel, color: const Color(0xFF8A7300), background: const Color(0xFFFFF8D6));
    }
    if (user.inSquadName != null && user.inSquadName!.isNotEmpty) {
      return _StatusBadge(
        label: l10n.badgeInSquad(user.inSquadName!),
        color: const Color(0xFF1D7FAE),
        background: const Color(0xFFE7F5FC),
      );
    }
    return _StatusBadge(label: l10n.badgeNoSquad, color: AppColors.grey600, background: AppColors.grey100);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.72;
    final l10n = widget.l10n;
    return SizedBox(
      height: height,
      child: BlocBuilder<MySquadCubit, MySquadState>(
        builder: (context, state) {
          final seats = state.remainingInviteSeats;
          final filtered = _filtered(state.suggestedMembers);
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.suggestedMembersTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(l10n.inviteSheetSubtitle(seats), style: const TextStyle(color: AppColors.grey600, fontSize: 13)),
                if (state.error != null) ...[
                  const SizedBox(height: 8),
                  AppErrorView(failure: state.error!),
                ],
                const SizedBox(height: 12),
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: l10n.searchNameOrEmail,
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: state.loadingSuggestions
                      ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
                      : filtered.isEmpty
                          ? Center(child: Text(l10n.suggestedMembersEmpty, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.grey600)))
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final user = filtered[index];
                                final inviting = state.invitingUserId == user.id;
                                final canInvite = user.canInvite && seats > 0;
                                final why = _inviteWhy(user, seats);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(14)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                                if (user.email != null && user.email!.isNotEmpty) ...[
                                                  const SizedBox(height: 2),
                                                  Text(user.email!, style: const TextStyle(color: AppColors.grey600, fontSize: 12)),
                                                ],
                                                const SizedBox(height: 6),
                                                _badge(user),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 88,
                                            child: BossPrimaryButton(
                                              label: canInvite ? l10n.sendInvite : '—',
                                              compact: true,
                                              isLoading: inviting,
                                              onPressed: canInvite && !inviting
                                                  ? () async {
                                                      final ok = await context.read<MySquadCubit>().inviteMember(user.id);
                                                      if (!context.mounted || !ok) return;
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.inviteSent)));
                                                    }
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (why != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                                        child: Text(why, style: const TextStyle(color: AppColors.grey600, fontSize: 11)),
                                      ),
                                  ],
                                );
                              },
                            ),
                ),
                const SizedBox(height: 8),
                Text(
                  seats <= 0 ? l10n.inviteNoSeatsHint : l10n.inviteSlotsHeldHint(widget.squad.maxMembers),
                  style: const TextStyle(color: AppColors.grey600, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 4),
                Text(l10n.inviteOtherSquadHint, style: const TextStyle(color: AppColors.grey600, fontSize: 12, height: 1.4)),
                TextButton(
                  onPressed: seats > 0 ? () => _shareCode(context) : null,
                  child: Text(l10n.shareSquadCode),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color, required this.background});

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _NoSquadView extends StatelessWidget {
  const _NoSquadView({
    required this.l10n,
    required this.onRefresh,
    this.hasPendingJoinRequest = false,
    this.isPendingInvite = false,
    this.pendingSquadName,
    this.isResponding = false,
    this.joinClosed = false,
    this.settings,
    this.onAcceptInvite,
    this.onRejectInvite,
    this.onCancelJoinRequest,
  });

  final AppLocalizations l10n;
  final VoidCallback onRefresh;
  final bool hasPendingJoinRequest;
  final bool isPendingInvite;
  final String? pendingSquadName;
  final bool isResponding;
  final bool joinClosed;
  final EmployeeSettings? settings;
  final VoidCallback? onAcceptInvite;
  final VoidCallback? onRejectInvite;
  final VoidCallback? onCancelJoinRequest;

  @override
  Widget build(BuildContext context) {
    final title = isPendingInvite
        ? l10n.pendingInviteTitle
        : hasPendingJoinRequest
            ? l10n.pendingJoinRequestTitle
            : l10n.noSquadTitle;
    final description = isPendingInvite
        ? l10n.pendingInviteBody(pendingSquadName ?? '')
        : hasPendingJoinRequest
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
          const SizedBox(height: 16),
          SquadJoinPolicyBanner(settings: settings),
          const SizedBox(height: 16),
          if (isPendingInvite) ...[
            BossPrimaryButton(
              label: l10n.acceptInvite,
              isLoading: isResponding,
              onPressed: isResponding ? null : onAcceptInvite,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: isResponding ? null : onRejectInvite,
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
              child: Text(l10n.rejectInvite),
            ),
          ] else if (hasPendingJoinRequest) ...[
            BossPrimaryButton(
              label: l10n.cancelJoinRequest,
              variant: BossButtonVariant.outline,
              isLoading: isResponding,
              onPressed: isResponding ? null : onCancelJoinRequest,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRefresh,
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
              child: Text(l10n.refresh),
            ),
          ] else if (!joinClosed) ...[
            BossPrimaryButton(
              label: l10n.createSquad,
              onPressed: () => context.push('/squad/create'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.push('/squad/join'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
              child: Text(l10n.joinSquad),
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
