import 'package:flutter/material.dart';

class InfoSmallWidget extends StatelessWidget {
  const InfoSmallWidget({super.key, required this.message, this.icon, this.color, this.padding, this.hide});

  final String message;
  final IconData? icon;
  final Color? color;
  final EdgeInsets? padding;
  final bool? hide;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        height: hide == true ? 0 : null,
        child: AnimatedOpacity(
          curve: Curves.ease,
          duration: const Duration(milliseconds: 400),
          opacity: hide == true ? 0 : 1,
          child: Container(
            padding: padding ?? const EdgeInsets.all(8),
            color: color?.withOpacity(0.5) ?? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
            child: Row(
              children: [
                const SizedBox(width: 4),
                Icon(icon ?? Icons.info_outline, size: 16, color: color ?? Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color ?? Theme.of(context).colorScheme.primary,
                    letterSpacing: 0
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
