import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_info.dart';

/// Result of a GitHub release update check.
class UpdateInfo {
  final String latestVersion;
  final String releaseNotes;
  final String? apkUrl;
  final String releaseUrl;
  final bool hasUpdate;

  const UpdateInfo({
    required this.latestVersion,
    required this.releaseNotes,
    this.apkUrl,
    required this.releaseUrl,
    required this.hasUpdate,
  });
}

/// Checks for app updates by querying the GitHub releases API.
class UpdateService {
  UpdateService._();

  /// GitHub owner and repository that hosts the releases.
  static const String _owner = 'proabusaleh';
  static const String _repo = 'calculatorplus';

  static const Duration _timeout = Duration(seconds: 12);

  static String get repoUrl => 'https://github.com/$_owner/$_repo';

  /// Fetches the latest release and compares it with the installed version.
  ///
  /// Returns [UpdateInfo] even on failure, so callers can decide how to react.
  static Future<UpdateInfo> checkForUpdate() async {
    return _fetchLatestRelease();
  }

  static Future<UpdateInfo> _fetchLatestRelease() async {
    final uri = Uri.parse(
        'https://api.github.com/repos/$_owner/$_repo/releases/latest');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'CalculatorPlus/${AppInfo.version}',
        },
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        return _noUpdate();
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = (json['tag_name'] as String? ?? '').trim();
      final latestVersion = tagName.replaceFirst(RegExp(r'^v'), '');
      final releaseNotes = (json['body'] as String? ?? '').trim();
      final htmlUrl = (json['html_url'] as String? ?? repoUrl);

      // Find the APK asset from the release assets.
      String? apkUrl;
      final assets = json['assets'] as List<dynamic>? ?? const [];
      for (final asset in assets) {
        final map = asset is Map<String, dynamic> ? asset : const <String, dynamic>{};
        final name = (map['name'] as String? ?? '').toLowerCase();
        final downloadUrl = map['browser_download_url'] as String?;
        if (downloadUrl != null && name.endsWith('.apk')) {
          apkUrl = downloadUrl;
          break;
        }
      }

      final hasUpdate = latestVersion.isNotEmpty &&
          latestVersion != AppInfo.version &&
          _compareVersions(latestVersion, AppInfo.version) > 0;

      return UpdateInfo(
        latestVersion: latestVersion,
        releaseNotes: releaseNotes,
        apkUrl: apkUrl,
        releaseUrl: htmlUrl,
        hasUpdate: hasUpdate,
      );
    } catch (_) {
      return _noUpdate();
    }
  }

  static UpdateInfo _noUpdate() => const UpdateInfo(
        latestVersion: '',
        releaseNotes: '',
        apkUrl: null,
        releaseUrl: '',
        hasUpdate: false,
      );

  /// Compares two dotted version strings.
  /// Returns >0 if [a] is newer than [b], 0 if equal, <0 otherwise.
  static int _compareVersions(String a, String b) {
    final aParts = a.split('.').map(int.tryParse).toList();
    final bParts = b.split('.').map(int.tryParse).toList();

    final len = aParts.length > bParts.length ? aParts.length : bParts.length;
    for (var i = 0; i < len; i++) {
      final av = i < aParts.length ? (aParts[i] ?? 0) : 0;
      final bv = i < bParts.length ? (bParts[i] ?? 0) : 0;
      if (av != bv) return av - bv;
    }
    return 0;
  }
}
