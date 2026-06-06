class User {
  final String? id;
  final String name;
  final String lastname;
  final String email;
  final String password;
  final String? birthdate;
  final String? profileImage;

  User({
    this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.password,
    this.birthdate,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      name: json['name']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      birthdate: json['birthdate']?.toString(),
      profileImage: json['profileImage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastname': lastname,
      'email': email,
      'password': password,
      if (birthdate != null) 'birthdate': birthdate,
      if (profileImage != null) 'profileImage': profileImage,
    };
  }
}
