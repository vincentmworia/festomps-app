import 'package:flutter/material.dart';

import '../main.dart';

class Custom {
  static String loadingText = ' ';

  static Widget normalTextOrange(String title) => Text(
        title,
        style: const TextStyle(
          color: MyApp.appSecondaryColor,
          // letterSpacing: 1.5,
          fontSize: 18.0,
        ),
      );

  static Widget normalText(String title) => Text(
        title,
        style: const TextStyle(
          color: MyApp.appSecondaryColor2,
          // letterSpacing: 1.5,
          fontSize: 18.0,
        ),
      );

  static Widget titleText(String title) => Text(
        title,
        style: const TextStyle(
          color: MyApp.appSecondaryColor,
          letterSpacing: 5,
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
      );

  static Widget icon(IconData icon, Color color) => Icon(
        icon,
        size: 30.0,
        color: color,
      );

  static Widget elevatedButton({
    required BuildContext context,
    required String title,
    required void Function()? onPress,
  }) {
    final Size bnSize = Size(MediaQuery.of(context).size.width / 1.5, 60);
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            minimumSize: bnSize,
            maximumSize: bnSize,
            primary: MyApp.appPrimaryColor,
            padding: const EdgeInsets.all(10),
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0))),
        onPressed: title == loadingText ? null : () => onPress!(),
        child: titleText(title));
  }
}

class InputField extends StatefulWidget {
  const InputField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.obscureText,
    this.focusNode,
    required this.autoCorrect,
    required this.enableSuggestions,
    this.textCapitalization,
    this.onFieldSubmitted,
    this.textInputAction,
    this.validator,
    this.onSaved,
  }) : super(key: key);
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final FocusNode? focusNode;
  final bool autoCorrect;
  final bool enableSuggestions;
  final TextCapitalization? textCapitalization;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late bool obscureText;

  @override
  void initState() {
    super.initState();
    obscureText =
        (widget.hintText == 'Password' || widget.hintText == 'Confirm Password')
            ? true
            : false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: TextFormField(
        key: widget.key,
        controller: widget.controller,
        keyboardType: TextInputType.emailAddress,
        focusNode: widget.focusNode,
        autocorrect: widget.autoCorrect,
        enableSuggestions: widget.enableSuggestions,
        textCapitalization:
            widget.textCapitalization ?? TextCapitalization.none,
        obscureText: obscureText,
        onFieldSubmitted: widget.onFieldSubmitted,
        textInputAction: widget.textInputAction,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
          fillColor: Colors.white,
          filled: true,
          hintText: widget.hintText,
          prefixIcon: Custom.icon(widget.icon, MyApp.appPrimaryColor),
          suffixIcon: (widget.hintText == 'Password' ||
                  widget.hintText == 'Confirm Password')
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                  child: obscureText
                      ? Custom.icon(Icons.visibility_off, Colors.grey)
                      : Custom.icon(Icons.visibility, MyApp.appPrimaryColor))
              : null,
        ),
        validator: widget.validator,
        onSaved: widget.onSaved,
      ),
    );
  }
}
