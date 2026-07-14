/// Inserts a thin space every 3 digits from the right — e.g. `2140` →
/// `'2 140'` (matches the prototype's number formatting for XP/scores).
String formatThousands(int value) {
  final bool negative = value < 0;
  final String digits = value.abs().toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return negative ? '-$buffer' : buffer.toString();
}
