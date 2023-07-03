import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_auth/functions/conversion.dart';
import 'package:google_auth/functions/location.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/functions/validate.dart';
import 'package:google_auth/strings/item.dart';
import 'package:google_auth/widgets/profile.dart';
import 'package:google_auth/widgets/snackbar.dart';

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
    barrierColor: Colors.black45,
    pageBuilder: (context, animation, secondaryAnimation) {
      return OrderDialog(name: name, brand: brand, hero: hero, dimensions: dimensions, weights: weights, onPressed: onPressed);
    })
  );
}

Future<void> showDeleteDialog({required BuildContext context, required Function onConfirm}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) => DeleteDialog(onConfirm: onConfirm),
  );
}

Future showAddressDialog({
  required BuildContext context,
  required List locations,
  required String hero
}) {
  return Navigator.push(context, PageRouteBuilder(
    opaque: false,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    pageBuilder: (context, animation, secondaryAnimation) {
      return AddAddressDialog(locations: locations, hero: hero);
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
      contentPadding: const EdgeInsets.fromLTRB(32, 38, 32, 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary)),
          onPressed: () => Navigator.pop(context),
          child: const Text('Kembali')
        ),
        TextButton(
          onPressed: () => widget.callback(context, source: widget.source, logintype: widget.from),
          style: Styles.buttonDanger(context: context),
          child: const Text(' Ya, Itu Saya ')
        )
      ],
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Center(child: UserProfile(source: widget.source)),
              const SizedBox(height: 10),
              Center(child: Text('+62 ${widget.source['phone_number']}', style: Theme.of(context).textTheme.labelLarge)),
            ],
          ),
          const Divider(height: 48),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.verified_user, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${widget.from} tersebut sudah terdaftar sebelumnya', style: Theme.of(context).textTheme.labelSmall)),
                ],
              ),
            ],
          ),
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
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(32, 12, 32, 24),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Akun dengan ${widget.from} tersebut belum terdaftar',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                letterSpacing: 0
              )
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary)),
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal')
        ),
        const SizedBox(width: 4),
        ElevatedButton(
          style: Styles.buttonForm(context: context),
          onPressed: () {
            Navigator.pop(context);
            widget.callback();
          },
          child: const Text('Daftar')
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
              autofocus: true,
              readOnly: true,
              initialValue: widget.value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
              decoration: Styles.inputDecorationForm(
                context: context,
                icon: Icon(widget.from == 'Nomor' ? Icons.phone : Icons.email_outlined),
                isPhone: widget.from == 'Nomor' ? true : false,
                placeholder: '',
                condition: true
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('Apakah anda ingin melanjutkan untuk mendaftar ?',
              style: Theme.of(context).textTheme.bodySmall
            ),
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
  late int index;

  late String weight;

  @override
  void initState() {
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

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight,
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Image.asset(ItemDescription.getLogo(widget.name), height: 40),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.cancel, size: 30)
          )
        ],
      ),
      body: SingleChildScrollView(
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
                    Flexible(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
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
                        labelStyle: Theme.of(context).textTheme.bodyLarge,
                        condition: true
                      ),
                      borderRadius: BorderRadius.circular(12),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.25
                      ),
                      isExpanded: true,
                      items: spesifications.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item)
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: jumlahController,
                      onChanged: (value) => setState(() => Validate.validateQuantity(context: context, value: value, textEditingController: jumlahController)),
                      keyboardType: TextInputType.number,
                      inputFormatters: [ FilteringTextInputFormatter.allow(RegExp("[0-9]")) ],
                      decoration: Styles.inputDecorationForm(
                        context: context,
                        placeholder: 'Jumlah',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: () => setJumlah(isPlus: false), icon: const Icon(Icons.remove), iconSize: 24, color: Theme.of(context).colorScheme.secondary),
                            IconButton(onPressed: () => setJumlah(isPlus: true), icon: const Icon(Icons.add), iconSize: 24, color: Theme.of(context).colorScheme.secondary),
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
                                  color: Theme.of(context).colorScheme.primary
                                ),
                              ),
                            ],
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: jumlahController.text.trim().isNotEmpty
                                ? () => widget.onPressed(count: jumlahController.text, index: index).whenComplete(() {
                                  showSnackBar(context, snackBarShop(duration: const Duration(seconds: 6), context: context, content: 'Pesanan Anda Masuk di Keranjang Belanja.'));
                                  Navigator.pop(context);
                                })
                                : null,
                              style: Styles.buttonForm(context: context),
                              icon: const Icon(Icons.local_shipping, size: 24),
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
      ),
    );
  }
}

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({super.key, required this.onConfirm});

  final Function onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.warning, size: 52),
      iconColor: Theme.of(context).colorScheme.error,
      titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w500
      ),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconPadding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            const SizedBox(height: 6),
            Text('Barang yang Anda pilih akan terhapus dari daftar pesanan.', style: Theme.of(context).textTheme.bodySmall?.copyWith(
              letterSpacing: 0,
              color: Theme.of(context).colorScheme.secondary
            )),
            const SizedBox(height: 24),
            Text('Hapus pesanan yang dipilih ?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            )),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary)),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        TextButton(
          style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.error)),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: const Text('Hapus'),
        ),
      ],
    );
  }
}

class AddAddressDialog extends StatefulWidget {
  const AddAddressDialog({super.key, required this.locations, required this.hero});

  final List locations;
  final String hero;

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  late TextEditingController nameController;
  late TextEditingController phonenumberController;

  late ValueNotifier isValidated;
  late List _locationName;

  @override
  void initState() {
    nameController = TextEditingController();
    phonenumberController = TextEditingController();
    isValidated = ValueNotifier(false);

    _locationName = ['Provinsi', 'Kota / Kabupaten', 'Kecamatan', 'Daerah', 'Alamat'];
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    phonenumberController.dispose();
    super.dispose();
  }

  setValidate() {
    if (nameController.text.trim().isNotEmpty && phonenumberController.text.trim().isNotEmpty) {
      isValidated.value = true;
    } else {
      isValidated.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Hero(
          tag: widget.hero,
          child: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: Themes.inputDecorationThemeForm(context: context)
            ),
            // TODO: Add Upload Photo Image
            // FIXME: Janky Double Context
            child: AlertDialog(
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500
              ),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              iconPadding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.help_outline, color: Theme.of(context).colorScheme.secondary),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text('Tambahkan alamat ini ke lokasi pemesanan.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            letterSpacing: 0,
                            height: 0,
                            color: Theme.of(context).colorScheme.secondary
                          )),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 24),
                      height: 1,
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = widget.locations.length - 1; i >= 0; i--) ...[
                          Visibility(
                            visible: i == 3 ? false : true,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(widget.locations[i]['icon'], size: 20, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Flexible(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_locationName[i], style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary
                                    )),
                                    const SizedBox(height: 4),
                                    Text(widget.locations[i]['value'], style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      height: 0
                                    )),
                                  ],
                                )),
                              ],
                            ),
                          ),
                          if(i != 3) const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 30),
                        TextField(
                          onChanged: (value) => setValidate(),
                          controller: nameController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.name,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.3),
                          decoration: Styles.inputDecorationForm(
                            context: context,
                            placeholder: 'Nama Lokasi / Tempat',
                            labelStyle: Theme.of(context).textTheme.bodyLarge,
                            hintText: 'Gudang #2',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            condition: nameController.text.trim().isNotEmpty
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          onChanged: (value) => setValidate(),
                          controller: phonenumberController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.3),
                          decoration: Styles.inputDecorationForm(
                            context: context,
                            labelStyle: Theme.of(context).textTheme.bodyLarge,
                            placeholder: 'Kontak Telepon',
                            isPhone: true,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            condition: phonenumberController.text.trim().isNotEmpty
                          ),
                        )
                      ]
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: <Widget>[
                TextButton(
                  style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary)),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ValueListenableBuilder(
                  valueListenable: isValidated,
                  builder: (context, isValidated, child) {
                    return TextButton(
                      onPressed: isValidated ? () {
                        LocationManager location = LocationManager(
                          name: nameController.text,
                          phone_number: phonenumberController.text,
                          province: widget.locations[0]['value'],
                          district: widget.locations[1]['value'],
                          subdistrict: widget.locations[2]['value'],
                          suburb: widget.locations[3]['value'],
                          street: widget.locations[4]['value']
                        );

                        LocationManager.add(location.toMap()).whenComplete(() {
                          Navigator.pop(context, true);
                        });
                      } : null,
                      style: Styles.buttonForm(context: context),
                      child: const Text('Simpan'),
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}