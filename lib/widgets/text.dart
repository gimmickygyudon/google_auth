import 'package:flutter/material.dart';

class TextIcon extends StatelessWidget {
  const TextIcon({super.key, required this.label, required this.icon, this.bgRadius, this.iconSize, this.disable, this.textStyle});

  final String label;
  final IconData icon;
  final double? bgRadius, iconSize;
  final bool? disable;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: bgRadius ?? 12,
          backgroundColor: disable == true
          ? Theme.of(context).colorScheme.onInverseSurface
          : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
          child: Icon(icon, size: iconSize ?? 18, color: disable == true ? Theme.of(context).colorScheme.inverseSurface : Theme.of(context).colorScheme.primary)
        ),
        const SizedBox(width: 10),
        Text(label, style: textStyle ?? Theme.of(context).textTheme.titleMedium?.copyWith(
          letterSpacing: 0
        )),
      ],
    );
  }
}