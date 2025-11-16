class UserProfile {
  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.birthDate,
    this.role = 'Membro',
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? birthDate;
  final String role;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      birthDate: json['birth_date']?.toString(),
      role: () {
        final value = json['role']?.toString();
        if (value != null && value.isNotEmpty) {
          return value;
        }
        return 'Membro';
      }(),
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
