import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DateFormat ar without initializeDateFormatting throws', () {
    expect(
      () => DateFormat.yMMMd('ar').add_jm().format(DateTime.now()),
      throwsException,
    );
  });

  test('DateFormat ar works after initializeDateFormatting', () async {
    await initializeDateFormatting('ar');
    final formatted = DateFormat.yMMMd('ar').add_jm().format(DateTime(2026, 8, 6, 14, 30));
    expect(formatted, isNotEmpty);
  });
}
