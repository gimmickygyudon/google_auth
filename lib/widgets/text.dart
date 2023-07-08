import 'package:flutter/material.dart';

class TextIcon extends StatelessWidget {
  const TextIcon({super.key, required this.label, required this.icon, this.bgRadius, this.iconSize});

  final String label;
  final IconData icon;
  final double? bgRadius, iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: bgRadius ?? 12,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
          child: Icon(icon, size: iconSize ?? 18, color: Theme.of(context).colorScheme.primary)
        ),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(
          letterSpacing: 0
        )),
      ],
    );
  }
}