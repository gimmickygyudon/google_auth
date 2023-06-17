import 'package:flutter/material.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/button.dart';
import 'package:google_auth/widgets/label.dart';

class AddressRoute extends StatefulWidget {
  const AddressRoute({super.key, required this.hero});

  final String hero;

  @override
  State<AddressRoute> createState() => _AddressRouteState();
}

class _AddressRouteState extends State<AddressRoute> {
  // TODO: Do This Later
  late SearchController _searchController;
  late TextEditingController searchController;

  late String deliveryType;
  List<Map> deliveryTypes = [
    {
      'name': 'FRANCO',
      'description': 'Barang dikirim ke lokasi tujuan'
    }, {
      'name': 'LOCO',
      'description': 'Barang di ambil sendiri'
    }
  ];

  @override
  void initState() {
    searchController = SearchController();
    deliveryType = deliveryTypes.first['name'];
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Themes.inputDecorationThemeForm(context: context)
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ubah Pengiriman'),
            ],
          ),
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: Styles.inputDecorationForm(
                  suffixIcon: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: LabelSearch(),
                  ),
                  context: context,
                  placeholder: 'Cari Alamat',
                  condition: searchController.text.trim().isNotEmpty
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    splashColor: Theme.of(context).colorScheme.inversePrimary
                  ),
                  child: ListTileTheme(
                    dense: true,
                    minVerticalPadding: 16,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                        child: Icon(
                          Icons.local_shipping,
                          size: 28,
                          color: Theme.of(context).colorScheme.primary
                        ),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
                      collapsedBackgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.4),
                      title: Text('Tipe Pengiriman', style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        height: 1.75
                      )),
                      subtitle: Text(deliveryType, style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary
                      )),
                      children: deliveryTypes.map((element) {
                        return RadioListTile(
                          selected: element['name'] == deliveryType,
                          value: element['name'],
                          groupValue: deliveryType,
                          onChanged: (value) {
                            setState(() {
                              deliveryType = value;
                            });
                          },
                          selectedTileColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                          title: Text(element['name'], style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Text(element['description']),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 32, 6, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Alamat', style: Theme.of(context).textTheme.titleMedium),
                    ElevatedButton.icon(
                      onPressed: () => pushAddressAdd(context: context),
                      style: Styles.buttonFlatSmall(context: context),
                      icon: const Icon(Icons.add_circle),
                      label: const Text('Tambah Alamat')
                    )
                  ],
                ),
              ),
              Hero(
                tag: widget.hero,
                child: Card(
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  color: true ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.15) : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.35),
                  child: Banner(
                    message: 'Alamat Ini',
                    location: BannerLocation.topEnd,
                    color: Theme.of(context).colorScheme.primary,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 42,
                                width: 42,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
                                        borderRadius: BorderRadius.circular(25.7),
                                        color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5)
                                      ),
                                      child: Icon(Icons.home, color: Theme.of(context).colorScheme.primary)
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.inversePrimary,
                                          borderRadius: BorderRadius.circular(25.7)
                                        ),
                                        child: Icon(Icons.check_circle, size: 18, color: Theme.of(context).colorScheme.primary)
                                      )
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('My Home', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary
                              ))
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
                            child: Text('Kabupaten Malang',
                              textAlign: TextAlign.justify,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Jl. Rogonoto No.57B, Gondorejo Ledok, Tamanharjo, Kec. Singosari, Kabupaten Malang, Jawa Timur 65153',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('+62 341 441111',
                              textAlign: TextAlign.justify,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}

class AddressAddRoute extends StatefulWidget {
  const AddressAddRoute({super.key});

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
          title: const Text('Tambah Alamat'),
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const ButtonListTile(
                icon: Icons.my_location,
                title: 'Gunakan Lokasi Sekarang',
                subtitle: 'Jl. Jalan di jalanin no. 69'
              ),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: 'Jl. ',
                onChanged: (value) {
                  setState(() {});
                },
                maxLines: null,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 2
                ),
                decoration: Styles.inputDecorationForm(
                  prefix: Transform.translate(
                    offset: const Offset(-6, 6),
                    child: const Icon(Icons.location_on)
                  ),
                  context: context,
                  placeholder: 'Alamat',
                  condition: false
                ),
              ),
            ],
          )
        )
      ),
    );
  }
}