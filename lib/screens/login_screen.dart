import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/firebase_auth.dart';
import '../providers/firebase_user_data.dart';
import '../screens/mqtt_home_screen/mqtt_root_screen.dart';
import '../global_data.dart';
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
  AuthenticationMode _authenticationMode = AuthenticationMode.login;
  var _init = true;

  var _isLoading = false;
  var _isReadingFingerprint = false;
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

  Future<void> _getAuth() async {
    bool isAuth = false;
    try {
      setState(() => _isReadingFingerprint = true);
      isAuth = await authentication.authenticate(
        localizedReason: 'Scan your fingeprint to access the app',
        options: const AuthenticationOptions(
          biometricOnly: false,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      setState(() => _isReadingFingerprint = false);
      if (isAuth) {
        // todo Sign in here, with username and password from shared preferences
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey(FirebaseUserData.prefName)) {
          final fingerprintData =
              json.decode(prefs.getString(FirebaseUserData.prefName)!)
                  as Map<String, dynamic>;
          setState(() => _isLoading = true);
          await _activateLogin(fingerprintData['email'] as String,
              fingerprintData['password'] as String);

          setState(() => _isLoading = false);
        } else {
          Future.delayed(Duration.zero).then(
              (_) => Custom.showCustomDialog(context, 'Fingerprint disabled'));
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _activateLogin(String email, String password) async {
    await FirebaseAuthenticationHandler.login(
            context: context, email: email, password: password)
        .then((message) {
      if (message == 'Welcome') {
        Navigator.pushReplacementNamed(context, MainHome.routeName);
      } else {
        Custom.showCustomDialog(context, message);
      }
    });
  }

  Future<void> _submit() async {
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
    try {
      if (_authenticationMode == AuthenticationMode.login) {
         await _activateLogin(_userEmail, _userPassword);
      } else {
        await FirebaseAuthenticationHandler.signup(
                context: context,
                firstname: _userFirstName,
                lastname: _userLastName,
                email: _userEmail,
                password: _userPassword)
            .then((message) => Custom.showCustomDialog(context, message));
      }
    } catch (error) {
      const errorMessage = 'Failed, check the internet connection later';
      return Custom.showCustomDialog(context, errorMessage);
    } finally {
      setState(() {
        _authenticationMode = AuthenticationMode.login;
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) {
      Future.delayed(Duration.zero).then((_) async {
        final loggedUser =
            Provider.of<FirebaseUserData>(context, listen: false);
        await loggedUser.switchValueInit();
      }).then((_) => setState(() => _init = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    final fingerprintUseAuthorized =
        Provider.of<FirebaseUserData>(context).switchValue;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          // physics: const BouncingScrollPhysics(
          //     parent: AlwaysScrollableScrollPhysics()),
          child: SizedBox(
            height: deviceHeight,
            child: Stack(
              children: [
                Form(
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
                              .requestFocus(_authenticationMode ==
                                      AuthenticationMode.signup
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
                          if (_passwordController.text.toLowerCase().trim() ==
                                  _firstNameController.text
                                      .toLowerCase()
                                      .trim() ||
                              _passwordController.text.toLowerCase().trim() ==
                                  '${_firstNameController.text}${_lastNameController.text}'
                                      .toLowerCase()
                                      .trim() ||
                              _passwordController.text.toLowerCase().trim() ==
                                  _lastNameController.text
                                      .toLowerCase()
                                      .trim() ||
                              _passwordController.text.toLowerCase().trim() ==
                                  _emailController.text.toLowerCase().trim()) {
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
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (_authenticationMode ==
                                  AuthenticationMode.login)
                                FutureBuilder(
                                    future: _checkBiometrics(),
                                    builder: (context, snap) {
                                      if (snap.connectionState ==
                                          ConnectionState.waiting) {
                                        // print('wait');
                                        return const Center();
                                      }
                                      var deviceHasBiometrics =
                                          snap.data as bool;
                                      // print(
                                      //     'Finger auth: $fingerprintUseAuthorized');
                                      // print('device auth: $deviceHasBiometrics');

                                      _loginWithFingerprint =
                                          fingerprintUseAuthorized &&
                                              deviceHasBiometrics;

                                      // print(_loginWithFingerprint);
                                      if (!_loginWithFingerprint) {
                                        return const Center();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: IconButton(
                                          onPressed: _getAuth,
                                          iconSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
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
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _authenticationMode ==
                                            AuthenticationMode.signup
                                        ? _authenticationMode =
                                            AuthenticationMode.login
                                        : _authenticationMode =
                                            AuthenticationMode.signup;
                                  });
                                },
                                child: Row(
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
                              ),
                            ],
                          ),
                        ),
                      ))
                    ],
                  ),
                ),
                if (_isLoading || _isReadingFingerprint)
                  Container(
                    height: deviceHeight,
                    color: MyApp.appSecondaryColor2.withOpacity(0.75),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    
  }

  @override
  void dispose() {
    super.dispose();
    _init = true;

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
  }
}
