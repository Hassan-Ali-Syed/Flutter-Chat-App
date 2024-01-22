import 'package:flutter/material.dart';

class UiHelper {
  static void showLoadingDialogue(BuildContext context, String title) {
    AlertDialog loadingDialog = AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(
            height: 30,
          ),
          Text(title)
        ],
      ),
    );
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return loadingDialog;
        });
  }

  static void showAlertDialogue(
      BuildContext context, String title, String content) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'))
      ],
    );
    showDialog(
        context: context,
        builder: (content) {
          return alertDialog;
        });
  }
}
