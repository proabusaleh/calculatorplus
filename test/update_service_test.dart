import 'package:flutter_test/flutter_test.dart';

import 'package:calculatorplus/services/update_service.dart';

void main() {
  group('normalizeVersion', () {
    test('strips leading v', () {
      expect(UpdateService.normalizeVersion('v2.0.3'), '2.0.3');
    });

    test('strips build metadata', () {
      expect(UpdateService.normalizeVersion('v2.0.3+4'), '2.0.3');
      expect(UpdateService.normalizeVersion('2.0.3+4'), '2.0.3');
    });

    test('strips pre-release suffix', () {
      expect(UpdateService.normalizeVersion('v2.0.3-beta.1'), '2.0.3');
    });

    test('empty stays empty', () {
      expect(UpdateService.normalizeVersion(''), isEmpty);
    });
  });

  group('compareVersions', () {
    test('newer patch is greater', () {
      expect(UpdateService.compareVersions('2.0.3', '2.0.2'), greaterThan(0));
    });

    test('equal versions are zero', () {
      expect(UpdateService.compareVersions('2.0.3', '2.0.3'), 0);
      expect(UpdateService.compareVersions('v2.0.3+4', '2.0.3'), 0);
    });

    test('older major is less', () {
      expect(UpdateService.compareVersions('2.0.2', '2.0.10'), lessThan(0));
    });

    test('multi-digit patch compares numerically', () {
      expect(UpdateService.compareVersions('2.0.10', '2.0.3'), greaterThan(0));
    });
  });

  group('update decision (mirrors checkForUpdate logic)', () {
    bool hasUpdate(String latestTag, String installed) {
      final latest = UpdateService.normalizeVersion(latestTag);
      final current = UpdateService.normalizeVersion(installed);
      return latest.isNotEmpty &&
          current.isNotEmpty &&
          UpdateService.compareVersions(latest, current) > 0;
    }

    test('v2.0.2 user is offered v2.0.3', () {
      expect(hasUpdate('v2.0.3', '2.0.2'), isTrue);
    });

    test('v2.0.3 user sees no update', () {
      expect(hasUpdate('v2.0.3', '2.0.3'), isFalse);
    });

    test('empty installed version never prompts (old bug)', () {
      expect(hasUpdate('v2.0.3', ''), isFalse);
    });
  });
}
