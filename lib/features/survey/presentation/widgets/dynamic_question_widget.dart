import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/features/survey/domain/entities/survey.dart';
import 'package:myboss_mobile/features/survey/presentation/widgets/signature_pad.dart';

/// Renders ANY survey question type coming from the backend as dynamic JSON.
/// This is the core of the dynamic survey engine — no question type is
/// hardcoded into the survey flow, only into this single renderer.
class DynamicQuestionWidget extends StatelessWidget {
  const DynamicQuestionWidget({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final SurveyQuestion question;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      key: ValueKey(question.id),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.type != QuestionType.consentCheckbox) ...[
          Text(
            question.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.black, height: 1.3),
          ),
          if (!question.required)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l10n.optional, style: TextStyle(color: AppColors.grey400, fontSize: 13)),
            ),
          if (question.description != null) ...[
            const SizedBox(height: 8),
            Text(question.description!, style: const TextStyle(color: AppColors.grey600, fontSize: 14, height: 1.4)),
          ],
          const SizedBox(height: 28),
        ],
        _buildInput(context, l10n),
        if (errorText != null && errorText!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            errorText!,
            style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }

  Widget _buildInput(BuildContext context, AppLocalizations l10n) {
    switch (question.type) {
      case QuestionType.rating:
        return _RatingInput(value: value, maxStars: (question.validation?['maxStars'] as num?)?.toInt() ?? 5, onChanged: onChanged);
      case QuestionType.nps:
        return _NpsInput(
          value: value,
          min: (question.validation?['min'] as num?)?.toInt() ?? 0,
          max: (question.validation?['max'] as num?)?.toInt() ?? 10,
          notLikelyLabel: l10n.notLikely,
          veryLikelyLabel: l10n.veryLikely,
          onChanged: onChanged,
        );
      case QuestionType.singleChoice:
        return _SingleChoiceInput(options: question.options ?? const [], value: value, onChanged: onChanged);
      case QuestionType.multiChoice:
        return _MultiChoiceInput(options: question.options ?? const [], value: value, onChanged: onChanged);
      case QuestionType.text:
        return _TextInput(
          initialValue: value as String?,
          hint: l10n.typeAnswer,
          maxLines: 5,
          onChanged: onChanged,
        );
      case QuestionType.consentName:
        return _TextInput(
          initialValue: value as String?,
          hint: l10n.fullName,
          onChanged: onChanged,
        );
      case QuestionType.consentNationalId:
        return _TextInput(
          initialValue: value as String?,
          hint: '99xxxxxxxx',
          keyboardType: TextInputType.number,
          maxLength: (question.validation?['maxLength'] as num?)?.toInt() ?? 10,
          digitsOnly: true,
          onChanged: onChanged,
        );
      case QuestionType.consentPhone:
        return _TextInput(
          initialValue: value as String?,
          hint: (question.validation?['pattern'] as String?) ?? '+962 77 XXX XXXX',
          keyboardType: TextInputType.phone,
          onChanged: onChanged,
        );
      case QuestionType.consentCheckbox:
        return _ConsentCheckboxInput(title: question.title, value: value as bool? ?? false, onChanged: onChanged);
      case QuestionType.signature:
        return SignaturePad(onChanged: onChanged);
      default:
        return Text('Unsupported question type: ${question.type}', style: const TextStyle(color: AppColors.error));
    }
  }
}

class _RatingInput extends StatelessWidget {
  const _RatingInput({required this.value, required this.maxStars, required this.onChanged});

  final dynamic value;
  final int maxStars;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = (value as num?)?.toInt() ?? 0;
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        children: List.generate(maxStars, (index) {
          final starValue = index + 1;
          final filled = starValue <= current;
          return GestureDetector(
            onTap: () => onChanged(starValue),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              color: AppColors.orange,
              size: 44,
            ),
          );
        }),
      ),
    );
  }
}

class _NpsInput extends StatelessWidget {
  const _NpsInput({
    required this.value,
    required this.min,
    required this.max,
    required this.notLikelyLabel,
    required this.veryLikelyLabel,
    required this.onChanged,
  });

  final dynamic value;
  final int min;
  final int max;
  final String notLikelyLabel;
  final String veryLikelyLabel;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = (value as num?)?.toInt();
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(max - min + 1, (i) {
            final score = min + i;
            final selected = current == score;
            return GestureDetector(
              onTap: () => onChanged(score),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.orange : AppColors.grey100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: selected ? AppColors.orange : AppColors.grey200),
                ),
                child: Text(
                  '$score',
                  style: TextStyle(
                    color: selected ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(notLikelyLabel, style: const TextStyle(color: AppColors.grey400, fontSize: 12)),
              Text(veryLikelyLabel, style: const TextStyle(color: AppColors.grey400, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SingleChoiceInput extends StatelessWidget {
  const _SingleChoiceInput({required this.options, required this.value, required this.onChanged});

  final List<QuestionOption> options;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        final selected = value == option.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ChoiceTile(
            label: option.label,
            selected: selected,
            leadingIcon: selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
            onTap: () => onChanged(option.id),
          ),
        );
      }).toList(),
    );
  }
}

class _MultiChoiceInput extends StatelessWidget {
  const _MultiChoiceInput({required this.options, required this.value, required this.onChanged});

  final List<QuestionOption> options;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedIds = (value as List?)?.cast<String>() ?? const <String>[];
    return Column(
      children: options.map((option) {
        final selected = selectedIds.contains(option.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ChoiceTile(
            label: option.label,
            selected: selected,
            leadingIcon: selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
            onTap: () {
              final updated = List<String>.from(selectedIds);
              if (selected) {
                updated.remove(option.id);
              } else {
                updated.add(option.id);
              }
              onChanged(updated);
            },
          ),
        );
      }).toList(),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.leadingIcon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final IconData leadingIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.orangeLight : AppColors.grey100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.orange : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(leadingIcon, color: selected ? AppColors.orange : AppColors.grey400),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextInput extends StatefulWidget {
  const _TextInput({
    required this.initialValue,
    required this.onChanged,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.maxLength,
    this.digitsOnly = false,
    this.autofocus = true,
  });

  final String? initialValue;
  final ValueChanged<dynamic> onChanged;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool digitsOnly;
  final bool autofocus;

  @override
  State<_TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<_TextInput> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialValue);
  late final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textInputAction: TextInputAction.done,
      inputFormatters: widget.digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: const TextStyle(fontSize: 16, color: AppColors.black),
      decoration: InputDecoration(hintText: widget.hint),
      onChanged: widget.onChanged,
      onTap: () => _focusNode.requestFocus(),
    );
  }
}

class _ConsentCheckboxInput extends StatelessWidget {
  const _ConsentCheckboxInput({required this.title, required this.value, required this.onChanged});

  final String title;
  final bool value;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value ? AppColors.orangeLight : AppColors.grey100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: value ? AppColors.orange : Colors.transparent, width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              activeColor: AppColors.orange,
              onChanged: (v) => onChanged(v ?? false),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(title, style: const TextStyle(fontSize: 15, height: 1.4, color: AppColors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
