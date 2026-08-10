import 'package:flutter/material.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';

const kBossScreenPadding = EdgeInsets.fromLTRB(20, 20, 20, 28);

class BossScreenPad extends StatelessWidget {
  const BossScreenPad({super.key, required this.child, this.padding = kBossScreenPadding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: padding,
        child: child,
      ),
    );
  }
}

class BossTopBar extends StatelessWidget {
  const BossTopBar({super.key, this.onBack, this.trailing});

  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 22),
              color: AppColors.ink,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            )
          else
            const SizedBox(width: 8),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class BossStepBar extends StatelessWidget {
  const BossStepBar({super.key, required this.currentStep, this.totalSteps = 3});

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final step = index + 1;
        Color color;
        if (step < currentStep) {
          color = AppColors.success;
        } else if (step == currentStep) {
          color = AppColors.orange;
        } else {
          color = const Color(0xFFDCDCDC);
        }
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 6 : 0),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          ),
        );
      }),
    );
  }
}

class BossStepTag extends StatelessWidget {
  const BossStepTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class BossCard extends StatelessWidget {
  const BossCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderColor,
    this.backgroundColor,
    this.onTap,
    this.borderWidth = 1,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor ?? AppColors.grey200, width: borderWidth),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: card),
    );
  }
}

class BossField extends StatelessWidget {
  const BossField({
    super.key,
    required this.child,
    this.leading,
    this.label,
    this.backgroundColor,
    this.enabled = true,
  });

  final Widget child;
  final Widget? leading;
  final String? label;
  final Color? backgroundColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 10)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (label != null)
                  Text(label!, style: const TextStyle(fontSize: 11, color: AppColors.grey600)),
                if (label != null) const SizedBox(height: 2),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 15,
                    color: enabled ? AppColors.ink : AppColors.grey600,
                    fontWeight: FontWeight.w500,
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BossChipRow extends StatelessWidget {
  const BossChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((option) {
        final isOn = selected == option;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: option != options.last ? 8 : 0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(option),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isOn ? AppColors.ink : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isOn ? AppColors.ink : AppColors.grey200, width: 1.5),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isOn ? AppColors.orange : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class BossWrapChips extends StatelessWidget {
  const BossWrapChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: options.map((option) {
        final isOn = selected.contains(option);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onToggle(option),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isOn ? AppColors.ink : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isOn ? AppColors.ink : AppColors.grey200, width: 1.5),
              ),
              child: Text(
                option,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isOn ? AppColors.orange : AppColors.ink,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class BossProgressBar extends StatelessWidget {
  const BossProgressBar({super.key, required this.progress, this.color = AppColors.success, this.height = 9});

  final double progress;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: progress.clamp(0, 1),
        minHeight: height,
        backgroundColor: const Color(0xFFE7E7E7),
        color: color,
      ),
    );
  }
}

class BossToggle extends StatelessWidget {
  const BossToggle({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46,
        height: 27,
        decoration: BoxDecoration(
          color: value ? AppColors.success : const Color(0xFFCFCFCF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 21,
            height: 21,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class BossBottomNav extends StatelessWidget {
  const BossBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BossNavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.grey200)),
      ),
      padding: EdgeInsets.fromLTRB(8, 10, 8, 14 + MediaQuery.paddingOf(context).bottom),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final selected = index == currentIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: selected ? const EdgeInsets.symmetric(horizontal: 14, vertical: 3) : EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.orange : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, size: 19, color: selected ? AppColors.white : const Color(0xFFA5A5A5)),
                      ),
                      if (item.badgeCount > 0)
                        Positioned(
                          right: selected ? 2 : -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                            decoration: BoxDecoration(
                              color: AppColors.orange,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.white, width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              item.badgeCount > 9 ? '9+' : '${item.badgeCount}',
                              style: const TextStyle(color: AppColors.white, fontSize: 8, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.ink : const Color(0xFFA5A5A5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class BossNavItem {
  const BossNavItem({required this.icon, required this.label, this.badgeCount = 0});

  final IconData icon;
  final String label;
  final int badgeCount;
}
