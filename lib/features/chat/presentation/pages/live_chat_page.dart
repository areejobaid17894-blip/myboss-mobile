import 'package:flutter/material.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_back_button.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';
import 'package:myboss_mobile/features/chat/domain/entities/chat_message.dart';
import 'package:myboss_mobile/features/chat/presentation/widgets/native_chat_view.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/resolve_user_squad_usecase.dart';
import 'package:myboss_mobile/features/squad/presentation/widgets/squad_required_panel.dart';

class LiveChatPage extends StatefulWidget {
  const LiveChatPage({super.key});

  @override
  State<LiveChatPage> createState() => _LiveChatPageState();
}

class _LiveChatPageState extends State<LiveChatPage> {
  bool _loadingContacts = true;
  Squad? _squad;
  List<ChatContact> _contacts = const [];
  ChatContact? _selectedContact;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _loadingContacts = true);

    final session = getIt<SessionManager>();
    final userId = session.currentUser?.id ?? '';
    final contacts = <ChatContact>[];

    if (userId.isNotEmpty) {
      final response = await getIt<ResolveUserSquadUseCase>().call(userId);
      final squad = response.squad;
      if (squad != null) {
        session.setSquad(squad);
        for (final member in squad.members) {
          if (member.userId == userId) continue;
          contacts.add(ChatContact(
            id: member.userId,
            name: member.displayName,
            subtitle: member.isLeader ? 'leader' : squad.name,
          ));
        }
      } else if (response.confirmedNoSquad) {
        session.markConfirmedNoSquad();
      }
      if (!mounted) return;
      setState(() {
        _squad = squad;
        _contacts = contacts;
        _loadingContacts = false;
        if (_selectedContact != null && !contacts.any((c) => c.id == _selectedContact!.id)) {
          _selectedContact = null;
        }
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _squad = null;
      _contacts = contacts;
      _loadingContacts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = getIt<SessionManager>();
    final userId = session.currentUser?.id ?? '';
    final selected = _selectedContact;
    final hasSquad = _squad != null;

    return Scaffold(
      appBar: BossFlowAppBar(
        title: Text(l10n.liveChatTitle),
        fallbackRoute: '/home',
      ),
      body: _loadingContacts
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : !hasSquad
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: SquadRequiredPanel(l10n: l10n),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SquadChatBanner(l10n: l10n, squadName: _squad!.name),
                    _RecipientSelector(
                      l10n: l10n,
                      contacts: _contacts,
                      selected: selected,
                      onSelected: (contact) => setState(() => _selectedContact = contact),
                    ),
                    Expanded(
                      child: selected == null
                          ? _SelectTeammatePrompt(
                              l10n: l10n,
                              contacts: _contacts,
                              onSelect: (c) => setState(() => _selectedContact = c),
                            )
                          : NativeChatView(
                              key: ValueKey(selected.id),
                              contact: selected,
                              currentUserId: userId,
                            ),
                    ),
                  ],
                ),
    );
  }
}

class _SquadChatBanner extends StatelessWidget {
  const _SquadChatBanner({required this.l10n, required this.squadName});

  final AppLocalizations l10n;
  final String squadName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.orangeLight,
      child: Row(
        children: [
          const Icon(Icons.groups_rounded, color: AppColors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.chatSquadOnlyHint(squadName),
              style: const TextStyle(color: AppColors.grey900, fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipientSelector extends StatelessWidget {
  const _RecipientSelector({
    required this.l10n,
    required this.contacts,
    required this.selected,
    required this.onSelected,
  });

  final AppLocalizations l10n;
  final List<ChatContact> contacts;
  final ChatContact? selected;
  final ValueChanged<ChatContact?> onSelected;

  String _subtitleFor(ChatContact contact) {
    if (contact.subtitle == 'leader') return l10n.leader;
    return contact.subtitle ?? l10n.chatTeammateSubtitle;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.chatSelectRecipient,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.black),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.chatSquadMembersOnly,
              style: const TextStyle(color: AppColors.grey600, fontSize: 13, height: 1.35),
            ),
            const SizedBox(height: 12),
            if (contacts.isEmpty)
              Text(l10n.chatNoTeammatesYet, style: const TextStyle(color: AppColors.grey600))
            else
              DropdownButtonFormField<ChatContact>(
                value: selected,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: l10n.chatSelectRecipientPlaceholder,
                  filled: true,
                  fillColor: AppColors.orangeLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: contacts
                    .map(
                      (contact) => DropdownMenuItem(
                        value: contact,
                        child: Row(
                          children: [
                            const Icon(Icons.person_rounded, color: AppColors.orange, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(contact.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  Text(
                                    _subtitleFor(contact),
                                    style: const TextStyle(color: AppColors.grey600, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onSelected,
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectTeammatePrompt extends StatelessWidget {
  const _SelectTeammatePrompt({
    required this.l10n,
    required this.contacts,
    required this.onSelect,
  });

  final AppLocalizations l10n;
  final List<ChatContact> contacts;
  final ValueChanged<ChatContact> onSelect;

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.chatNoTeammatesYet, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.grey600, height: 1.4)),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l10n.chatQuickPick, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 12),
        ...contacts.map(
          (contact) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: BossPrimaryButton(
              label: contact.name,
              icon: Icons.chat_rounded,
              onPressed: () => onSelect(contact),
            ),
          ),
        ),
      ],
    );
  }
}
