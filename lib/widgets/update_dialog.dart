import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_info.dart';
import '../services/update_service.dart';
import '../theme/app_theme.dart';

/// Shows the "App update available" dialog with Update / Later options.
class UpdateDialog {
  UpdateDialog._();

  /// Shows the update prompt if [info] indicates an update is available.
  /// Returns `true` if there was an update to show.
  static Future<bool> maybeShow(BuildContext context, UpdateInfo info) async {
    if (!info.hasUpdate) return false;

    if (!context.mounted) return false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _UpdatePrompt(info: info),
    );
    return true;
  }

  /// Opens the APK download URL, or falls back to the release page.
  static Future<void> openUpdate(UpdateInfo info) async {
    var target = info.apkUrl ?? info.releaseUrl;
    if (target.isEmpty) return;
    final uri = Uri.parse(target);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _UpdatePrompt extends StatelessWidget {
  final UpdateInfo info;
  const _UpdatePrompt({required this.info});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppTheme.surface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.glow(AppTheme.electricBlue, radius: 20),
              ),
              child: const Icon(
                Icons.system_update_alt_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Update Available',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'A new version (${info.latestVersion}) is available.\nYour app is on ${AppInfo.displayVersion}.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            if (info.releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  info.releaseNotes,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.5,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppTheme.electricBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  UpdateDialog.openUpdate(info);
                },
                child: Text(
                  'Update Now',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Later',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
