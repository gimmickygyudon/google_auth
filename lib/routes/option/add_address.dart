import 'package:flutter/material.dart';

import '../../styles/theme.dart';
import '../../widgets/button.dart';

class AddressAddRoute extends StatefulWidget {
  const AddressAddRoute({super.key, required this.hero});

  final String hero;

  @override
  State<AddressAddRoute> createState() => _AddressAddRouteState();
}

class _AddressAddRouteState extends State<AddressAddRoute> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Themes.inputDecorationThemeForm(context: context)
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alamat Baru'),
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              ButtonListTile(
                icon: Icons.my_location,
                title: const Text('Lokasi Sekarang'),
                subtitle: Text('Jl. Jalan di jalanin no. 69', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  letterSpacing: 0,
                  color: Theme.of(context).colorScheme.secondary
                ))
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                child: Text('Masukan Alamat Anda atau Gunakan Lokasi Sekarang.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    letterSpacing: 0
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {});
                  },
                  maxLines: 3,
                  decoration: Styles.inputDecorationForm(
                    alignLabelWithHint: true,
                    // prefix: Transform.translate(
                    //   offset: const Offset(-6, 6),
                    //   child: const Icon(Icons.location_on)
                    // ),
                    context: context,
                    labelStyle: const TextStyle(fontSize: 16),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    placeholder: 'Alamat',
                    hintText: 'Jl. Rogonoto No.57B, Gondorejo Ledok',
                    condition: false
                  ),
                ),
              ),
            ],
          )
        )
      ),
    );
  }
}