import 'package:flutter/material.dart';
import 'package:google_auth/functions/location.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/button.dart';
import 'package:google_auth/widgets/handle.dart';

class AddressRoute extends StatefulWidget {
  const AddressRoute({super.key, required this.hero});

  final String hero;

  @override
  State<AddressRoute> createState() => _AddressRouteState();
}

class _AddressRouteState extends State<AddressRoute> {
  // TODO: Do This Later
  // late SearchController _searchController;
  late TextEditingController _searchController;
  late Future<List?> _getLocation;
  late int? locationindex;

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
    _searchController = SearchController();
    deliveryType = deliveryTypes.first['name'];

    _getLocation = _dataLocation();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List?> _dataLocation() {
    return LocationManager.retrieve().then((value) {
      return LocationManager.getIndex().then((index) {
        locationindex = index;

        print(value);
        return value;
      });
    });
  }

  void setDelivery(String value) => setState(() => deliveryType = value);
  void refresh() => setState(() {
    _getLocation = _dataLocation();
  });

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
                padding: const EdgeInsets.fromLTRB(6, 32, 6, 16),
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
              Hero(
                tag: 'Add',
                child: ButtonListTile(
                  icon: const Icon(Icons.add_location_alt_outlined),
                  bgRadius: 20,
                  title: const Text('Tambah Alamat Baru'),
                  onTap: () => pushAddressAdd(context: context, hero: 'Add')
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder(
                future: _dataLocation(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const HandleLoading();
                  } else if (snapshot.hasData) {
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: CardAddress(
                            hero: widget.hero,
                            refresh: refresh,
                            index: index,
                            isSelected: locationindex == index,
                            location: snapshot.data?[index],
                          ),
                        );
                      }
                    );
                  } else {
                    // TODO: get handle widget
                    return const HandleLoading();
                  }
                }
              )
            ],
          ),
        )
      ),
    );
  }
}

class CardAddress extends StatefulWidget {
  const CardAddress({
    super.key,
    required this.hero,
    required this.isSelected,
    required this.index,
    required this.location,
    required this.refresh
  });

  final String hero;
  final bool isSelected;
  final int index;
  final Map location;
  final Function refresh;

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
            color: widget.isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
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
                      // TODO: Show Image Uploaded Photo
                      SizedBox(
                        height: 44,
                        width: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.isSelected
                                ? Theme.of(context).colorScheme.surface
                                : Theme.of(context).colorScheme.primary,
                                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                                borderRadius: BorderRadius.circular(25.7),
                              ),
                              child: Icon(Icons.home_outlined, color: widget.isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface
                              )
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.location['name'], style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: widget.isSelected
                            ? Theme.of(context).colorScheme.surface
                            : Theme.of(context).colorScheme.primary,
                          )),
                          widget.isSelected ? Text('Digunakan', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w500,
                            color: widget.isSelected
                            ? Theme.of(context).colorScheme.inversePrimary
                            : Theme.of(context).colorScheme.secondary
                          )) : const SizedBox()
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
                    child: Text(widget.location['district'],
                      textAlign: TextAlign.justify,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: widget.isSelected
                        ? Theme.of(context).colorScheme.surface
                        : null
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          height: 1.5,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w400,
                          color: widget.isSelected
                          ? Theme.of(context).colorScheme.surface
                          : null
                        ),
                        children: [
                          TextSpan(text: '${widget.location['street']}, '),
                          TextSpan(text: '${widget.location['subdistrict']}, '),
                          TextSpan(text: '${widget.location['district']}, '),
                          TextSpan(text: '${widget.location['province']}'),
                        ]
                      )
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.phone, size: 20, color: widget.isSelected
                          ? Theme.of(context).colorScheme.surface
                          : null
                        ),
                        const SizedBox(width: 8),
                        Text('+62 ${widget.location['phone_number']}',
                          textAlign: TextAlign.justify,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: widget.isSelected
                            ? Theme.of(context).colorScheme.surface
                            : null
                          ),
                        ),
                      ],
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
                icon: Icon(Icons.more_vert,
                  color: widget.isSelected
                  ? Theme.of(context).colorScheme.surface
                  : null
                ),
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
                      onTap: () {
                        LocationManager.delete(widget.index);
                        widget.refresh();
                      },
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