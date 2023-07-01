import 'package:flutter/material.dart';

class ListTileOptions extends StatelessWidget {
  const ListTileOptions({super.key, required this.title, required this.subtitle, required this.options, required this.onChanged});

  final String title, subtitle;
  final List options;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Theme.of(context).colorScheme.inversePrimary
      ),
      child: ListTileTheme(
        dense: true,
        minVerticalPadding: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
            child: Icon(
              Icons.local_shipping,
              size: 24,
              color: Theme.of(context).colorScheme.primary
            ),
          ),
          trailing: const Icon(Icons.arrow_drop_down, size: 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
          collapsedBackgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          title: Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
          )),
          subtitle: Text(subtitle, style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            height: 0
          )),
          children: options.map((element) {
            return RadioListTile(
              selected: element['name'] == subtitle,
              value: element['name'],
              groupValue: subtitle,
              onChanged: (e) {
                onChanged(e);
              },
              selectedTileColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
              title: Text(element['name'], style: Theme.of(context).textTheme.titleSmall?.copyWith(
                height: 0
              )),
              subtitle: Text(element['description'], style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                height: 0,
                letterSpacing: 0
              )),
            );
          }).toList(),
        ),
      ),
    );
  }
}