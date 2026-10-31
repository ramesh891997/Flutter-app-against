import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Period of the day for personalized time-based greetings.
enum TimeOfDayPeriod { morning, afternoon, evening }

/// Time utilities providing global time-zone aware greetings.
class TimeUtils {
  const TimeUtils._();

  /// Determines the time period based on local time anywhere in the world.
  ///
  /// - Morning: 05:00 to 11:59
  /// - Afternoon: 12:00 to 16:59
  /// - Evening / Night: 17:00 to 04:59
  static TimeOfDayPeriod getTimePeriod([DateTime? localTime]) {
    final now = localTime ?? DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return TimeOfDayPeriod.morning;
    } else if (hour >= 12 && hour < 17) {
      return TimeOfDayPeriod.afternoon;
    } else {
      return TimeOfDayPeriod.evening;
    }
  }

  /// Returns the localized greeting string for the current local time.
  static String getGreeting(AppLocalizations l10n, [DateTime? localTime]) {
    switch (getTimePeriod(localTime)) {
      case TimeOfDayPeriod.morning:
        return l10n.goodMorning;
      case TimeOfDayPeriod.afternoon:
        return l10n.goodAfternoon;
      case TimeOfDayPeriod.evening:
        return l10n.goodEvening;
    }
  }
}
