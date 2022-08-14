import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../global_data.dart';
import '../models/user.dart';
import '../providers/firebase_user_data.dart';
import '../widgets/custom_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen(this.user, {Key? key}) : super(key: key);

  final User user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  var _userEmail = '';
  var _userFirstName = '';
  var _userLastName = '';
  var _userPassword = '';

  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _oldPasswordFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    resetFields();
    _emailFocusNode.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _oldPasswordFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _confirmPasswordController.dispose();
    _oldPasswordController.dispose();
    _passwordController.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState == null || !(_formKey.currentState!.validate())) {
      return;
    }
    _formKey.currentState!.save();

    // todo submit to firebase
    _userEmail = _userEmail.trim();
    _userFirstName = _userFirstName.trim();
    _userLastName = _userLastName.trim();
    _userPassword = _userPassword;

    setState(() {
      _isLoading = true;
    });
    if (kDebugMode) {
      print('''
    Email:\t$_userEmail
    Firstname:\t$_userFirstName
    Lastname:\t$_userLastName
    new password:\t$_userPassword
    ''');
    }
    await Custom.showCustomDialog(context, 'UPDATE SUCCESSFUL');

    Future.delayed(Duration.zero).then((_) => Navigator.pop(context));
  }

  @override
  void initState() {
    super.initState();
    _initValues = widget.user;
    resetFields();
    _firstNameController.text = _initValues.firstName;
    _lastNameController.text = _initValues.lastName;
    _emailController.text = _initValues.email;
  }

  void resetFields() {
    _emailController.text = '';
    _firstNameController.text = '';
    _lastNameController.text = '';
    _oldPasswordController.text = '';
    _passwordController.text = '';
    _confirmPasswordController.text = '';
  }

  late User _initValues;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUserData>(context);
    // todo insert the new user and update the data
    final deviceHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Custom.titleText('Edit Profile'),
          leading: IconButton(
            icon: Custom.icon(Icons.arrow_back, MyApp.appSecondaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: deviceHeight,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        MyApp.appPrimaryColor.withOpacity(0.5),
                        MyApp.appSecondaryColor.withOpacity(0.5),
                        MyApp.appSecondaryColor2.withOpacity(0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0, 1, 3],
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    height: deviceHeight / 1.2,
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
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
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context)
                                          .requestFocus(_firstNameFocusNode),
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
                                InputField(
                                  key: const ValueKey('firstName'),
                                  controller: _firstNameController,
                                  hintText: 'First Name',
                                  icon: Icons.person,
                                  obscureText: false,
                                  focusNode: _firstNameFocusNode,
                                  autoCorrect: false,
                                  enableSuggestions: false,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context)
                                          .requestFocus(_lastNameFocusNode),
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
                                InputField(
                                  key: const ValueKey('lastName'),
                                  controller: _lastNameController,
                                  hintText: 'Last Name',
                                  icon: Icons.person,
                                  obscureText: false,
                                  focusNode: _lastNameFocusNode,
                                  autoCorrect: false,
                                  enableSuggestions: false,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context)
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
                                  key: const ValueKey('oldPassword'),
                                  controller: _oldPasswordController,
                                  hintText: 'Old Password',
                                  icon: Icons.lock,
                                  obscureText: true,
                                  focusNode: _oldPasswordFocusNode,
                                  autoCorrect: false,
                                  enableSuggestions: false,
                                  textCapitalization: TextCapitalization.none,
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context)
                                          .requestFocus(_passwordFocusNode),
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a valid password.';
                                    }
                                    if (_oldPasswordController.text !=
                                        _initValues.password) {
                                      return 'Old password is wrong';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _userPassword = value!;
                                  },
                                ),
                                InputField(
                                  key: const ValueKey('newPassword'),
                                  controller: _passwordController,
                                  hintText: 'New Password',
                                  icon: Icons.lock,
                                  obscureText: true,
                                  focusNode: _passwordFocusNode,
                                  autoCorrect: false,
                                  enableSuggestions: false,
                                  textCapitalization: TextCapitalization.none,
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context).requestFocus(
                                          _confirmPasswordFocusNode),
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a valid password.';
                                    }
                                    if (value.length < 7) {
                                      return 'Password must be at least 7 characters long';
                                    }
                                    if (_passwordController.text
                                                .toLowerCase()
                                                .trim() ==
                                            _firstNameController.text
                                                .toLowerCase()
                                                .trim() ||
                                        _passwordController.text
                                                .toLowerCase()
                                                .trim() ==
                                            '${_firstNameController.text}${_lastNameController.text}'
                                                .toLowerCase()
                                                .trim() ||
                                        _passwordController.text
                                                .toLowerCase()
                                                .trim() ==
                                            _lastNameController.text
                                                .toLowerCase()
                                                .trim() ||
                                        _passwordController.text
                                                .toLowerCase()
                                                .trim() ==
                                            _emailController.text
                                                .toLowerCase()
                                                .trim()) {
                                      return 'Password must be different from email and name';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _userPassword = value!;
                                  },
                                ),
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
                              ],
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Custom.elevatedButton(
                                  context: context,
                                  title:
                                      _isLoading ? Custom.loadingText : 'Done',
                                  onPress: _isLoading ? () {} : _submit,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
