final class PaginationModel<T> {
  late final int count;
  late final int currentPage;
  late final String? next;
  late final bool isLastPage;
  late final List<T> list;

  void setData({
    required Object? map,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    final Map<String, dynamic>? page =
        map is Map ? Map<String, dynamic>.from(map) : null;
    final Object? rawResults = map is List ? map : page?['results'];

    if (rawResults is! List) {
      throw const FormatException('Invalid pagination response');
    }

    final data = rawResults
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    count = page?['count'] is int ? page!['count'] as int : data.length;
    next = page?['next']?.toString();
    currentPage = next == null ? 1 : getCurrentPage(next ?? '');
    isLastPage = next == null;
    list = List<T>.from(data.map(fromJson));
  }

  int getCurrentPage(String url) {
    final uri = Uri.parse(url);

    // Get the 'page' query parameter
    final page = uri.queryParameters['page'];

    // Convert to int (default to 1 if null or invalid)
    final currentPage = int.tryParse(page ?? '1') ?? 1;

    return currentPage == 1 ? 1 : currentPage - 1;
  }
}
