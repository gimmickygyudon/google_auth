import 'package:flutter/material.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/styles/theme.dart';
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
      'description': 'Barang Dikirim Ke Lokasi Tujuan'
    }, {
      'name': 'LOCO',
      'description': 'Barang Di Ambil Sendiri'
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

  void setDelivery(String value) => setState(() => deliveryType = value);

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
          actions: [
            IconButton(
              onPressed: () => pushAddressAdd(context: context, hero: 'Tambah Alamat'),
              icon: const Icon(Icons.add)
            )
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => pushAddressAdd(context: context, hero: 'Tambah Alamat'),
          heroTag: 'Tambah Alamat',
          icon: Icon(Icons.add_location_alt, color: Theme.of(context).colorScheme.surface),
          label: Text('Alamat Baru', style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.surface,
            letterSpacing: 0
          )),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Column(
            children: [
              // TextField(
              //   controller: searchController,
              //   onChanged: (value) {
              //     setState(() {});
              //   },
              //   decoration: Styles.inputDecorationForm(
              //     suffixIcon: const Padding(
              //       padding: EdgeInsets.only(left: 4),
              //       child: LabelSearch(),
              //     ),
              //     icon: const Icon(Icons.location_on),
              //     context: context,
              //     placeholder: 'Cari Alamat',
              //     condition: searchController.text.trim().isNotEmpty
              //   ),
              // ),
              ListRadioDelivery(
                value: deliveryType,
                options: deliveryTypes,
                onChanged: setDelivery,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 32, 6, 12),
                child: Column(
                  children: [
                    Text('Tempat Anda', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      letterSpacing: 0,
                    )),
                    Text('Pilih Lokasi Pengiriman', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      letterSpacing: 0
                    )),
                  ],
                ),
              ),
              CardAddress(hero: widget.hero)
            ],
          ),
        )
      ),
    );
  }
}

class CardAddress extends StatefulWidget {
  const CardAddress({super.key, required this.hero});

  final String hero;

  @override
  State<CardAddress> createState() => _CardAddressState();
}

class _CardAddressState extends State<CardAddress> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.hero,
      child: Stack(
        children: [
          Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            color: true ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.15) : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.35),
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
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                                borderRadius: BorderRadius.circular(25.7),
                              ),
                              child: Icon(Icons.house, color: Theme.of(context).colorScheme.surface)
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(25.7)
                                ),
                                child: Icon(Icons.check_circle, size: 16, color: Theme.of(context).colorScheme.inversePrimary)
                              )
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
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
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: PopupMenuButton(
                elevation: 8,
                surfaceTintColor: Theme.of(context).colorScheme.inversePrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.zero,
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      height: 45,
                      onTap: () => pushAddressAdd(context: context, hero: 'Tambah Alamat'),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_location_alt_outlined),
                          SizedBox(width: 8),
                          Text('Ubah Alamat'),
                        ],
                      )
                    ),
                    PopupMenuItem(
                      height: 45,
                      labelTextStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error
                      )),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          const Text('Hapus'),
                        ],
                      )
                    )
                  ];
                },
              )
            ),
          )
        ],
      ),
    );
  }
}

class ListRadioDelivery extends StatefulWidget {
  const ListRadioDelivery({super.key, required this.options, required this.value, required this.onChanged});

  final List options;
  final String value;
  final Function onChanged;

  @override
  State<ListRadioDelivery> createState() => _ListRadioDeliveryState();
}

class _ListRadioDeliveryState extends State<ListRadioDelivery> {
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
          title: Text('Tipe Pengiriman', style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
          )),
          subtitle: Text(widget.value, style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            height: 0
          )),
          children: widget.options.map((element) {
            return RadioListTile(
              selected: element['name'] == widget.value,
              value: element['name'],
              groupValue: widget.value,
              onChanged: (e) {
                widget.onChanged(e);
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