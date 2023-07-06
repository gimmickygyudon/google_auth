import 'package:flutter/material.dart';

class ChipSmall extends StatelessWidget {
  const ChipSmall({super.key, required this.bgColor, required this.label, required this.labelColor, this.trailing});

  final Color bgColor, labelColor;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      padding: const EdgeInsets.fromLTRB(0, 1, 0, 0),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      backgroundColor: bgColor,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 4),
          trailing ?? const SizedBox()
        ],
      ),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: labelColor
      ),
    );
  }
}

class ChipOffline extends StatelessWidget {
  const ChipOffline({super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Row(
        children: [
          Icon(Icons.offline_bolt, size: 16, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 4),
          const Text('Offline'),
        ],
      ),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.error,
      ),
      side: BorderSide(color: Theme.of(context).colorScheme.error),
      padding: EdgeInsets.zero,
      visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
    );
  }
}
