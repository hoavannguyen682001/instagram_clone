import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final Function()? function;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final String textButton;
  const FollowButton(
      {Key? key,
      this.function,
      required this.backgroundColor,
      required this.borderColor,
      required this.textColor,
      required this.textButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: TextButton(
        onPressed: function,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.6,
          height: 27,
          child: Text(
            textButton,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
