import 'package:custom_cam/src/custom_icons_icons.dart';
import 'package:custom_cam/src/custom_theme.dart';
import 'package:flutter/material.dart';

class CameraAlert extends StatelessWidget {

  final String title;
  final String description;
  final String positiveInput;
  final String negativeInput;
  final VoidCallback positiveCallback;

  const CameraAlert({Key? key, required this.title, required this.description, required this.positiveInput, required this.negativeInput, required this.positiveCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(CustomIcons.warning, size: 55, color: CustomTheme.secondaryColor),
          Padding(
            padding: const EdgeInsets.only(top: 13.0),
            child: SizedBox(width: 250, child: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF333333), fontSize: 18, fontWeight: FontWeight.w700))),
          )
        ],
      ),
      content: SizedBox(width: 250, child: Text(description, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF2C2C2C), fontSize: 14, fontWeight: FontWeight.w400))),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    positiveCallback();
                  },
                  style: CustomTheme.textButtonStyle,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(positiveInput),
                  )
              ),
            ),
            if (negativeInput.isNotEmpty)
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                      foregroundColor: CustomTheme.primaryColor
                  ),
                  child: Text(negativeInput)
              )
          ],
        )
      ],
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14))
      ),
    );
  }
}
