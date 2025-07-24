import 'package:firstapp/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
    context: context, 
    title: 'An error occured', 
    content: text, 
    optionsBuilder: () => {
      'OK': null,
    },
  );
}