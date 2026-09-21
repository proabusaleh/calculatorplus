import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/display_preferences.dart';
import '../models/button_layout_item.dart';
import '../models/user_profile.dart';
import '../services/prefs_service.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _prefsKey = 'display_prefs';
  static const String _layoutKey = 'button_layout';
  static const String _profilesKey = 'user_profiles';
  static const String _activeProfileKey = 'active_profile_id';

  /// Keys for display prefs are shared with the 'default' profile (for
  /// backward compatibility with previously saved values) and namespaced by
  /// profile id for everything else.
  static String _displayPrefsKey(String profileId) =>
      profileId == 'default' ? _prefsKey : '${_prefsKey}_$profileId';

  static String _layoutKeyFor(String profileId) =>
      profileId == 'default' ? _layoutKey : '${_layoutKey}_$profileId';

  DisplayPreferences _displayPrefs = const DisplayPreferences();
  DisplayPreferences get displayPrefs => _displayPrefs;

  List<ButtonLayoutItem> _buttonLayout = ButtonLayoutItem.defaultLayout();
  List<ButtonLayoutItem> get buttonLayout => List.unmodifiable(_buttonLayout);

  List<UserProfile> _profiles = UserProfile.presets();
  List<UserProfile> get profiles => List.unmodifiable(_profiles);

  String _activeProfileId = 'default';
  String get activeProfileId => _activeProfileId;

  Timer? _saveDebounceTimer;

  UserProfile get activeProfile {
    return _profiles.firstWhere(
      (p) => p.id == _activeProfileId,
      orElse: () => _profiles.first,
    );
  }

  SettingsProvider() {
    _loadAll();
  }

  @override
  void dispose() {
    _saveDebounceTimer?.cancel();
    super.dispose();
  }

  // ─────────────────── Display Preferences ───────────────────

  void setDisplayFormat(DisplayFormat format) {
    _displayPrefs = _displayPrefs.copyWith(format: format);
    notifyListeners();
    _savePrefs();
  }

  void setDecimalSeparator(DecimalSeparator sep) {
    _displayPrefs = _displayPrefs.copyWith(decimalSeparator: sep);
    notifyListeners();
    _savePrefs();
  }

  void toggleThousandsSeparator() {
    _displayPrefs = _displayPrefs.copyWith(
      thousandsSeparatorEnabled: !_displayPrefs.thousandsSeparatorEnabled,
    );
    notifyListeners();
    _savePrefs();
  }

  void setAngleDisplay(AngleDisplayUnit unit) {
    _displayPrefs = _displayPrefs.copyWith(angleDisplay: unit);
    notifyListeners();
    _savePrefs();
  }

  void setDisplayFontSize(double size) {
    _displayPrefs = _displayPrefs.copyWith(displayFontSize: size);
    notifyListeners();
    _savePrefs();
  }

  void setResultFontSize(double size) {
    _displayPrefs = _displayPrefs.copyWith(resultFontSize: size);
    notifyListeners();
    _savePrefs();
  }

  void setFontFamily(String family) {
    _displayPrefs = _displayPrefs.copyWith(fontFamily: family);
    notifyListeners();
    _savePrefs();
  }

  void toggleTrailingZeros() {
    _displayPrefs = _displayPrefs.copyWith(
      showTrailingZeros: !_displayPrefs.showTrailingZeros,
    );
    notifyListeners();
    _savePrefs();
  }

  void setMaxDecimalPlaces(int places) {
    _displayPrefs = _displayPrefs.copyWith(maxDecimalPlaces: places);
    notifyListeners();
    _savePrefs();
  }

  // ─────────────────── Button Layout ───────────────────

  Future<void> toggleButtonVisibility(String buttonId) async {
    final index = _buttonLayout.indexWhere((b) => b.id == buttonId);
    if (index == -1) return;
    _buttonLayout[index] = _buttonLayout[index].copyWith(
      visible: !_buttonLayout[index].visible,
    );
    notifyListeners();
    await _saveLayout();
  }

  Future<void> reorderButton(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex--;
    final item = _buttonLayout.removeAt(oldIndex);
    _buttonLayout.insert(newIndex, item);
    for (int i = 0; i < _buttonLayout.length; i++) {
      _buttonLayout[i] = _buttonLayout[i].copyWith(order: i);
    }
    notifyListeners();
    await _saveLayout();
  }

  Future<void> resetButtonLayout() async {
    _buttonLayout = ButtonLayoutItem.defaultLayout();
    notifyListeners();
    await _saveLayout();
  }

  List<ButtonLayoutItem> get visibleButtons {
    return _buttonLayout.where((b) => b.visible).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  bool isButtonVisible(String id) {
    final btn = _buttonLayout.where((b) => b.id == id);
    return btn.isNotEmpty ? btn.first.visible : true;
  }

  // ─────────────────── Profiles ───────────────────

  Future<void> setActiveProfile(String profileId) async {
    if (!_profiles.any((p) => p.id == profileId)) return;
    if (profileId == _activeProfileId) return;

    // Persist the outgoing profile's settings before switching away.
    _saveDebounceTimer?.cancel();
    final previousId = _activeProfileId;
    try {
      final prefs = await PrefsService.getInstance();
      await prefs.setString(
        _displayPrefsKey(previousId),
        jsonEncode(_displayPrefs.toJson()),
      );
      await prefs.setStringList(
        _layoutKeyFor(previousId),
        _buttonLayout.map((b) => jsonEncode(b.toJson())).toList(),
      );
    } catch (_) {}

    _activeProfileId = profileId;
    await _loadProfileSettings(profileId);
    notifyListeners();

    try {
      final prefs = await PrefsService.getInstance();
      await prefs.setString(_activeProfileKey, profileId);
    } catch (_) {}
  }

  Future<void> addProfile(String name) async {
    final id = 'profile_${DateTime.now().millisecondsSinceEpoch}';
    _profiles.add(UserProfile(id: id, name: name));
    notifyListeners();
    await _saveProfiles();
  }

  Future<void> renameProfile(String id, String newName) async {
    final index = _profiles.indexWhere((p) => p.id == id);
    if (index == -1) return;
    _profiles[index] = _profiles[index].copyWith(name: newName);
    notifyListeners();
    await _saveProfiles();
  }

  Future<void> deleteProfile(String id) async {
    final profile = _profiles.where((p) => p.id == id);
    if (profile.isEmpty || profile.first.isDefault) return;
    _profiles.removeWhere((p) => p.id == id);
    if (_activeProfileId == id) {
      _activeProfileId = 'default';
      await _loadProfileSettings('default');
    }
    notifyListeners();
    await _saveProfiles();
  }

  // ─────────────────── Persistence ───────────────────

  Future<void> _loadAll() async {
    await _loadProfiles();
    await _loadActiveProfile();
    await _loadProfileSettings(_activeProfileId);
    notifyListeners();
  }

  Future<void> _loadProfileSettings(String profileId) async {
    await _loadDisplayPrefs(profileId);
    await _loadButtonLayout(profileId);
  }

  Future<void> _loadDisplayPrefs(String profileId) async {
    try {
      final prefs = await PrefsService.getInstance();
      final json = prefs.getString(_displayPrefsKey(profileId));
      if (json != null) {
        _displayPrefs = DisplayPreferences.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        );
      }
    } catch (_) {}
  }

  Future<void> _loadButtonLayout(String profileId) async {
    try {
      final prefs = await PrefsService.getInstance();
      final list = prefs.getStringList(_layoutKeyFor(profileId));
      if (list != null && list.isNotEmpty) {
        _buttonLayout = list
            .map((j) => ButtonLayoutItem.fromJson(
                jsonDecode(j) as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
  }

  void _savePrefs() {
    final profileId = _activeProfileId;
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final prefs = await PrefsService.getInstance();
        await prefs.setString(
            _displayPrefsKey(profileId), jsonEncode(_displayPrefs.toJson()));
      } catch (_) {}
    });
  }

  Future<void> _saveLayout() async {
    final profileId = _activeProfileId;
    try {
      final prefs = await PrefsService.getInstance();
      final list = _buttonLayout.map((b) => jsonEncode(b.toJson())).toList();
      await prefs.setStringList(_layoutKeyFor(profileId), list);
    } catch (_) {}
  }

  Future<void> _loadProfiles() async {
    try {
      final prefs = await PrefsService.getInstance();
      final list = prefs.getStringList(_profilesKey);
      if (list != null && list.isNotEmpty) {
        _profiles = list
            .map((j) =>
                UserProfile.fromJson(jsonDecode(j) as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _saveProfiles() async {
    try {
      final prefs = await PrefsService.getInstance();
      final list = _profiles.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList(_profilesKey, list);
    } catch (_) {}
  }

  Future<void> _loadActiveProfile() async {
    try {
      final prefs = await PrefsService.getInstance();
      _activeProfileId = prefs.getString(_activeProfileKey) ?? 'default';
    } catch (_) {}
  }
}
