import 'package:flutter/material.dart';

Future<void> showRegisteredUser(BuildContext context, Map<String, dynamic> source, Function callback, String from) {
  return showDialog(
    context: context, 
    builder: (BuildContext context) {
      return DialogRegisteredUser(source: source, callback: callback, from: from,);
    }
  );
}

class DialogRegisteredUser extends StatefulWidget {
  const DialogRegisteredUser({super.key, required this.source, required this.callback, required this.from});

  final Map<String, dynamic> source;
  final Function callback;
  final String from;

  @override
  State<DialogRegisteredUser> createState() => _DialogRegisteredUserState();
}

class _DialogRegisteredUserState extends State<DialogRegisteredUser> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('${widget.from} sudah terdaftar sebelumnya', style: Theme.of(context).textTheme.titleMedium),
      actions: [
        TextButton(
          style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary)),
          onPressed: () => Navigator.pop(context), 
          child: const Text('Batal')
        ),
        TextButton(
          onPressed: () => widget.callback(context, widget.source, widget.from), 
          child: const Text('Ya, Itu Saya')
        )
      ],
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: () {},
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.account_circle, size: 36),
            title: Text(widget.source['user_name'], style: Theme.of(context).textTheme.bodyLarge),
            subtitle: Text(widget.source[widget.from == 'Nomor' ? 'phone_number' : 'user_email'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary)),
          ),
          Text('Apakah itu anda ?', style: Theme.of(context).textTheme.bodyMedium)
        ],
      ),
    );
  }
}
