import 'package:flutter/material.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';

class BossLogo extends StatelessWidget {
  const BossLogo({
    super.key,
    this.showTagline = true,
    this.align = TextAlign.start,
  });

  final bool showTagline;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align == TextAlign.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: AppTextStyles.logo,
            children: [
              const TextSpan(text: 'the '),
              const TextSpan(text: 'B'),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                  ),
                ),
              ),
              const TextSpan(text: 'SS'),
            ],
          ),
          textAlign: align,
        ),
        if (showTagline) ...[
          const SizedBox(height: 10),
          Text(
            'Bring our squads to society.',
            style: AppTextStyles.tagline,
            textAlign: align,
          ),
        ],
      ],
    );
  }
}
