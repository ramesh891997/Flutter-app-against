import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Form field validation utilities supporting localization.
class Validators {
  const Validators._();

  /// Validates a username string.
  static String? validateUsername(String? value, [AppLocalizations? l10n]) {
    final loc = l10n ?? AppLocalizations.en;
    if (value == null || value.trim().isEmpty) {
      return loc.usernameRequired;
    }
    if (value.trim().length < 3) {
      return loc.usernameTooShort;
    }
    return null;
  }

  /// Validates a password string.
  static String? validatePassword(String? value, [AppLocalizations? l10n]) {
    final loc = l10n ?? AppLocalizations.en;
    if (value == null || value.isEmpty) {
      return loc.passwordRequired;
    }
    if (value.length < 6) {
      return loc.passwordTooShort;
    }
    return null;
  }
}
