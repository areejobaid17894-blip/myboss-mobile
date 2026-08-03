class OtpRouteArgs {
  const OtpRouteArgs({
    required this.sessionId,
    required this.email,
    this.demoOtpCode,
  });

  final String sessionId;
  final String email;
  final String? demoOtpCode;
}
