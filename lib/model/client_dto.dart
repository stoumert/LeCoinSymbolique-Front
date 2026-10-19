class ClientDTO {
  final int id;
  final String email;
  final String username;
  final String fullName;

  ClientDTO({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
  });

  factory ClientDTO.fromJson(Map<String, dynamic> json) {
    return ClientDTO(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullName: json['fullName'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'fullName': fullName,
    };
  }
}
