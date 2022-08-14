class SignUpData {
  final String idToken;
  final String email;
  final String refreshToken;
  final String expiresIn;
  final String localId;

  SignUpData({
    required this.idToken,
    required this.email,
    required this.refreshToken,
    required this.expiresIn,
    required this.localId,
  });


  static SignUpData fromMap(Map<String, dynamic> signUpData) =>
      SignUpData(idToken: signUpData ['idToken'],
          email: signUpData['email'],
          refreshToken: signUpData['refreshToken'],
          expiresIn: signUpData['expiresIn'],
          localId: signUpData ['localId']);


}
