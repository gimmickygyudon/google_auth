import 'package:flutter/material.dart';

class LabelSearch extends StatelessWidget {
  const LabelSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.only(left: 12, right: 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12)
        ),
        // color: Theme.of(context).colorScheme.surfaceVariant
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            VerticalDivider(indent: 8, endIndent: 8, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(width: 4),
            Icon(Icons.search, color: Theme.of(context).colorScheme.inverseSurface, size: 22),
            const SizedBox(width: 4),
            Text('Pencarian', style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.inverseSurface
            ))
          ],
        ),
      )
    );
  }
}