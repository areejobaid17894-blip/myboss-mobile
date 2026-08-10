import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myboss_mobile/core/config/env_config.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/utils/image_url_resolver.dart';

/// Renders a remote or data-URI image with a consistent placeholder fallback.
class RemoteImageUrl extends StatelessWidget {
  const RemoteImageUrl({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  String get _resolvedUrl {
    if (!getIt.isRegistered<EnvConfig>()) return url.trim();
    final gatewayOrigin = Uri.parse(getIt<EnvConfig>().authBaseUrl).origin;
    return resolveNotificationImageUrl(url, gatewayOrigin);
  }

  bool get _hasImage => _resolvedUrl.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final resolved = _resolvedUrl;
    final child = !_hasImage
        ? _placeholder()
        : resolved.startsWith('data:image')
            ? _dataImage(resolved)
            : resolved.startsWith('http')
                ? Image.network(
                    resolved,
                    fit: fit,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder();

    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  Widget _dataImage(String resolved) {
    try {
      final base64Part = resolved.split(',').last;
      return Image.memory(
        base64Decode(base64Part),
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } catch (_) {
      return _placeholder();
    }
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.grey100,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: AppColors.grey400, size: 36),
    );
  }
}
