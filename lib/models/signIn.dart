class SignInData {
  final String localId;
  final String email;
  final String idToken;
  final String expiresIn;

  SignInData({
    required this.localId,
    required this.email,
    required this.idToken,
    required this.expiresIn,
  });

 static SignInData fromMap(Map<String, dynamic> signInData) => SignInData(
      localId: signInData['localId'],
      email: signInData['email'],
      // displayName: signInData['displayName'],
      idToken: signInData['idToken'],
      // registered: signInData['registered'],
      // refreshToken: signInData['refreshToken'],
      expiresIn: signInData['expiresIn']);
}
