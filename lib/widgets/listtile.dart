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

class ListTileToast extends StatelessWidget {
  const ListTileToast({
    super.key, this.leading, this.title, this.subtitle, this.action, this.onClose
  });

  final Widget? leading;
  final String? title, subtitle;
  final Widget? action;
  final Function? onClose;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      leading: leading,
      horizontalTitleGap: 8,
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary.withOpacity(0.5))),
      tileColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
      title: title != null ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title!),
          IconButton(
            onPressed: () => onClose!(),
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              iconSize: MaterialStatePropertyAll(20)
            ),
            icon: const Icon(Icons.close)
          )
        ],
      ) : null,
      titleTextStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        height: 2,
        letterSpacing: 0
      ),
      subtitle: subtitle != null ? Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(subtitle!),
            const SizedBox(height: 10),
            action ?? const SizedBox()
          ],
        ),
      ) : null,
      subtitleTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: 10,
        letterSpacing: 0
      ),
    );
  }
}

class ListTileCheckBox extends StatelessWidget {
  const ListTileCheckBox({super.key, required this.selected, required this.onChanged, required this.title});

  final String title;
  final bool selected;
  final Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListTileTheme(
        horizontalTitleGap: 12,
        child: CheckboxListTile(
          title: Text(title, style: Theme.of(context).textTheme.labelMedium?.copyWith(
            letterSpacing: 0,
            color: selected ? Theme.of(context).colorScheme.primary : null
          )),
          dense: true,
          selected: selected,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          contentPadding: EdgeInsets.zero,
          checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          controlAffinity: ListTileControlAffinity.leading,
          value: selected,
          onChanged: (value) {
            onChanged(value!);
          },
        ),
      ),
    );
  }
}