import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../providers/calculator_provider.dart';
import '../providers/settings_provider.dart';
import '../services/calculator_service.dart';
import '../theme/app_theme.dart';
import 'animated_builder.dart';

class DisplayPanel extends StatefulWidget {
  const DisplayPanel({super.key});

  @override
  State<DisplayPanel> createState() => _DisplayPanelState();
}

class _DisplayPanelState extends State<DisplayPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _resultCtrl;
  late Animation<double> _resultSlide;
  late Animation<double> _resultFade;
  String _prevResult = '';

  @override
  void initState() {
    super.initState();
    _resultCtrl = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _resultSlide = Tween<double>(begin: 15, end: 0).animate(
      CurvedAnimation(parent: _resultCtrl, curve: Curves.easeOutCubic),
    );
    _resultFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _resultCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _resultCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final displayScale = settings.displayPrefs.displayFontSize;
    final resultScale = settings.displayPrefs.resultFontSize;
    final fontFamily = settings.displayPrefs.fontFamily;

    return Consumer<CalculatorProvider>(
      builder: (context, calc, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final state = calc.state;

        if (state.result != _prevResult && state.result.isNotEmpty) {
          _prevResult = state.result;
          _resultCtrl.reset();
          _resultCtrl.forward();
        }

        final String displayExpr =
        state.expression.isEmpty ? '0' : state.expression;

        return GestureDetector(
          onLongPress: () => _showCopyMenu(context, calc),
          child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Indicators row (memory / error)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 14,
                        color: AppTheme.red.withValues(alpha: 0.85),
                      ),
                    ),
                  if (state.memory.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.purple.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.purple.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.memory_rounded,
                            size: 10,
                            color: AppTheme.purple,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            state.memory,
                            style: GoogleFonts.getFont(
                              fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              // Expression
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: AutoSizeText(
                        displayExpr,
                        key: ValueKey(displayExpr),
                        style: GoogleFonts.getFont(
                          fontFamily,
                          fontSize: size.width * 0.11 * displayScale,
                          fontWeight: FontWeight.w300,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.9)
                              : const Color(0xFF1C1C1E).withValues(alpha: 0.9),
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        minFontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Result
              SizedBox(
                height: size.height * 0.055,
                child: AppAnimatedBuilder(
                  animation: _resultCtrl,
                  builder: (context, _) {
                    return Opacity(
                      opacity: state.result.isEmpty
                          ? 0.0
                          : _resultFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _resultSlide.value),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                if (state.hasError)
                                  AutoSizeText(
                                    state.errorMessage,
                                    style: GoogleFonts.getFont(
                                      fontFamily,
                                      fontSize: size.width * 0.055 * resultScale,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.red.withValues(alpha: 0.9),
                                    ),
                                    maxLines: 1,
                                    minFontSize: 14,
                                  )
                                else ...[
                                  Text(
                                    '=',
                                    style: GoogleFonts.getFont(
                                      fontFamily,
                                      fontSize: (state.shouldResetOnNextInput
                                          ? size.width * 0.08
                                          : size.width * 0.055) * resultScale,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.electricBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AutoSizeText(
                                    CalculatorService.formatDisplayNumber(
                                        state.result),
                                    style: GoogleFonts.getFont(
                                      fontFamily,
                                      fontSize: (state.shouldResetOnNextInput
                                          ? size.width * 0.08
                                          : size.width * 0.055) * resultScale,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1C1C1E),
                                    ),
                                    maxLines: 1,
                                    minFontSize: 14,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Divider
              Container(
                height: 1,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ]
                        : [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  void _showCopyMenu(BuildContext context, CalculatorProvider calc) {
    final expression = calc.getExpressionForCopy();
    final result = calc.getResultForCopy();
    if (expression.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Copy Expression'),
              subtitle: Text(
                expression,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: expression));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Expression copied'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppTheme.accentGreen,
                    duration: const Duration(seconds: 2),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
            ),
            if (result.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.calculate_rounded),
                title: const Text('Copy Result'),
                subtitle: Text(
                  CalculatorService.formatDisplayNumber(result),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: result));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Result copied'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: AppTheme.accentGreen,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
