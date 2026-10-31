import 'package:intl/intl.dart';

import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Formatting utilities for currency, ratings, and percentages.
class Formatters {
  const Formatters._();

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Format a numeric amount as currency string, e.g. `$19.99`.
  static String formatCurrency(num? amount) {
    if (amount == null) return '\$0.00';
    return _currencyFormatter.format(amount);
  }

  /// Format a rating number to one decimal place, e.g. `4.5`.
  static String formatRating(num? rating) {
    if (rating == null) return '0.0';
    return rating.toStringAsFixed(1);
  }

  /// Format a discount percentage using localized string provider.
  static String formatDiscount(
    num? discountPercentage, [
    AppLocalizations? l10n,
  ]) {
    if (discountPercentage == null || discountPercentage <= 0) return '';
    final loc = l10n ?? AppLocalizations.en;
    return loc.discountPercentOff(discountPercentage.round());
  }
}
