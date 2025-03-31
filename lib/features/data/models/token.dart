class Token {
  final String token;
  final String expiry;

  Token({
    required this.token,
    required this.expiry,
  });

  factory Token.fromJson(Map<String, dynamic> json) =>
      Token(token: '', expiry: '');
}
