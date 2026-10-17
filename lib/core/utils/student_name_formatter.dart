String compactStudentName(String fullName) {
  final words = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  final wordLimit = words.take(2).contains('عبد') ? 3 : 2;
  return words.take(wordLimit).join(' ');
}
