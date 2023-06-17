import 'package:flutter/material.dart';

class LabelSearch extends StatelessWidget {
  const LabelSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      padding: const EdgeInsets.only(left: 6, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, color: Theme.of(context).colorScheme.primary, size: 22),
          const SizedBox(width: 2),
          Text('Cari', style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary
          ))
        ],
      )
    );
  }
}