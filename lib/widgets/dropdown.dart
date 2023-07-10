import 'package:flutter/material.dart';

import '../functions/color.dart';

class DropdownLight extends StatelessWidget {
  const DropdownLight({super.key, required this.value, required this.values, required this.onChanged});

  final String? value;
  final List<String> values;
  final Function(dynamic value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 2, 4, 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6)
      ),
      child: DropdownButton(
        isDense: true,
        underline: const SizedBox(),
        value: value,
        borderRadius: BorderRadius.circular(8),
        onChanged: (value) => onChanged(value),
        elevation: 0,
        dropdownColor: lighten(Theme.of(context).colorScheme.primaryContainer, 0.05),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0
        ),
        iconEnabledColor: Theme.of(context).colorScheme.primary,
        items: values.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e)
          );
        }).toList()
      ),
    );
  }
}