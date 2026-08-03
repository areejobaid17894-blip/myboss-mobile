import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/error/failure_message_mapper.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/localization/locale_cubit.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';
import 'package:myboss_mobile/core/widgets/boss_log_out_button.dart';
import 'package:myboss_mobile/features/config/domain/entities/employee_settings.dart';
import 'package:myboss_mobile/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:myboss_mobile/features/squad/domain/squad_access.dart';
import 'package:myboss_mobile/features/squad/presentation/widgets/squad_required_panel.dart';
import 'package:myboss_mobile/features/user/domain/entities/user_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionManager>();
    final userId = session.currentUser?.id ?? '';

    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..load(userId),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  String? _vestSize;
  bool _openToTravel = false;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionManager>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: const [
          LanguageToggleButton(),
          BossLogOutAppBarAction(),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.profile != null) {
            session.setUser(state.profile!);
            if (!_initialized) {
              _vestSize = state.profile!.vestSize;
              _openToTravel = state.profile!.openToTravel ?? false;
              _initialized = true;
            }
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.profile == null && session.currentUser == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.orange));
          }

          final profile = state.profile ?? session.currentUser;
          if (profile == null) {
            if (state.error != null) {
              return AppErrorView(
                failure: state.error!,
                onRetry: () => context.read<ProfileCubit>().load(session.currentUser?.id ?? ''),
              );
            }
            return Center(child: Text(l10n.loadProfileError));
          }

          final settings = state.settings ?? const EmployeeSettings(
            profileEditLimit: 2,
            vestSizeEditWindowStart: '',
            vestSizeEditWindowEnd: '',
          );
          final canEdit = settings.canEditProfile(profile.profileEditCount);
          final editsRemaining = settings.profileEditLimit - profile.profileEditCount;
          final hasChanges = _vestSize != profile.vestSize || _openToTravel != (profile.openToTravel ?? false);
          final inSquad = hasActiveSquad(session);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (!inSquad) ...[
                SquadRequiredPanel(l10n: l10n, showFeatureList: true),
                const SizedBox(height: 20),
              ],
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            localizedFailureMessage(l10n, state.error!),
                            style: const TextStyle(color: AppColors.error, fontSize: 13, height: 1.35),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.read<ProfileCubit>().load(profile.id),
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                ),
              _ProfileHeader(profile: profile),
              const SizedBox(height: 24),
              if (profile.profileEditCount >= 1 || settings.hasVestSizeEditWindow)
                _VestSizePolicyBanner(settings: settings, l10n: l10n),
              if (profile.profileEditCount >= 1 || settings.hasVestSizeEditWindow)
                const SizedBox(height: 16),
              Text(l10n.vestSize, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: vestSizes.map((size) {
                  final selected = _vestSize == size;
                  return ChoiceChip(
                    label: Text(size),
                    selected: selected,
                    onSelected: !canEdit ? null : (_) => setState(() => _vestSize = size),
                    selectedColor: AppColors.orange,
                    labelStyle: TextStyle(color: selected ? AppColors.white : AppColors.black, fontWeight: FontWeight.w600),
                    backgroundColor: AppColors.grey100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(l10n.openToTravel, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Switch(
                      value: _openToTravel,
                      activeThumbColor: AppColors.orange,
                      onChanged: !canEdit ? null : (v) => setState(() => _openToTravel = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                !canEdit && profile.profileEditCount >= 1 && !settings.isWithinVestSizeEditWindow()
                    ? l10n.vestSizeEditOutsideWindow
                    : editsRemaining <= 0
                        ? l10n.noProfileEditsRemaining
                        : editsRemaining == 1
                            ? l10n.profileEditsRemainingOne
                            : l10n.profileEditsRemaining(editsRemaining),
                style: const TextStyle(color: AppColors.grey600, fontSize: 12),
              ),
              if (state.saveError != null) ...[
                const SizedBox(height: 8),
                Text(
                  localizedFailureMessage(l10n, state.saveError!),
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ],
              const SizedBox(height: 16),
              BossPrimaryButton(
                label: l10n.saveChanges,
                isLoading: state.isSaving,
                onPressed: !hasChanges || !canEdit
                    ? null
                    : () => context.read<ProfileCubit>().save(
                          id: profile.id,
                          vestSize: _vestSize,
                          openToTravel: _openToTravel,
                        ),
              ),
              const SizedBox(height: 32),
              if (inSquad)
                _ProfileLinkTile(
                  icon: Icons.chat_rounded,
                  label: l10n.liveChat,
                  onTap: () => context.push('/chat'),
                )
              else
                SquadLockedFeatureTile(
                  icon: Icons.chat_rounded,
                  label: l10n.liveChat,
                  lockedHint: l10n.noSquadChatLockedHint,
                  onJoin: () => context.push('/squad/join'),
                ),
              const SizedBox(height: 12),
              if (inSquad)
                _ProfileLinkTile(
                  icon: Icons.feedback_rounded,
                  label: l10n.employeeFeedbackSurvey,
                  onTap: () => context.push('/survey/employee'),
                )
              else
                SquadLockedFeatureTile(
                  icon: Icons.feedback_rounded,
                  label: l10n.employeeFeedbackSurvey,
                  lockedHint: l10n.noSquadSurveyLockedHint,
                  onJoin: () => context.push('/squad/join'),
                ),
              const SizedBox(height: 12),
              _ProfileLinkTile(
                icon: Icons.bar_chart_rounded,
                label: l10n.reports,
                onTap: () => context.push('/reports'),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.logOut,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.error),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.logOutConfirmMessage,
                      style: const TextStyle(color: AppColors.grey600, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    const BossLogOutButton(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _formatPolicyDate(String raw, BuildContext context) {
  final parsed = DateTime.tryParse('${raw.trim()}T00:00:00');
  if (parsed == null) return raw;
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).format(parsed);
}

class _VestSizePolicyBanner extends StatelessWidget {
  const _VestSizePolicyBanner({required this.settings, required this.l10n});

  final EmployeeSettings settings;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final hasWindow = settings.hasVestSizeEditWindow;
    final start = hasWindow ? _formatPolicyDate(settings.vestSizeEditWindowStart, context) : '';
    final end = hasWindow ? _formatPolicyDate(settings.vestSizeEditWindowEnd, context) : '';
    final message = hasWindow
        ? l10n.vestSizeChangePolicyNote(start, end)
        : l10n.vestSizeChangePolicyNoWindow;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.orangeLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.orangeDark, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.vestSizeChangePolicyTitle,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.orangeDark),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(color: AppColors.grey600, fontSize: 13, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.orangeLight, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.orange,
            child: Text(
              profile.firstName.isNotEmpty ? profile.firstName[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(profile.email, style: const TextStyle(color: AppColors.grey600, fontSize: 13)),
                if (profile.buildingName != null) ...[
                  const SizedBox(height: 4),
                  Text('${profile.buildingName} · ${profile.governorate ?? ''}', style: const TextStyle(color: AppColors.grey600, fontSize: 12)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLinkTile extends StatelessWidget {
  const _ProfileLinkTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.orange),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            const BossChevronIcon(),
          ],
        ),
      ),
    );
  }
}
