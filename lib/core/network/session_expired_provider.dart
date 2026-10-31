import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider holding a callback invoked when an authentication session expires.
final sessionExpiredProvider = Provider<void Function()?>((ref) => null);
