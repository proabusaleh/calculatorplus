import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/memory_provider.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class MemoryManagerWidget extends StatelessWidget {
  const MemoryManagerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<MemoryProvider>(
      builder: (context, mem, _) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.memory_rounded,
                        color: AppTheme.accentPurple, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Memory Slots',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    if (mem.hasAnyMemory)
                      TextButton(
                        onPressed: () => _clearAll(context, mem),
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.errorRed,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Slots grid
              Flexible(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: 10,
                  itemBuilder: (context, i) {
                    return _buildSlot(context, mem, i, isDark);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSlot(
      BuildContext context, MemoryProvider mem, int index, bool isDark) {
    final slot = mem.slot(index);
    final hasValue = slot.value.isNotEmpty;

    return GestureDetector(
      onTap: hasValue
          ? () {
              HapticService.selectionClick();
              Navigator.pop(context, {'action': 'recall', 'index': index});
            }
          : null,
      onLongPress: hasValue
          ? () => _showSlotOptions(context, mem, index, isDark)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasValue
              ? AppTheme.accentPurple.withValues(alpha: 0.1)
              : isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? AppTheme.accentPurple.withValues(alpha: 0.3)
                : isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  'M$index',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: hasValue
                        ? AppTheme.accentPurple
                        : isDark
                            ? Colors.white38
                            : Colors.black38,
                  ),
                ),
                if (slot.label.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      slot.label,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
                if (hasValue)
                  GestureDetector(
                    onTap: () => _showSlotOptions(context, mem, index, isDark),
                    child: Icon(
                      Icons.more_vert_rounded,
                      size: 14,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              hasValue ? slot.value : 'Empty',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: hasValue
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.white24 : Colors.black26),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showSlotOptions(
      BuildContext context, MemoryProvider mem, int index, bool isDark) {
    HapticService.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'M$index: ${mem.slot(index).value}',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _optionTile(
              Icons.label_outline_rounded,
              'Rename',
              isDark,
              () {
                Navigator.pop(context);
                _showRenameDialog(context, mem, index, isDark);
              },
            ),
            _optionTile(
              Icons.content_copy_rounded,
              'Copy Value',
              isDark,
              () {
                Navigator.pop(context);
                Navigator.pop(context, {
                  'action': 'copy',
                  'value': mem.slot(index).value,
                });
              },
            ),
            _optionTile(
              Icons.delete_outline_rounded,
              'Clear Slot',
              isDark,
              () {
                mem.clearSlot(index);
                Navigator.pop(context);
              },
              destructive: true,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(
      IconData icon, String label, bool isDark, VoidCallback onTap,
      {bool destructive = false}) {
    final color = destructive ? AppTheme.errorRed : (isDark ? Colors.white70 : Colors.black54);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context, MemoryProvider mem, int index, bool isDark) {
    final ctrl = TextEditingController(text: mem.slot(index).label);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Rename M$index',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g., Tax Rate',
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
              mem.labelSlot(index, ctrl.text.trim());
              Navigator.pop(context);
            },
            child: Text('Save',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _clearAll(BuildContext context, MemoryProvider mem) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear all memory?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text(
          'This will clear all 10 memory slots.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () {
              mem.clearAllSlots();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Clear All',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
