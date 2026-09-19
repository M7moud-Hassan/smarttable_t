class AppUpdateInfo {
  const AppUpdateInfo({
    required this.isUpdateAvailable,
    required this.isRequired,
    this.storeUrl,
    this.message,
  });

  final bool isUpdateAvailable;
  final bool isRequired;
  final String? storeUrl;
  final String? message;

  factory AppUpdateInfo.fromResponse(
    dynamic response, {
    required String currentVersion,
    required String currentBuild,
    String? serverMessage,
  }) {
    final data = _flattenResponse(response);
    final explicitUpdate = response is bool
        ? response
        : _firstBool(data, const [
            'update_available',
            'is_update_available',
            'has_update',
            'should_update',
            'need_update',
            'needs_update',
            'is_update',
            'update',
            'available',
          ]);
    final explicitRequiredUpdate = _firstBool(data, const [
      'update_required',
      'requires_update',
      'required_update',
      'is_update_required',
      'force_update',
      'forced_update',
      'mandatory',
      'is_mandatory',
      'is_required',
    ]);
    final minimumVersion = _firstString(data, const [
      'minimum_version',
      'min_version',
      'minimum_build',
      'min_build',
    ]);
    final inferredRequiredUpdate = _isBelowMinimum(
          minimumVersion,
          currentVersion: currentVersion,
          currentBuild: currentBuild,
        ) ||
        _isRequiredMode(data);
    final requiredUpdate = explicitRequiredUpdate ?? inferredRequiredUpdate;

    final latestVersion = _firstString(data, const [
      'latest_version',
      'new_version',
      'current_version',
      'version',
    ]);
    final latestBuild = _firstString(data, const [
      'latest_build',
      'new_build',
      'build_number',
      'build',
    ]);
    final newerVersion = latestVersion != null &&
        _compareVersions(latestVersion, currentVersion) > 0;
    final newerBuild = latestBuild != null &&
        (int.tryParse(latestBuild) ?? -1) > (int.tryParse(currentBuild) ?? -1);

    return AppUpdateInfo(
      isUpdateAvailable:
          requiredUpdate || (explicitUpdate ?? (newerVersion || newerBuild)),
      isRequired: requiredUpdate,
      storeUrl: _firstString(data, const [
        'store_url',
        'store_link',
        'download_url',
        'update_url',
        'market_url',
        'play_store_url',
        'google_play_url',
        'app_store_url',
        'apple_store_url',
        'url',
      ]),
      message: _firstString(data, const [
            'update_message',
            'message',
            'release_notes',
            'description',
          ]) ??
          serverMessage,
    );
  }

  AppUpdateInfo withFallbackStoreUrl(String url) {
    return AppUpdateInfo(
      isUpdateAvailable: isUpdateAvailable,
      isRequired: isRequired,
      storeUrl: storeUrl ?? url,
      message: message,
    );
  }

  static Map<String, dynamic> _flattenResponse(dynamic response) {
    final flattened = <String, dynamic>{};

    void visit(dynamic value) {
      if (value is Map) {
        for (final entry in value.entries) {
          final key = entry.key.toString().toLowerCase();
          flattened.putIfAbsent(key, () => entry.value);
          if (entry.value is Map || entry.value is Iterable) {
            visit(entry.value);
          }
        }
      } else if (value is Iterable) {
        for (final item in value) {
          visit(item);
        }
      }
    }

    visit(response);
    return flattened;
  }

  static bool? _firstBool(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        switch (value.trim().toLowerCase()) {
          case 'true':
          case '1':
          case 'yes':
            return true;
          case 'false':
          case '0':
          case 'no':
            return false;
        }
      }
    }
    return null;
  }

  static String? _firstString(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is num) return value.toString();
    }
    return null;
  }

  static bool _isRequiredMode(Map<String, dynamic> data) {
    final mode = _firstString(data, const [
      'update_type',
      'update_mode',
      'type',
    ])?.toLowerCase();
    return const {'force', 'forced', 'mandatory', 'required'}.contains(mode);
  }

  static bool _isBelowMinimum(
    String? minimumVersion, {
    required String currentVersion,
    required String currentBuild,
  }) {
    if (minimumVersion == null) return false;

    if (minimumVersion.contains('.')) {
      return _compareVersions(currentVersion, minimumVersion) < 0;
    }

    final minimumBuild = int.tryParse(minimumVersion);
    final installedBuild = int.tryParse(currentBuild);
    return minimumBuild != null &&
        installedBuild != null &&
        installedBuild < minimumBuild;
  }

  static int _compareVersions(String left, String right) {
    final leftParts = _numericVersionParts(left);
    final rightParts = _numericVersionParts(right);
    final length = leftParts.length > rightParts.length
        ? leftParts.length
        : rightParts.length;

    for (var index = 0; index < length; index++) {
      final leftPart = index < leftParts.length ? leftParts[index] : 0;
      final rightPart = index < rightParts.length ? rightParts[index] : 0;
      if (leftPart != rightPart) return leftPart.compareTo(rightPart);
    }
    return 0;
  }

  static List<int> _numericVersionParts(String version) {
    return version
        .split(RegExp(r'[^0-9]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
  }
}
