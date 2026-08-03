import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';

class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.initialCode,
    this.enabled = true,
    this.length = 6,
    this.autoSubmit = true,
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final String? initialCode;
  final bool enabled;
  final int length;
  final bool autoSubmit;

  @override
  State<OtpInput> createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    final code = _normalizeCode(widget.initialCode);
    if (code != null) {
      _applyCodeToControllers(code);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onChanged?.call(code);
        if (widget.autoSubmit) _complete(code);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNodes.first.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant OtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final code = _normalizeCode(widget.initialCode);
    final oldCode = _normalizeCode(oldWidget.initialCode);
    if (code != null && code != oldCode) {
      refill(code);
    }
  }

  String? _normalizeCode(String? raw) {
    final digits = raw?.replaceAll(RegExp(r'\D'), '');
    if (digits == null || digits.length != widget.length) return null;
    return digits;
  }

  void _applyCodeToControllers(String code) {
    for (var i = 0; i < widget.length; i++) {
      _controllers[i].text = code[i];
    }
  }

  void allowRetry() {
    _completed = false;
  }

  void reset() {
    _completed = false;
    for (final controller in _controllers) {
      controller.clear();
    }
    setState(() {});
  }

  void refill(String code) {
    final digits = _normalizeCode(code);
    if (digits == null) return;

    _completed = false;
    _applyCodeToControllers(digits);
    setState(() {});
    _focusNodes.last.unfocus();
  }

  void fillCode(String code) {
    final digits = _normalizeCode(code);
    if (digits == null || _completed) return;

    _applyCodeToControllers(digits);
    setState(() {});
    _focusNodes.last.unfocus();
    widget.onChanged?.call(digits);
    if (widget.autoSubmit) _complete(digits);
  }

  void _complete(String code) {
    if (_completed || !widget.autoSubmit) {
      widget.onChanged?.call(code);
      return;
    }
    _completed = true;
    widget.onCompleted(code);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _submitIfComplete() {
    final code = currentCode;
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      _focusNodes.last.unfocus();
      if (widget.autoSubmit) {
        _complete(code);
      }
    }
  }

  void _notifyChange() {
    widget.onChanged?.call(currentCode);
  }

  String get currentCode => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 1) {
      fillCode(digits.substring(0, widget.length));
      return;
    }

    if (digits.isEmpty) {
      _controllers[index].clear();
      setState(() {});
      _notifyChange();
      return;
    }

    _controllers[index].text = digits;
    setState(() {});
    _notifyChange();

    if (index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _submitIfComplete();
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // OTP digits must always read left-to-right, even in Arabic/RTL mode.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AutofillGroup(
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(widget.length, (index) {
          final hasValue = _controllers[index].text.isNotEmpty;

          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: index < widget.length - 1 ? 8 : 0,
              ),
              child: SizedBox(
                height: 60,
                child: Focus(
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.backspace) {
                      _onBackspace(index);
                    }
                    return KeyEventResult.ignored;
                  },
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    enabled: widget.enabled,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    textInputAction: index == widget.length - 1
                        ? TextInputAction.done
                        : TextInputAction.next,
                    maxLength: 1,
                    autocorrect: false,
                    enableSuggestions: false,
                    smartDashesType: SmartDashesType.disabled,
                    smartQuotesType: SmartQuotesType.disabled,
                    autofillHints: const <String>[],
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      height: 1,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: hasValue ? AppColors.white : AppColors.grey100,
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: hasValue ? AppColors.orange : AppColors.grey200,
                          width: 1.5,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.grey200, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.orange, width: 2),
                      ),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => _onChanged(index, value),
                    onTap: () => _controllers[index].selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _controllers[index].text.length,
                    ),
                    onSubmitted: (_) {
                      if (index < widget.length - 1) {
                        _focusNodes[index + 1].requestFocus();
                      } else {
                        _submitIfComplete();
                      }
                    },
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ),
    );
  }
}
