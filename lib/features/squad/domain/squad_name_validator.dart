/// Shared squad-name rules for create-squad (client + matches backend intent).
class SquadNameValidator {
  const SquadNameValidator._();

  static const maxLength = 100;
  static const minLength = 2;

  /// Letters (Latin + Arabic) and single spaces between words only.
  static final RegExp _allowedName = RegExp(
    r'^[A-Za-z\u0600-\u06FF]+(?: [A-Za-z\u0600-\u06FF]+)*$',
  );

  static String normalize(String raw) =>
      raw.trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Returns a stable error code, or null when valid.
  static String? validate(String raw) {
    final name = normalize(raw);
    if (name.isEmpty) return 'SQUAD_NAME_EMPTY';
    if (name.length < minLength) return 'SQUAD_NAME_TOO_SHORT';
    if (name.length > maxLength) return 'SQUAD_NAME_TOO_LONG';
    if (!_allowedName.hasMatch(name)) return 'SQUAD_NAME_INVALID';
    return null;
  }
}
