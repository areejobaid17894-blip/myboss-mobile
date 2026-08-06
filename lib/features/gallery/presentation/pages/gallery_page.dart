import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/notifications/notification_route.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/error/failure_message_mapper.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/localization/locale_cubit.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';
import 'package:myboss_mobile/features/gallery/domain/entities/gallery_item.dart';
import 'package:myboss_mobile/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';
import 'package:myboss_mobile/features/squad/domain/squad_access.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/resolve_user_squad_usecase.dart';
import 'package:myboss_mobile/features/squad/presentation/widgets/squad_required_panel.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GalleryCubit>()..load(),
      child: const _GalleryView(),
    );
  }
}

class _GalleryView extends StatefulWidget {
  const _GalleryView();

  @override
  State<_GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<_GalleryView> {
  bool _loadingSquad = true;
  Squad? _squad;
  bool _wasUploading = false;
  bool _confirmedNoSquad = false;

  @override
  void initState() {
    super.initState();
    _loadSquad();
  }

  Future<void> _loadSquad() async {
    final session = getIt<SessionManager>();
    final cached = session.currentSquad;
    if (cached != null && mounted) {
      setState(() => _squad = cached);
    }

    final userId = session.currentUser?.id ?? '';
    if (userId.isEmpty) {
      setState(() {
        _loadingSquad = false;
        _squad = null;
        _confirmedNoSquad = true;
      });
      return;
    }

    final response = await getIt<ResolveUserSquadUseCase>().call(userId);
    if (!mounted) return;
    if (response.confirmedNoSquad && response.squad == null) {
      session.markConfirmedNoSquad();
    } else if (response.squad != null) {
      session.setSquad(response.squad);
    }
    setState(() {
      _squad = response.squad ?? cached;
      _confirmedNoSquad = response.confirmedNoSquad && response.squad == null;
      _loadingSquad = false;
    });
  }

  bool _canUpload(SessionManager session) => hasActiveSquad(session);

  String? _uploadSquadId(SessionManager session) => _squad?.id ?? activeSquadId(session);

  Future<ImageSource?> _pickImageSource(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.gallerySharePhotoTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.orange),
                title: Text(l10n.galleryTitle),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded, color: AppColors.orange),
                title: const Text('Camera'),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final session = getIt<SessionManager>();
    final squadId = _uploadSquadId(session);
    if (!_canUpload(session) || squadId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.servicesLockedDesc)),
      );
      return;
    }

    final user = session.currentUser;
    if (user == null) return;

    final cubit = context.read<GalleryCubit>();
    if (cubit.uploadedCountFor(user.id) >= maxGalleryUploadsPerUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.maxUploadsReached)),
      );
      return;
    }

    final source = await _pickImageSource(context);
    if (source == null || !context.mounted) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 55, maxWidth: 960);
    if (picked == null || !context.mounted) return;

    final caption = await _showCaptionDialog(context);
    if (!mounted) return;

    final bytes = await picked.readAsBytes();
    final base64Str = base64Encode(bytes);
    final dataUrl = 'data:image/jpeg;base64,$base64Str';

    await cubit.upload(
      userId: user.id,
      squadId: squadId,
      governorate: user.governorate ?? _squad?.governorate ?? 'Amman',
      url: dataUrl,
      caption: caption?.isNotEmpty == true ? caption : null,
    );
  }

  Future<String?> _showCaptionDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.galleryAddPost),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: l10n.galleryCaptionHint,
                filled: true,
                fillColor: AppColors.grey100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(''),
                    child: Text(l10n.gallerySkipCaption),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BossPrimaryButton(
                    label: l10n.galleryPost,
                    onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionManager>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.galleryTitle),
        actions: const [LanguageToggleButton()],
      ),
      body: BlocConsumer<GalleryCubit, GalleryState>(
        listener: (context, state) {
          if (state.uploadError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizedFailureMessage(l10n, state.uploadError!))),
            );
          }
          if (_wasUploading && !state.isUploading && state.uploadError == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.galleryPostSuccess)),
            );
          }
          _wasUploading = state.isUploading;
        },
        builder: (context, state) {
          final uploadedCount = session.currentUser == null ? 0 : context.read<GalleryCubit>().uploadedCountFor(session.currentUser!.id);
          final canUpload = _canUpload(session);
          final squadName = _squad?.name;

          if (_loadingSquad) {
            return const Center(child: CircularProgressIndicator(color: AppColors.orange));
          }

          return RefreshIndicator(
            color: AppColors.orange,
            onRefresh: () async {
              await _loadSquad();
              await context.read<GalleryCubit>().load();
            },
            child: state.isLoading && state.feed == null
                ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
                : CustomScrollView(
                        slivers: [
                          if (state.error != null)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                                child: AppErrorView(
                                  failure: state.error!,
                                  onRetry: () => context.read<GalleryCubit>().load(),
                                ),
                              ),
                            ),
                          if (_confirmedNoSquad)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                                child: SquadRequiredPanel(
                                  l10n: l10n,
                                  title: l10n.servicesLockedTitle,
                                  description: l10n.noSquadBrowseGalleryHint,
                                ),
                              ),
                            ),
                          if (canUpload)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                                child: _GalleryShareCard(
                                  l10n: l10n,
                                  squadName: squadName ?? session.currentUser?.squadId ?? l10n.mySquadTitle,
                                  isUploading: state.isUploading,
                                  onSharePhoto: () => _pickAndUpload(context),
                                ),
                              ),
                            ),
                          SliverToBoxAdapter(
                            child: _GalleryGridHeader(
                              uploadedCount: uploadedCount,
                              l10n: l10n,
                              canUpload: canUpload,
                              squadName: squadName,
                            ),
                          ),
                          if ((state.feed?.items ?? const []).isEmpty && state.error == null)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    canUpload ? l10n.galleryEmptyCanPost : l10n.noPhotosYet,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: AppColors.grey600, height: 1.4),
                                  ),
                                ),
                              ),
                            )
                          else if (state.feed != null)
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(16, 16, 16, canUpload ? 16 : 24),
                              sliver: SliverList.separated(
                                itemCount: state.feed!.items.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final item = state.feed!.items[index];
                                  if (item.isAnnouncement) {
                                    return _GalleryAnnouncementCard(item: item);
                                  }
                                  return _GalleryPostCard(item: item);
                                },
                              ),
                            ),
                        ],
                      ),
          );
        },
      ),
    );
  }
}

class _GalleryShareCard extends StatelessWidget {
  const _GalleryShareCard({
    required this.l10n,
    required this.squadName,
    required this.isUploading,
    required this.onSharePhoto,
  });

  final AppLocalizations l10n;
  final String squadName;
  final bool isUploading;
  final VoidCallback onSharePhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.orange, Color(0xFFFF8A50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.add_a_photo_rounded, color: AppColors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.gallerySharePhotoTitle,
                  style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.gallerySharePhotoDesc(squadName),
            style: const TextStyle(color: AppColors.white, height: 1.4, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isUploading ? null : onSharePhoto,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.orange,
              ),
              child: isUploading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.orange),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.ios_share_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.gallerySharePhotoButton),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryGridHeader extends StatelessWidget {
  const _GalleryGridHeader({
    required this.uploadedCount,
    required this.l10n,
    required this.canUpload,
    this.squadName,
  });

  final int uploadedCount;
  final AppLocalizations l10n;
  final bool canUpload;
  final String? squadName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.fieldMoments, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          if (canUpload && squadName != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.groups_rounded, size: 16, color: AppColors.orange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.gallerySquadBanner(squadName!),
                    style: const TextStyle(color: AppColors.orange, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Text(
            canUpload ? l10n.galleryUploadHint : l10n.noSquadBrowseGalleryHint,
            style: const TextStyle(color: AppColors.grey600, fontSize: 13, height: 1.35),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.uploadedCount(uploadedCount, maxGalleryUploadsPerUser),
            style: const TextStyle(color: AppColors.grey600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _GalleryAnnouncementCard extends StatefulWidget {
  const _GalleryAnnouncementCard({required this.item});

  final GalleryItem item;

  @override
  State<_GalleryAnnouncementCard> createState() => _GalleryAnnouncementCardState();
}

class _GalleryAnnouncementCardState extends State<_GalleryAnnouncementCard> {
  @override
  void initState() {
    super.initState();
    final userId = getIt<SessionManager>().currentUser?.id;
    final notificationId = widget.item.notificationId;
    if (userId != null && notificationId != null && notificationId.isNotEmpty) {
      context.read<GalleryCubit>().markAnnouncementRead(notificationId, userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final targetRoute = resolveNotificationRoute(item.route);

    return InkWell(
      onTap: targetRoute == '/gallery' ? null : () => context.go(targetRoute),
      borderRadius: BorderRadius.circular(16),
      child: Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.orange, Color(0xFFFF8A50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: const Text('B', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('the Boss', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w800)),
                ),
                const Icon(Icons.campaign_rounded, color: AppColors.white, size: 20),
              ],
            ),
          ),
          if (item.url.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _GalleryImage(item: item),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title ?? 'Announcement',
                  style: const TextStyle(color: AppColors.white, fontSize: 17, fontWeight: FontWeight.w800),
                ),
                if (item.caption != null && item.caption!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.caption!,
                    style: const TextStyle(color: AppColors.white, height: 1.45, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _GalleryPostCard extends StatelessWidget {
  const _GalleryPostCard({required this.item});

  final GalleryItem item;

  Future<void> _sharePost(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final text = item.caption?.trim().isNotEmpty == true ? item.caption!.trim() : l10n.galleryShareDefault;
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.galleryShareCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
        boxShadow: const [BoxShadow(color: Color(0x0F1A1A1A), blurRadius: 8, offset: Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: _GalleryImage(item: item),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: item.caption != null && item.caption!.isNotEmpty
                      ? Text(item.caption!, style: const TextStyle(height: 1.4, fontSize: 14))
                      : Text(
                          l10n.galleryShareDefault,
                          style: const TextStyle(height: 1.4, fontSize: 13, color: AppColors.grey600, fontStyle: FontStyle.italic),
                        ),
                ),
                IconButton(
                  tooltip: l10n.gallerySharePost,
                  onPressed: () => _sharePost(context),
                  icon: const Icon(Icons.share_rounded, color: AppColors.orange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryImage extends StatelessWidget {
  const _GalleryImage({required this.item});

  final GalleryItem item;

  @override
  Widget build(BuildContext context) {
    if (item.url.startsWith('data:image')) {
      try {
        final base64Part = item.url.split(',').last;
        return Image.memory(base64Decode(base64Part), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder());
      } catch (_) {
        return _placeholder();
      }
    }
    if (item.url.startsWith('http')) {
      return Image.network(item.url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder());
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.grey100,
      alignment: Alignment.center,
      child: const Icon(Icons.photo_rounded, color: AppColors.grey400, size: 32),
    );
  }
}

