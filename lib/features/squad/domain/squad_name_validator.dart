/// Shared squad-name rules for create-squad (client + matches backend).
class SquadNameValidator {
  const SquadNameValidator._();

  static const maxLength = 100;
  static const minLength = 2;

  static String normalize(String raw) => raw
      .replaceAll(RegExp(r'[\u200B-\u200F\u202A-\u202E\u2060-\u206F\uFEFF]'), '')
      .replaceAll(RegExp(r'[\u00A0\u202F\u2007]'), ' ')
      .replaceAll(RegExp(r'[\u2018\u2019\u2032]'), "'")
      .replaceAll(RegExp(r'[\u2013\u2014\u2212]'), '-')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');

  /// Returns a stable error code, or null when valid.
  static String? validate(String raw) {
    final name = normalize(raw);
    if (name.isEmpty) return 'SQUAD_NAME_EMPTY';
    if (name.length < minLength) return 'SQUAD_NAME_TOO_SHORT';
    if (name.length > maxLength) return 'SQUAD_NAME_TOO_LONG';
    return null;
  }
}
