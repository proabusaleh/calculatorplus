import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/memory_slot.dart';
import '../services/prefs_service.dart';
import '../services/calculator_service.dart';

class MemoryProvider extends ChangeNotifier {
  static const String _memoryKey = 'memory_slots_v1';
  static const String _variablesKey = 'calc_variables_v1';

  List<MemorySlot> _slots = MemorySlot.initialSlots();
  List<MemorySlot> get slots => List.unmodifiable(_slots);

  // Named variables
  List<MapEntry<String, String>> _variables = [];
  List<MapEntry<String, String>> get variables =>
      List.unmodifiable(_variables);

  MemoryProvider() {
    _loadMemory();
    _loadVariables();
  }

  // ─────────────────── Memory Slots ───────────────────

  MemorySlot slot(int index) {
    if (index < 0 || index >= _slots.length) {
      return MemorySlot(index: index);
    }
    return _slots[index];
  }

  String get activeMemoryDisplay {
    final nonEmpty = _slots.where((s) => s.value.isNotEmpty).toList();
    if (nonEmpty.isEmpty) return '';
    if (nonEmpty.length == 1) return nonEmpty.first.value;
    return '${nonEmpty.length} slots';
  }

  bool get hasAnyMemory => _slots.any((s) => s.value.isNotEmpty);

  Future<void> storeToSlot(int index, String value) async {
    if (index < 0 || index >= _slots.length) return;
    _slots[index] = _slots[index].copyWith(value: value);
    notifyListeners();
    await _saveMemory();
  }

  Future<void> storeCurrentResult(int index, String expression,
      {bool useDegrees = true}) async {
    final result = CalculatorService.evaluate(
      expression,
      useDegrees: useDegrees,
    );
    if (!result.isError) {
      await storeToSlot(index, result.value);
    }
  }

  String recallSlot(int index) {
    if (index < 0 || index >= _slots.length) return '';
    return _slots[index].value;
  }

  Future<void> clearSlot(int index) async {
    if (index < 0 || index >= _slots.length) return;
    _slots[index] = _slots[index].copyWith(value: '');
    notifyListeners();
    await _saveMemory();
  }

  Future<void> labelSlot(int index, String label) async {
    if (index < 0 || index >= _slots.length) return;
    _slots[index] = _slots[index].copyWith(label: label);
    notifyListeners();
    await _saveMemory();
  }

  Future<void> addToSlot(int index, double amount) async {
    if (index < 0 || index >= _slots.length) return;
    double current = double.tryParse(_slots[index].value) ?? 0;
    String newValue =
        CalculatorService.formatDisplayNumber((current + amount).toString());
    _slots[index] = _slots[index].copyWith(value: newValue);
    notifyListeners();
    await _saveMemory();
  }

  Future<void> subtractFromSlot(int index, double amount) async {
    if (index < 0 || index >= _slots.length) return;
    double current = double.tryParse(_slots[index].value) ?? 0;
    String newValue =
        CalculatorService.formatDisplayNumber((current - amount).toString());
    _slots[index] = _slots[index].copyWith(value: newValue);
    notifyListeners();
    await _saveMemory();
  }

  Future<void> clearAllSlots() async {
    _slots = MemorySlot.initialSlots();
    notifyListeners();
    await _saveMemory();
  }

  // ─────────────────── Variables ───────────────────

  Future<void> setVariable(String name, String value) async {
    final index = _variables.indexWhere((v) => v.key == name);
    if (index >= 0) {
      _variables[index] = MapEntry(name, value);
    } else {
      _variables.add(MapEntry(name, value));
    }
    notifyListeners();
    await _saveVariables();
  }

  String getVariable(String name) {
    final entry = _variables.where((v) => v.key == name);
    return entry.isNotEmpty ? entry.first.value : '';
  }

  bool hasVariable(String name) {
    return _variables.any((v) => v.key == name);
  }

  Future<void> removeVariable(String name) async {
    _variables.removeWhere((v) => v.key == name);
    notifyListeners();
    await _saveVariables();
  }

  Future<void> clearAllVariables() async {
    _variables.clear();
    notifyListeners();
    await _saveVariables();
  }

  // ─────────────────── Persistence ───────────────────

  Future<void> _saveMemory() async {
    try {
      final prefs = await PrefsService.getInstance();
      final list = _slots.map((s) => s.encode()).toList();
      await prefs.setStringList(_memoryKey, list);
    } catch (_) {}
  }

  Future<void> _loadMemory() async {
    try {
      final prefs = await PrefsService.getInstance();
      final list = prefs.getStringList(_memoryKey);
      if (list != null && list.length == MemorySlot.slotCount) {
        _slots = list.map((j) => MemorySlot.decode(j)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveVariables() async {
    try {
      final prefs = await PrefsService.getInstance();
      final list = _variables
          .map((v) => jsonEncode({'name': v.key, 'value': v.value}))
          .toList();
      await prefs.setStringList(_variablesKey, list);
    } catch (_) {}
  }

  Future<void> _loadVariables() async {
    try {
      final prefs = await PrefsService.getInstance();
      final list = prefs.getStringList(_variablesKey);
      if (list != null) {
        _variables = list.map((j) {
          final m = jsonDecode(j) as Map<String, dynamic>;
          return MapEntry(m['name'] as String, m['value'] as String);
        }).toList();
        notifyListeners();
      }
    } catch (_) {}
  }
}
