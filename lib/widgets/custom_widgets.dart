import 'package:flutter/material.dart';

import '../main.dart';

class Custom {
  static String loadingText = '...';
  static Container containerStyled = Container(
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
  );

  static Container containerLoading(double deviceHeight) => Container(
        height: deviceHeight,
        color: MyApp.appPrimaryColor.withOpacity(0.75),
        child: const Center(
          child: CircularProgressIndicator(color: MyApp.appSecondaryColor),
        ),
      );

  static AppBar appBar(GlobalKey<ScaffoldState> scaffoldKey, String title) =>
      AppBar(
        title: titleText(title),
        leading: IconButton(
          icon: icon(Icons.menu, MyApp.appSecondaryColor),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
      );

  static Future<dynamic> showCustomDialog(
      BuildContext context, String message) async {
    return await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              // title: const Text(''),
              content: normalText(message),
              actions: [
                Center(
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Okay')),
                )
              ],
            ));
  }

  static Widget normalTextOrange(String title) => Text(
        title,
        style: const TextStyle(
          color: MyApp.appSecondaryColor,
          // letterSpacing: 1.5,
          fontSize: 20.0,
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
          fontSize: 25.0,
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
        child: title == loadingText
            ? const Center(
                child: CircularProgressIndicator(
                  color: MyApp.appSecondaryColor,
                ),
              )
            : titleText(title));
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
    this.initialValue,
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
  final String? initialValue;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late bool obscureText;

  @override
  void initState() {
    super.initState();
    obscureText = (widget.hintText == 'Password' ||
            widget.hintText == 'New Password' ||
            widget.hintText == 'Old Password' ||
            widget.hintText == 'Confirm Password')
        ? true
        : false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: TextFormField(
          initialValue: widget.initialValue,
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
                    widget.hintText == 'Old Password' ||
                    widget.hintText == 'New Password' ||
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
      ),
    );
  }
}
