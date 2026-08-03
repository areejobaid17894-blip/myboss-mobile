import 'package:flutter/material.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_design_widgets.dart';

enum BossButtonVariant { brand, ink, outline, ghostDanger }

class BossPrimaryButton extends StatelessWidget {
  const BossPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = BossButtonVariant.brand,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final BossButtonVariant variant;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      BossButtonVariant.brand => (AppColors.orange, AppColors.white, AppColors.orange),
      BossButtonVariant.ink => (AppColors.ink, AppColors.white, AppColors.ink),
      BossButtonVariant.outline => (Colors.transparent, AppColors.ink, AppColors.ink),
      BossButtonVariant.ghostDanger => (Colors.transparent, AppColors.error, AppColors.error),
    };

    return SizedBox(
      width: compact ? null : double.infinity,
      height: compact ? 36 : 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.35),
          disabledForegroundColor: fg.withValues(alpha: 0.8),
          elevation: 0,
          padding: compact ? const EdgeInsets.symmetric(horizontal: 14) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(compact ? 10 : 14),
            side: BorderSide(color: border, width: variant == BossButtonVariant.outline || variant == BossButtonVariant.ghostDanger ? 1.5 : 0),
          ),
          textStyle: TextStyle(fontSize: compact ? 12 : 15, fontWeight: FontWeight.w700),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
                children: [
                  Text(label),
                  if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 18)],
                ],
              ),
      ),
    );
  }
}

class BossEmailField extends StatelessWidget {
  const BossEmailField({
    super.key,
    required this.controller,
    this.errorText,
    this.enabled = true,
    this.hintText = 'name@company.com',
    this.autofocus = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? errorText;
  final bool enabled;
  final String hintText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BossField(
          leading: const Text('✉️', style: TextStyle(fontSize: 18)),
          child: TextField(
            controller: controller,
            enabled: enabled,
            autofocus: autofocus,
            onChanged: onChanged,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColors.grey600, fontSize: 15),
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(fontSize: 15, color: AppColors.ink),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(errorText!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
        ],
      ],
    );
  }
}
