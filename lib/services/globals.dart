import 'services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Static global state. Immutable services that do not care about build context.
class Global {
  // Data Models
  static final Map models = {
    Asset: (data) => Asset.fromMap(data),
    Question: (data) => Question.fromMap(data),
    Reminders: (data) => Reminders.fromMap(data),
  };
}
