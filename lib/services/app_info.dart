import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  AppInfo._();

  static String _appName = 'Calculator Plus';
  static String _packageName = '';
  static String _version = '';
  static String _buildNumber = '';

  static String get appName => _appName;
  static String get packageName => _packageName;
  static String get version => _version;
  static String get buildNumber => _buildNumber;
  static String get displayVersion => 'v$_version+$_buildNumber';

  static Future<void> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _appName = info.appName;
      _packageName = info.packageName;
      _version = info.version;
      _buildNumber = info.buildNumber;
    } catch (_) {
      // Falls back to static defaults if platform channel fails
    }
  }
}
