import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_provider.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class ProfileManagerWidget extends StatelessWidget {
  final SettingsProvider settings;

  const ProfileManagerWidget({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.person_outline_rounded,
                    color: AppTheme.accentGreen, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Profiles',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.add_rounded,
                      color: AppTheme.accentGreen, size: 24),
                  onPressed: () => _showAddDialog(context, isDark),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: settings.profiles.length,
              itemBuilder: (context, i) {
                final profile = settings.profiles[i];
                final isActive = profile.id == settings.activeProfileId;
                return _buildProfileTile(context, profile, isActive, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile(
      BuildContext context, UserProfile profile, bool isActive, bool isDark) {
    final iconData = profile.icon == 'work'
        ? Icons.work_rounded
        : profile.icon == 'school'
            ? Icons.school_rounded
            : profile.icon == 'home'
                ? Icons.home_rounded
                : Icons.person_rounded;

    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        settings.setActiveProfile(profile.id);
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.accentGreen.withValues(alpha: 0.1)
              : (isDark ? AppTheme.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppTheme.accentGreen
                : isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (isActive ? AppTheme.accentGreen : AppTheme.accentPurple)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                iconData,
                size: 18,
                color: isActive ? AppTheme.accentGreen : AppTheme.accentPurple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                profile.name,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppTheme.accentGreen
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
            if (isActive)
              Icon(Icons.check_circle_rounded,
                  color: AppTheme.accentGreen, size: 20),
            if (!profile.isDefault)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                onSelected: (v) {
                  if (v == 'rename') {
                    _showRenameDialog(context, profile, isDark);
                  } else if (v == 'delete') {
                    _confirmDelete(context, profile);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Text('Rename',
                        style: GoogleFonts.inter(fontSize: 14)),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: Colors.red)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, bool isDark) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('New Profile',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Profile name',
            hintStyle: GoogleFonts.inter(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                settings.addProfile(ctrl.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text('Create',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context, UserProfile profile, bool isDark) {
    final ctrl = TextEditingController(text: profile.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Rename Profile',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'New name',
            hintStyle: GoogleFonts.inter(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                settings.renameProfile(profile.id, ctrl.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text('Save',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete "${profile.name}"?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text(
          'This will remove the profile and its settings.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () {
              settings.deleteProfile(profile.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
