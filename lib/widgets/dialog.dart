import 'package:flutter/material.dart';
import 'package:google_auth/widgets/profile.dart';

import '../styles/theme.dart';

Future<void> showRegisteredUser(BuildContext context, { 
    required Map<String, dynamic> source, 
    required Function callback, 
    required String from 
  }) {
  return showDialog(
    context: context, 
    builder: (BuildContext context) {
      return DialogRegisteredUser(source: source, callback: callback, from: from);
    }
  );
}

Future <void> showUnRegisteredUser(BuildContext context, { 
    required String value, 
    required Function callback, 
    required String from,
    Map? source
  }) {
  return showDialog(
    context: context, 
    builder: (BuildContext context) {
      return DialogUnRegisteredUser(
        value: value, 
        callback: callback, 
        from: from, 
        source: source
      );
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
          child: const Text('Masuk')
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
            leading: const Icon(Icons.account_circle, size: 42),
            title: Text(widget.source['user_name'], style: Theme.of(context).textTheme.bodyLarge),
            subtitle: Text(widget.source[widget.from == 'Nomor' ? 'phone_number' : 'user_email'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary)),
          ),
          Text('Apakah itu anda ?', style: Theme.of(context).textTheme.bodyMedium)
        ],
      ),
    );
  }
}

class DialogUnRegisteredUser extends StatefulWidget {
  const DialogUnRegisteredUser({super.key, required this.value, required this.callback, required this.from, this.source});

  final String value;
  final Function callback;
  final String from;
  final Map? source;

  @override
  State<DialogUnRegisteredUser> createState() => _DialogUnRegisteredUserState();
}

class _DialogUnRegisteredUserState extends State<DialogUnRegisteredUser> {
  late FocusNode _focusNode;

  @override
  void initState() {
    _focusNode = FocusNode(canRequestFocus: false);
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Akun dengan ${widget.from} tersebut belum terdaftar', style: Theme.of(context).textTheme.titleMedium),
      actions: [
        TextButton(
          style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary)),
          onPressed: () => Navigator.pop(context), 
          child: const Text('Batal')
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.callback();
          }, 
          child: const Text('Masuk')
        )
      ],
      content: widget.from == 'Google' 
      ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          UserProfile(source: widget.source),
          const SizedBox(height: 10),
        ],
      )
      : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          TextFormField(
            readOnly: true,
            focusNode: _focusNode,
            initialValue: widget.value,
            decoration: Styles.inputDecorationForm(
              context: context, 
              icon: Icon(widget.from == 'Nomor' ? Icons.phone : Icons.email_outlined),
              placeholder: '', 
              condition: false
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('Apakah anda ingin melanjutkan untuk mendaftar ?', style: Theme.of(context).textTheme.bodySmall),
          )
        ],
      ),
    );
  }
}
