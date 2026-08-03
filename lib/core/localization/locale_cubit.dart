import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/error/failure_message_mapper.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/storage/secure_storage_service.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._storage) : super(const Locale('ar'));

  final SecureStorageService _storage;

  Future<void> loadSavedLocale() async {
    final code = await _storage.getLocale();
    if (code == 'en' || code == 'ar') {
      emit(Locale(code!));
    }
  }

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    await _storage.saveLocale(locale.languageCode);
  }

  Future<void> toggle() async {
    final next = state.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    await setLocale(next);
  }
}

/// Reusable inline error panel for feature screens.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.failure,
    this.onRetry,
  });

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = localizedFailureMessage(l10n, failure);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error, fontSize: 15, height: 1.4),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(onPressed: onRetry, child: Text(l10n.retry)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Language toggle chip for app bars / profile.
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final label = locale.languageCode == 'ar' ? 'EN' : 'ع';
        return TextButton(
          onPressed: () => context.read<LocaleCubit>().toggle(),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        );
      },
    );
  }
}

/// RTL-aware chevron for list tiles.
class BossChevronIcon extends StatelessWidget {
  const BossChevronIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.chevron_right_rounded, color: AppColors.grey400, textDirection: Directionality.of(context));
  }
}
