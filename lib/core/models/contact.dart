import 'package:hive/hive.dart';

part 'contact.g.dart';

@HiveType(typeId: 0)
class Contact {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? phone;

  @HiveField(3)
  final String? notes;

  @HiveField(4)
  final bool isActive;

  @HiveField(5)
  final String? fcmToken;

  Contact({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    required this.isActive,
    this.fcmToken,
  });

  Contact copyWith({
    String? id,
    String? name,
    String? phone,
    String? notes,
    bool? isActive,
    String? fcmToken,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'notes': notes,
      'isActive': isActive,
      'fcmToken': fcmToken,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool,
      fcmToken: json['fcmToken'] as String?,
    );
  }
}
