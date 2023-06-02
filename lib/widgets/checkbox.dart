import 'package:flutter/material.dart';

class CheckboxPassword extends StatelessWidget {
  const CheckboxPassword({super.key, required this.onChanged, required this.visibility});

  final Function onChanged;
  final bool visibility;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
      child: CheckboxListTile(
        onChanged: (value) => onChanged(value),
        value: visibility, 
        contentPadding: EdgeInsets.zero,
        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Text('Tampilkan Sandi', style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 0)),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
