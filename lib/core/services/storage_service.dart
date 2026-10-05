import 'package:hive_flutter/hive_flutter.dart';
import '../models/contact.dart';
import '../models/alert_event.dart';

class StorageService {
  static const String _contactsBox = 'contacts';
  static const String _alertsBox = 'alerts';
  static const String _settingsBox = 'settings';

  static const String _userNameKey = 'user_name';
  static const int maxContacts = 3;

  Box<Contact>? _contacts;
  Box<AlertEvent>? _alerts;
  Box? _settings;

  /// Initialize Hive and open boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ContactAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AlertEventAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(AlertStatusAdapter());
    }

    // Open boxes
    _contacts = await Hive.openBox<Contact>(_contactsBox);
    _alerts = await Hive.openBox<AlertEvent>(_alertsBox);
    _settings = await Hive.openBox(_settingsBox);
  }

  // === Contact Operations ===

  /// Get all contacts
  List<Contact> getContacts() {
    return _contacts?.values.toList() ?? [];
  }

  /// Get active contacts only
  List<Contact> getActiveContacts() {
    return getContacts().where((c) => c.isActive).toList();
  }

  /// Add a new contact
  /// Returns false if max contacts reached
  Future<bool> addContact(Contact contact) async {
    if (getContacts().length >= maxContacts) {
      return false;
    }
    await _contacts?.put(contact.id, contact);
    return true;
  }

  /// Update existing contact
  Future<void> updateContact(Contact contact) async {
    await _contacts?.put(contact.id, contact);
  }

  /// Delete contact
  Future<void> deleteContact(String id) async {
    await _contacts?.delete(id);
  }

  /// Check if can add more contacts
  bool canAddContact() {
    return getContacts().length < maxContacts;
  }

  // === Alert History Operations ===

  /// Get all alerts sorted by date (most recent first)
  List<AlertEvent> getAlerts() {
    final alerts = _alerts?.values.toList() ?? [];
    alerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return alerts;
  }

  /// Get most recent active alert (not resolved)
  AlertEvent? getActiveAlert() {
    final alerts = getAlerts();
    try {
      return alerts.firstWhere((alert) => alert.isActive);
    } catch (e) {
      return null;
    }
  }

  /// Add a new alert event
  Future<void> addAlert(AlertEvent event) async {
    await _alerts?.put(event.id, event);
  }

  /// Update existing alert
  Future<void> updateAlert(AlertEvent event) async {
    await _alerts?.put(event.id, event);
  }

  /// Resolve an alert (mark as resolved)
  Future<void> resolveAlert(String id) async {
    final alert = _alerts?.get(id);
    if (alert != null) {
      final resolved = alert.resolve();
      await _alerts?.put(id, resolved);
    }
  }

  /// Delete alert
  Future<void> deleteAlert(String id) async {
    await _alerts?.delete(id);
  }

  /// Clear all alerts
  Future<void> clearAllAlerts() async {
    await _alerts?.clear();
  }

  // === Settings Operations ===

  /// Get user's name for alert message
  String? getUserName() {
    return _settings?.get(_userNameKey) as String?;
  }

  /// Set user's name
  Future<void> setUserName(String? name) async {
    if (name == null || name.isEmpty) {
      await _settings?.delete(_userNameKey);
    } else {
      await _settings?.put(_userNameKey, name);
    }
  }

  // === Clear All Data ===

  /// Clear all data (contacts + alerts)
  Future<void> clearAllData() async {
    await _contacts?.clear();
    await _alerts?.clear();
  }
}
