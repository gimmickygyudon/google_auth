import 'package:flutter/material.dart';

class ChipSmall extends StatelessWidget {
  const ChipSmall({
    super.key, this.bgColor, required this.label, this.labelColor, this.trailing, this.borderRadius, this.leading, this.textStyle
  });

  final Color? bgColor, labelColor;
  final String label;
  final Widget? trailing, leading;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      padding: const EdgeInsets.fromLTRB(0, 1, 0, 0),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.circular(4)),
      backgroundColor: bgColor ?? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          leading ?? const SizedBox(),
          SizedBox(width: leading != null ? 4 : 0),
          Text(label),
          SizedBox(width: trailing != null ? 4 : 0),
          trailing ?? const SizedBox()
        ],
      ),
      labelStyle: textStyle ?? Theme.of(context).textTheme.labelSmall?.copyWith(
        color: labelColor ?? Theme.of(context).colorScheme.primary
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
