import 'package:flutter/material.dart';

typedef ShareNoteCallback = Future<void> Function(String email);

Future<void> showShareNoteDialog({
  required BuildContext context,
  required ShareNoteCallback onShare,
}) {
  final controller = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Notiz teilen'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          hintText: 'E-Mail-Adresse eingeben',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Dialog schließen
          },
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () async {
            final email = controller.text.trim();
            if (email.isNotEmpty) {
              await onShare(email);
              Navigator.of(context).pop(); // Nach dem Teilen schließen
            }
          },
          child: const Text('Teilen'),
        ),
      ],
    ),
  );
}
