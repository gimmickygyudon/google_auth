import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showSnackBar(BuildContext context, SnackBar snackBar) {
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void hideSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
}

SnackBar snackBarShop({
  required BuildContext context,
  required String content,
  Duration duration = const Duration(seconds: 4),
  Color? color,
}) {
  return SnackBar(
    padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
    duration: duration,
    backgroundColor: Theme.of(context).colorScheme.primary.withBlue(100),
    showCloseIcon: true,
    content: Consumer(
      builder: (context, value, child) => Row(
        children: [
          const SizedBox(width: 6),
          Badge(
            largeSize: 20,
            label: const Text('+1'),
            child: Icon(Icons.shopping_bag, color: Theme.of(context).colorScheme.surface)
          ),
          const SizedBox(width: 16),
          Text(
            content,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.surface,
              letterSpacing: 0
            ),
          ),
        ],
      ),
    ),
  );
}

SnackBar snackBarComplete({
  required BuildContext context,
  required String content,
  Duration duration = const Duration(seconds: 4)
}) {
  return SnackBar(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
    margin: const EdgeInsets.fromLTRB(15, 0, 15, 20),
    duration: duration,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    content: Consumer(
      builder: (context, value, child) => Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.primary, width: 3))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 6),
                Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  content,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    letterSpacing: 0
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () => hideSnackBar(context),
              style: const ButtonStyle(
                visualDensity: VisualDensity(vertical: -4, horizontal: -4)
              ),
              icon: const Icon(Icons.close)
            )
          ],
        ),
      ),
    ),
  );
}

SnackBar snackBarError({
  required BuildContext context,
  required String content,
  IconData? icon = Icons.warning
  }) {
  return SnackBar(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
    margin: const EdgeInsets.fromLTRB(15, 0, 15, 20),
    duration: const Duration(seconds: 10),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    content: Consumer(
      builder: (context, value, child) => Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.error, width: 3))
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 90),
              child: Row(
                children: [
                  const SizedBox(width: 6),
                  Icon(icon, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      content,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.inverseSurface,
                        letterSpacing: 0
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => hideSnackBar(context),
              style: const ButtonStyle(
                visualDensity: VisualDensity(vertical: -4, horizontal: -4)
              ),
              icon: const Icon(Icons.close)
            )
          ],
        ),
      ),
    ),
  );
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
