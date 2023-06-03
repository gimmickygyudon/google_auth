import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, SnackBar snackBar) {
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void hideSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
}

SnackBar snackBarAuth({required BuildContext context, required String content}) {
  return SnackBar(
    action: SnackBarAction(label: 'OK', onPressed: () => hideSnackBar(context)),
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
    backgroundColor: Theme.of(context).colorScheme.inverseSurface,
    content: Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        content,
        style: TextStyle(color: Theme.of(context).colorScheme.surface, letterSpacing: 0.5),
      ),
    ),
  );
}

SnackBar snackBarAuthProgress(BuildContext context, String content) {
  return SnackBar(
    duration: const Duration(days: 365),
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
    backgroundColor: Theme.of(context).colorScheme.inverseSurface,
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            content,
            style: TextStyle(color: Theme.of(context).colorScheme.surface, letterSpacing: 0.5),
          ),
        ),
      ],
    ),
  );
}
