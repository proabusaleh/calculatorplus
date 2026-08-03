import 'dart:convert';

class UserProfile {
  final String id;
  final String name;
  final String icon;
  final bool isDefault;

  const UserProfile({
    required this.id,
    required this.name,
    this.icon = 'person',
    this.isDefault = false,
  });

  UserProfile copyWith({String? name, String? icon, bool? isDefault}) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'isDefault': isDefault,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? 'person',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  String encode() => jsonEncode(toJson());

  factory UserProfile.decode(String source) {
    return UserProfile.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }

  static UserProfile defaultProfile() {
    return const UserProfile(
      id: 'default',
      name: 'Default',
      icon: 'person',
      isDefault: true,
    );
  }

  static List<UserProfile> presets() {
    return [
      defaultProfile(),
      const UserProfile(id: 'work', name: 'Work', icon: 'work'),
      const UserProfile(id: 'school', name: 'School', icon: 'school'),
      const UserProfile(id: 'personal', name: 'Personal', icon: 'home'),
    ];
  }
}
