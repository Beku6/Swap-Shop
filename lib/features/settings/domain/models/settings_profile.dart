class SettingsProfile {
  const SettingsProfile({
    required this.userId,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.pushEnabled,
    required this.isPrivate,
  });

  final String userId;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final bool pushEnabled;
  final bool isPrivate;
}
