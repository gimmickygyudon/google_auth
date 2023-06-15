import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_auth/functions/conversion.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/strings/item.dart';
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

Future<void> showUnRegisteredUser(BuildContext context, { 
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

Future<void> showOrderDialog({
  required BuildContext context,
  required String name,
  required String brand,
  required String hero,
  required List dimensions,
  required List weights,
  required Function onPressed
}) {
  return Navigator.push(context, PageRouteBuilder(
    opaque: false,
    barrierDismissible: true,
    barrierColor: Colors.black26,
    pageBuilder: (context, animation, secondaryAnimation) {
      return OrderDialog(name: name, brand: brand, hero: hero, dimensions: dimensions, weights: weights, onPressed: onPressed);
    })
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
      surfaceTintColor: Theme.of(context).colorScheme.inversePrimary,
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text('${widget.from} sudah terdaftar sebelumnya', style: Theme.of(context).textTheme.titleMedium)),
        ],
      ),
      actions: [
        TextButton(
          style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary)),
          onPressed: () => Navigator.pop(context), 
          child: const Text('Batal')
        ),
        TextButton(
          onPressed: () => widget.callback(context, source: widget.source, logintype: widget.from), 
          child: const Text('Ya, Itu Saya')
        )
      ],
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: UserProfile(source: widget.source)),
          const SizedBox(height: 24),
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
          Theme(
            data: Theme.of(context).copyWith(inputDecorationTheme: Themes.inputDecorationThemeForm(context: context)),
            child: TextFormField(
              readOnly: true,
              focusNode: _focusNode,
              initialValue: widget.value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
              decoration: Styles.inputDecorationForm(
                context: context, 
                icon: Icon(widget.from == 'Nomor' ? Icons.phone : Icons.email_outlined),
                isPhone: widget.from == 'Nomor' ? true : false,
                placeholder: '', 
                condition: false
              ),
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

class OrderDialog extends StatefulWidget {
  const OrderDialog({
    super.key, 
    required this.name, 
    required this.brand, 
    required this.hero, 
    required this.dimensions, 
    required this.onPressed, 
    required this.weights, 
  });

  final String name, brand, hero;
  final List dimensions, weights;
  final Function onPressed;

  @override
  State<OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<OrderDialog> {
  late String spesification;
  late List spesifications;
  late TextEditingController jumlahController;
  late bool isValidated;
  late int index;

  late String weight;

  @override
  void initState() {
    isValidated = false;
    index = 0;
    weight = widget.weights[index];

    spesification = '${widget.dimensions[index]}  •  ${widget.weights[index]} Kg';
    spesifications = getSpesifications();

    jumlahController = TextEditingController();
    super.initState();
  }

  List getSpesifications() {
    List list = List.empty(growable: true);
    int i = 0;

    for (String element in widget.dimensions) { 
      list.add('$element  •  ${widget.weights[i]} Kg');
      i++;
    }

    return list;
  }

  void validate(String value) {
    if (value.isNotEmpty) {
      if (int.parse(value) < 1) {
        jumlahController.text = '';
      } 
    }

    if (value.trim().isNotEmpty || value.trim() != '0') {
      setState(() {
        isValidated = true;
      }); 
    } else {
      setState(() {
        isValidated = false;
      });
    }
  }

  void setJumlah({required bool isPlus}) {
    setState(() {
      if (jumlahController.text.trim().isEmpty) jumlahController.text = '0';

      if (isPlus) {
        jumlahController.text = (int.parse(jumlahController.text) + 1).toString();
      } else {
        jumlahController.text = (int.parse(jumlahController.text) - 1).toString();
        if (int.parse(jumlahController.text) <= 0) jumlahController.text = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (jumlahController.text.trim().isNotEmpty) {
      weight = setWeight(weight: double.parse(widget.weights[index]), count: double.parse(jumlahController.text));
    }

    return Center(
      child: Hero(
        tag: widget.hero,
        child: Material(
          type: MaterialType.transparency,
          child: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: Themes.inputDecorationThemeForm(context: context)
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(25.7)
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(ItemDescription.getLogo(widget.name), width: 200, fit: BoxFit.cover),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.cancel, size: 30)
                      )
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 4,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(child: Image.asset(ItemDescription.getImage(widget.name), fit: BoxFit.cover)),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background
                            ),
                            child: Row(
                              children: [
                                Image.asset('assets/logo IBM p C.png', height: 18),
                                const SizedBox(width: 8),
                                Text(widget.name.toTitleCase(), style: Theme.of(context).textTheme.titleMedium),
                              ],
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField(
                    value: spesification,
                    onChanged: (value) {
                      setState(() {
                        spesification = value.toString();
                        index = spesifications.indexOf(value);
                      });
                    },
                    decoration: Styles.inputDecorationForm(
                      context: context, 
                      placeholder: 'Spesifikasi',
                      condition: true
                    ),
                    borderRadius: BorderRadius.circular(12),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.25
                    ),
                    items: spesifications.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Row(
                          children: [
                            const Icon(Icons.view_in_ar),
                            const SizedBox(width: 12),
                            Text(item),
                          ],
                        )
                      );
                    }).toList(), 
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: jumlahController,
                    onChanged: (value) {
                      setState(() {
                        validate(value);
                      });
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [ FilteringTextInputFormatter.allow(RegExp("[0-9]")) ],
                    decoration: Styles.inputDecorationForm(
                      context: context, 
                      placeholder: 'Jumlah',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(onPressed: () => setJumlah(isPlus: false), icon: const Icon(Icons.remove_circle_outline), iconSize: 24, color: Theme.of(context).colorScheme.secondary),
                          IconButton(onPressed: () => setJumlah(isPlus: true), icon: const Icon(Icons.add_circle_outline), iconSize: 24, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 8)
                        ],
                      ),
                      condition: jumlahController.text.trim().isNotEmpty
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        style: ButtonStyle(
                          foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary)
                        ),
                        child: const Text('Batal')
                      ),
                      Row(
                        children: [
                          if (jumlahController.text.trim().isNotEmpty) ...[
                            Text(weight, 
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).primaryColor
                              ),
                            ), 
                          ],
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: jumlahController.text.trim().isNotEmpty
                              ? () => widget.onPressed(count: jumlahController.text, index: index).whenComplete(() {
                                Navigator.pop(context);
                              })
                              : null,
                            style: Styles.buttonForm(context: context),
                            icon: const Icon(Icons.shopping_bag), 
                            label: const Text('Pesan')
                          ),
                        ],
                      )
                    ]
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
