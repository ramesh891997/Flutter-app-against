import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_demo_app/core/utils/time_utils.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

void main() {
  const l10n = AppLocalizations(Locale('en'));

  group('TimeUtils - Global Time-Based Greetings', () {
    test('returns morning greeting from 05:00 to 11:59', () {
      final t5am = DateTime(2026, 10, 31, 5, 0);
      final t9am = DateTime(2026, 10, 31, 9, 30);
      final t1159am = DateTime(2026, 10, 31, 11, 59);

      expect(TimeUtils.getTimePeriod(t5am), TimeOfDayPeriod.morning);
      expect(TimeUtils.getGreeting(l10n, t5am), 'Good morning,');

      expect(TimeUtils.getTimePeriod(t9am), TimeOfDayPeriod.morning);
      expect(TimeUtils.getGreeting(l10n, t9am), 'Good morning,');

      expect(TimeUtils.getTimePeriod(t1159am), TimeOfDayPeriod.morning);
      expect(TimeUtils.getGreeting(l10n, t1159am), 'Good morning,');
    });

    test('returns afternoon greeting from 12:00 to 16:59', () {
      final t12pm = DateTime(2026, 10, 31, 12, 0);
      final t3pm = DateTime(2026, 10, 31, 15, 15);
      final t459pm = DateTime(2026, 10, 31, 16, 59);

      expect(TimeUtils.getTimePeriod(t12pm), TimeOfDayPeriod.afternoon);
      expect(TimeUtils.getGreeting(l10n, t12pm), 'Good afternoon,');

      expect(TimeUtils.getTimePeriod(t3pm), TimeOfDayPeriod.afternoon);
      expect(TimeUtils.getGreeting(l10n, t3pm), 'Good afternoon,');

      expect(TimeUtils.getTimePeriod(t459pm), TimeOfDayPeriod.afternoon);
      expect(TimeUtils.getGreeting(l10n, t459pm), 'Good afternoon,');
    });

    test('returns evening greeting from 17:00 to 04:59', () {
      final t5pm = DateTime(2026, 10, 31, 17, 0);
      final t8pm = DateTime(2026, 10, 31, 20, 0);
      final tMidnight = DateTime(2026, 10, 31, 0, 0);
      final t4am = DateTime(2026, 10, 31, 4, 30);

      expect(TimeUtils.getTimePeriod(t5pm), TimeOfDayPeriod.evening);
      expect(TimeUtils.getGreeting(l10n, t5pm), 'Good evening,');

      expect(TimeUtils.getTimePeriod(t8pm), TimeOfDayPeriod.evening);
      expect(TimeUtils.getGreeting(l10n, t8pm), 'Good evening,');

      expect(TimeUtils.getTimePeriod(tMidnight), TimeOfDayPeriod.evening);
      expect(TimeUtils.getGreeting(l10n, tMidnight), 'Good evening,');

      expect(TimeUtils.getTimePeriod(t4am), TimeOfDayPeriod.evening);
      expect(TimeUtils.getGreeting(l10n, t4am), 'Good evening,');
    });
  });
}
