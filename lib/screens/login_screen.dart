import 'package:festomps/screens/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../providers/firebase_provider.dart';
import '../global_data.dart';
import './home_screen.dart';
import '../enum.dart';
import '../main.dart';
import '../widgets/curve_clipper.dart';
import '../widgets/custom_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    Key? key,
  }) : super(key: key);
  static const routeName = '/login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late AuthenticationMode _authenticationMode;

  var _isLoading = false;
  var _userEmail = '';
  var _userFirstName = '';
  var _userLastName = '';
  var _userPassword = '';

  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  LocalAuthentication authentication = LocalAuthentication();

  Future<void> _getAuth() async {
    bool isAuth = false;
    try {
      isAuth = await authentication.authenticate(
        localizedReason: 'Scan your fingeprint to access the app',
        options: const AuthenticationOptions(
          biometricOnly: false, // todo Just use fingerprint if set this to true
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      if (kDebugMode) {
        print(isAuth);
      }
      if (isAuth) {
        Future.delayed(Duration.zero).then((_) =>
            Navigator.pushReplacementNamed(context, HomeScreen.routeName));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _authenticationMode = AuthenticationMode.login;
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _confirmPasswordController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    Future.delayed(Duration.zero).then((value) {
      _isLoading = false;
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    });
    FocusScope.of(context).unfocus();
    if (_formKey.currentState == null || !(_formKey.currentState!.validate())) {
      return;
    }
    _formKey.currentState!.save();

    _userEmail = _userEmail.trim();
    _userFirstName = _userFirstName.trim();
    _userLastName = _userLastName.trim();
    _userPassword = _userPassword.trim();

    setState(() {
      _isLoading = true;
    });
    if (kDebugMode) {
      print('''
    Email:\t$_userEmail
    Firstname:\t$_userFirstName
    Lastname:\t$_userLastName
    password:\t$_userPassword
    ''');
    }
    if (_authenticationMode == AuthenticationMode.login) {
      _emailController.text = '';
      _passwordController.text = '';
    } else {
      Future.delayed(const Duration(seconds: 5)).then((value) => setState(() {
            _emailController.text = '';
            _passwordController.text = '';
            _firstNameController.text = '';
            _lastNameController.text = '';
            _confirmPasswordController.text = '';
            _authenticationMode = AuthenticationMode.login;
            _isLoading = false;
          }));
    }
  }

  bool _loginWithFingerprint = false;
  bool _hasBioSensor = false;

  Future<bool> _checkBiometrics() async {
    try {
      _hasBioSensor = await authentication.canCheckBiometrics;
    } on Exception {
      _hasBioSensor = false;
    }
    return _hasBioSensor;
  }
  @override
  Widget build(BuildContext context) {
    final deviceHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    final fingerprintUseAuthorized =
        Provider.of<FirebaseUserData>(context, listen: false).switchValue;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: SizedBox(
            height: deviceHeight,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: deviceHeight *
                        (_authenticationMode == AuthenticationMode.signup
                            ? 0.3
                            : 0.45),
                    child: ClipPath(
                      clipper: CurveClipper(),
                      child: const Image(
                        image: AssetImage(MyApp.appBackgroundImgUrl),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if ((_authenticationMode == AuthenticationMode.login))
                    SizedBox(height: deviceHeight * 0.05),
                  InputField(
                    key: const ValueKey('email'),
                    controller: _emailController,
                    hintText: 'Email',
                    icon: Icons.account_box,
                    obscureText: false,
                    focusNode: _emailFocusNode,
                    autoCorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.none,
                    onFieldSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(
                            _authenticationMode == AuthenticationMode.signup
                                ? _firstNameFocusNode
                                : _passwordFocusNode),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userEmail = value!;
                    },
                  ),
                  if ((_authenticationMode == AuthenticationMode.signup))
                    InputField(
                      key: const ValueKey('firstName'),
                      controller: _firstNameController,
                      hintText: 'First Name',
                      icon: Icons.person,
                      obscureText: false,
                      focusNode: _firstNameFocusNode,
                      autoCorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.sentences,
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(
                              _authenticationMode == AuthenticationMode.signup
                                  ? _lastNameFocusNode
                                  : _passwordFocusNode),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter First Name';
                        }
                        var isCaps = false;
                        for (String val in alphabet) {
                          if (val.toUpperCase() == value[0]) {
                            isCaps = true;
                            break;
                          }
                        }
                        if (!isCaps) {
                          return 'Name must start with a capital letter';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userFirstName = value!;
                      },
                    ),
                  if ((_authenticationMode == AuthenticationMode.signup))
                    InputField(
                      key: const ValueKey('lastName'),
                      controller: _lastNameController,
                      hintText: 'Last Name',
                      icon: Icons.person,
                      obscureText: false,
                      focusNode: _lastNameFocusNode,
                      autoCorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.sentences,
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(_passwordFocusNode),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 4) {
                          return 'Enter Last Name';
                        }

                        var isCaps = false;
                        for (String val in alphabet) {
                          if (val.toUpperCase() == value[0]) {
                            isCaps = true;
                            break;
                          }
                        }
                        if (!isCaps) {
                          return 'Name must start with a capital letter';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        _userLastName = value!;
                      },
                    ),
                  InputField(
                    key: const ValueKey('password'),
                    controller: _passwordController,
                    hintText: 'Password',
                    icon: Icons.lock,
                    obscureText: true,
                    focusNode: _passwordFocusNode,
                    autoCorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.none,
                    onFieldSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(
                            _authenticationMode == AuthenticationMode.signup
                                ? _confirmPasswordFocusNode
                                : null),
                    textInputAction:
                        _authenticationMode == AuthenticationMode.signup
                            ? TextInputAction.next
                            : TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid password.';
                      }
                      if (value.length < 7) {
                        return 'Password must be at least 7 characters long';
                      }
                      if (_userPassword.toLowerCase().trim() ==
                              _userFirstName.toLowerCase().trim() ||
                          _userPassword.toLowerCase().trim() ==
                              _userLastName.toLowerCase().trim() ||
                          _userPassword.toLowerCase().trim() ==
                              _userEmail.toLowerCase().trim()) {
                        return 'Password must be different from email and name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userPassword = value!;
                    },
                  ),
                  if ((_authenticationMode == AuthenticationMode.signup))
                    InputField(
                      key: const ValueKey('confirmPassword'),
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      icon: Icons.lock,
                      obscureText: true,
                      focusNode: _confirmPasswordFocusNode,
                      autoCorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.none,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(null),
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid password.';
                        }
                        if (_passwordController.text !=
                            _confirmPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  Expanded(
                      child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _authenticationMode == AuthenticationMode.signup
                              ? _authenticationMode = AuthenticationMode.login
                              : _authenticationMode = AuthenticationMode.signup;
                        });
                      },
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.35,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (
                                _authenticationMode == AuthenticationMode.login)
                              FutureBuilder(
                                  future: _checkBiometrics(),
                                  builder: (context, snap) {
                                    if(snap.connectionState==ConnectionState.waiting){
                                      print('wait');
                                      return const Center();
                                    }
                                  var  deviceHasBiometrics =snap.data as bool;
                                    print('Finger auth: $fingerprintUseAuthorized');
                                    print('device auth: $deviceHasBiometrics');

                                    _loginWithFingerprint =
                                        fingerprintUseAuthorized &&
                                            deviceHasBiometrics;

                                    print(_loginWithFingerprint);
                                    if(!_loginWithFingerprint){
                                      return const Center();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: IconButton(
                                        onPressed: _getAuth,
                                        iconSize:
                                            MediaQuery.of(context).size.height *
                                                0.06,
                                        icon: const Icon(
                                          Icons.fingerprint,
                                          color: MyApp.appSecondaryColor,
                                        ),
                                      ),
                                    );
                                  }),
                            Custom.elevatedButton(
                              context: context,
                              title: _isLoading
                                  ? Custom.loadingText
                                  : (_authenticationMode ==
                                          AuthenticationMode.signup
                                      ? 'Sign Up'
                                      : 'Login'),
                              onPress: _isLoading ? () {} : _submit,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Custom.normalText((_authenticationMode ==
                                        AuthenticationMode.login)
                                    ? 'Don\'t have an account? '
                                    : 'Already have an account? '),
                                Custom.normalTextOrange('\tClick here '),
                                // const Text(
                                //   '\tClick here ',
                                //   style: TextStyle(
                                //       color: MyApp.appPrimaryColor, fontSize: 16.0),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
