import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TawkWebView extends StatefulWidget {
  const TawkWebView({super.key, required this.html});

  final String html;

  @override
  State<TawkWebView> createState() => _TawkWebViewState();
}

class _TawkWebViewState extends State<TawkWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..loadHtmlString(widget.html, baseUrl: 'https://embed.tawk.to');
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
