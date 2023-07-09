import 'package:flutter/material.dart';
import 'package:google_auth/functions/location.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/button.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:google_auth/widgets/listtile.dart';

class AddressRoute extends StatefulWidget {
  const AddressRoute({super.key, required this.hero});

  final String hero;

  @override
  State<AddressRoute> createState() => _AddressRouteState();

  static ValueNotifier locations = ValueNotifier({
    'locationindex': '',
    'locations': []
  });
}

class _AddressRouteState extends State<AddressRoute> {
  // TODO: Do This Later
  // late SearchController _searchController;
  late TextEditingController _searchController;
  // ignore: unused_field

  String? deliveryType;
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
    LocationManager.getLocalDataLocation().then((value) {
      setState(() {
        AddressRoute.locations.value['locations'] = value;
      });

      return value;
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String?> initDelivery() async {
    return deliveryType = await Delivery.getType().then((value) {
      return value;
    });
  }

  void setDelivery(String value) {
    setState(() => deliveryType = value);
    Delivery.setType(value);
  }

  void refresh() => setState(() {
    LocationManager.getLocalDataLocation().then((locations) async {
      LocationManager.getIndex().then((index) {
        AddressRoute.locations.value['locationindex'] = index;
      });
      return locations;
    });
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: Themes.appBarTheme(context),
        inputDecorationTheme: Themes.inputDecorationThemeForm(context: context)
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            ],
          ),
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          actions: [
            IconButton(
              onPressed: () => pushAddressAdd(context: context, hero: 'Tambah Alamat'),
              icon: const Icon(Icons.add)
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text('Opsi Pengiriman', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  letterSpacing: 0,
                )),
              ),
              const SizedBox(height: 30),
              FutureBuilder(
                future: initDelivery(),
                builder: (context, snapshot) {
                  return ListTileOptions(
                    title: 'Tipe Pengiriman',
                    subtitle: snapshot.data.toString(),
                    options: deliveryTypes,
                    onChanged: setDelivery
                  );
                }
              ),
              const SizedBox(height: 20),
              Hero(
                tag: 'Add',
                child: ButtonListTile(
                  icon: const Icon(Icons.add_location_alt),
                  bgRadius: 20,
                  title: const Text('Tambah Alamat Baru'),
                  onTap: () => pushAddressAdd(context: context, hero: 'Add')
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 38, 8, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
              ValueListenableBuilder(
                valueListenable: AddressRoute.locations,
                builder: (context, snapshot, child) {
                  if (snapshot['locations'].isEmpty) {
                    return const Center(child: HandleEmptyAddress());
                  } else if (snapshot['locations'].isNotEmpty) {
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot['locations'].length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: CardAddress(
                            onSelect: (index) {
                              setState(() {
                                LocationManager.setIndex(index);
                              });
                            },
                            refresh: refresh,
                            index: index,
                            isSelected: snapshot['locationindex'] == index,
                            location: snapshot['locations'][index],
                          ),
                        );
                      }
                    );
                  } else {
                    return const Center(child: HandleLoading());
                  }
                }
              )
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pop(context),
          elevation: 0,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Kembali')
        ),
      ),
    );
  }
}

class CardAddress extends StatefulWidget {
  const CardAddress({
    super.key,
    required this.isSelected,
    required this.index,
    required this.location,
    required this.refresh,
    required this.onSelect
  });

  final bool isSelected;
  final int index;
  final Map location;
  final Function refresh;
  final Function(int index) onSelect;

  @override
  State<CardAddress> createState() => _CardAddressState();
}

class _CardAddressState extends State<CardAddress> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.location['name'],
      child: Stack(
        children: [
          Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            color: widget.isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
            child: InkWell(
              onTap: () => widget.onSelect(widget.index),
              splashColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
              highlightColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
              child: Ink(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  border: widget.isSelected
                  ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                  : Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // TODO: Show Image Uploaded Photo
                        SizedBox(
                          height: 44,
                          width: widget.isSelected ? 44 : 36,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(widget.isSelected ? 8 : 4),
                                decoration: BoxDecoration(
                                  color: widget.isSelected
                                  ? Theme.of(context).colorScheme.surface
                                  : null,
                                  border: Border.all(color: widget.isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 2),
                                  borderRadius: BorderRadius.circular(25.7),
                                ),
                                child: Icon(Icons.home_outlined,
                                  size: widget.isSelected ? null : 30,
                                  color: widget.isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.primary
                                )
                              ),
                              if (widget.isSelected) Align(
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
                            widget.isSelected ? Text('Lokasi Pengiriman', style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                            wordSpacing: 2,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
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
                          if (widget.isSelected) Icon(Icons.check_circle, color: Theme.of(context).colorScheme.inversePrimary),
                          if (widget.isSelected == false) Text('#${widget.index + 1}', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary
                          ))
                        ],
                      ),
                    ),
                  ],
                ),
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