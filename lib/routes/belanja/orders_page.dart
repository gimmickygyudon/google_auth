import 'package:flutter/material.dart';
import 'package:google_auth/functions/location.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/strings/item.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/cart.dart';
import 'package:google_auth/widgets/dialog.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:google_auth/widgets/profile.dart';

import '../../functions/conversion.dart';

class OrdersPageRoute extends StatefulWidget {
  const OrdersPageRoute({super.key, required this.hero});

  final String hero;

  @override
  State<OrdersPageRoute> createState() => _OrdersPageRouteState();


  static ValueNotifier<Map> currentLocation = ValueNotifier({});
}

class _OrdersPageRouteState extends State<OrdersPageRoute> {
  final ValueNotifier<bool> orderOpen = ValueNotifier(true);

  late Future _getCurrentLocation;
  late String deliveryType;

  List checkedItems = List.empty(growable: true);
  bool firstInit = false;

  @override
  void initState() {
    _getCurrentLocation = LocationManager.getCurrentLocation().then((value) {
      return Delivery.getType().then((type) {
        setState(() => deliveryType = type);
        return value;
      });
    });

    setCurrentLocation();
    super.initState();
  }

  Future<void> setCurrentLocation() async {
    Map? currentLocation = await LocationManager.getCurrentLocation().then((value) {
      return Delivery.getType().then((type) {
        deliveryType = type;
        return value;
      });
    });

    if (currentLocation != null) {
      OrdersPageRoute.currentLocation.value = currentLocation;
    }
  }

  void _removeItems() {
    setState(() {
      int i = 0;
      List<int> listIndex = List.empty(growable: true);
      for (bool element in checkedItems) {
        if (element == true) {
          listIndex.add(i);
        }
        i++;
      }

      Cart.remove(index: listIndex).then((value) {
        Cart.getItems().then((value) {
          if (value != null) {
            checkedItems = List.empty(growable: true);
            for (int i = 0; i < value.length; i++) {
              checkedItems.add(false);
            }
          }
          if (checkedItems.contains(true) == false) orderOpen.value = false;
        });
      });
    });
  }

  // TODO: Dirty Code Fix Duplicate Later
  void setCheckedList() {
    checkedItems = List.empty(growable: true);
    Cart.getItems().then((value) {
      value?.forEach((element) {
        checkedItems.add(false);
      });
    });
  }

  List setSpesifications(Map data) {
    List<String> spesifications = List.generate(data['dimensions'].length, (i) => '${data['dimensions'][i] + '  •  *' + setWeight(weight: double.parse(data['weights'][i]), count: double.parse(data['count']))}');
    return spesifications;
  }

  int selectedIndex(Map data) => data['dimensions'].indexOf(data['dimension']);
  List spesifications(Map data) => setSpesifications(data);
  String spesification(Map data) => spesifications(data)[selectedIndex(data)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.1),
      appBar: AppBar(
        title: const Text('Pesanan'),
        titleTextStyle: Theme.of(context).textTheme.titleMedium,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20)
          )
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.005),
        actions: [
          ProfileMenu(color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(width: 12)
        ],
      ),
      bottomNavigationBar: AnimatedSize(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        child: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          height: checkedItems.isEmpty ? 0 : 64,
          elevation: 20,
          shadowColor: Theme.of(context).colorScheme.shadow,
          surfaceTintColor: Colors.transparent,
          child: ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali')
              ),
              ElevatedButton.icon(
                onPressed: checkedItems.contains(true) ? () {
                  orderOpen.value
                  ? setState(() => orderOpen.value = false)
                  : setState(() => orderOpen.value = true);
                } : null,
                style: ButtonStyle(
                  elevation: const MaterialStatePropertyAll(0),
                  padding: const MaterialStatePropertyAll(EdgeInsets.fromLTRB(18, 4, 14, 4)),
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if(states.contains(MaterialState.disabled)) {
                      return null;
                    } else if (orderOpen.value) {
                      return Theme.of(context).colorScheme.tertiary;
                    } else {
                      return Theme.of(context).colorScheme.primary;
                    }
                  }),
                  foregroundColor: MaterialStateProperty.resolveWith((states) {
                    if(states.contains(MaterialState.disabled)) {
                      return null;
                    } else {
                      return Theme.of(context).colorScheme.surface;
                    }
                  }),
                  overlayColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.inversePrimary),
                  iconSize: MaterialStatePropertyAll(orderOpen.value ? null : 28)
                ),
                icon: Text(orderOpen.value ? 'Batal ' : 'Checkout'),
                label: Icon(orderOpen.value ? Icons.cancel : Icons.arrow_drop_down)
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AddressCard(
              orderOpen: orderOpen,
              getCurrentLocation: _getCurrentLocation,
              deliveryType: deliveryType,
            ),
            if (orderOpen.value) Divider(
              indent: 16,
              endIndent: 16,
              height: 72, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)
            ),
            ListTile(
              contentPadding: const EdgeInsets.only(left: 16),
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.secondary
              ),
              title: const Text('Pesanan Anda,'),
              subtitleTextStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w500
              ),
              textColor: checkedItems.contains(true) ? Theme.of(context).colorScheme.primary : null,
              subtitle: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (checkedItems.isNotEmpty) ...[
                    Text(checkedItems.where((element) => element == true).length.toString()),
                    const SizedBox(width: 12),
                  ],
                  Text(checkedItems.isNotEmpty ? 'Dipilih' : 'Kosong', style: Theme.of(context).textTheme.displaySmall),
                ],
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.filled(
                      onPressed: checkedItems.contains(true) ? () => showDeleteDialog(context: context, onConfirm: _removeItems) : null,
                      style: Styles.buttonDanger(context: context),
                      icon: const Icon(Icons.delete)
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (checkedItems.isNotEmpty) ElevatedButton.icon(
                    onPressed: () => setState(() {
                      if (checkedItems.every((element) => element == true)) {
                        checkedItems = List.filled(checkedItems.length, false);
                        orderOpen.value = false;
                      } else {
                        checkedItems = List.filled(checkedItems.length, true);
                      }
                    }),
                    style: Styles.buttonLight(context: context),
                    icon: Icon(checkedItems.every((element) => element == true) ? Icons.check_box : Icons.check_box_outline_blank),
                    label: const Text('Semua'),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder(
              valueListenable: CartWidget.cartNotifier,
              builder: (context, item, child) {
                // TODO: Dirty Fix
                if (item.isNotEmpty) {
                  if (firstInit == false) {
                    for (int i = 0; i < item.length; i++) {
                      checkedItems.add(false);
                    }
                    firstInit = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) { setState(() {});});
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: item.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Material(
                          type: MaterialType.transparency,
                          child: CheckboxListTile(
                            value: checkedItems[index],
                            onChanged: (value) {
                              setState(() {
                                checkedItems[index] = value;
                                if (checkedItems.contains(true) == false) orderOpen.value = false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: checkedItems[index] ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                width: 2
                              )
                            ),
                            isThreeLine: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            selected: checkedItems[index],
                            selectedTileColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            title: Text(item[index]['name'].toString().toTitleCase()),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(item[index]['brand'].toString().toTitleCase(),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    padding: EdgeInsets.zero,
                                    isDense: true,
                                    borderRadius: BorderRadius.circular(10),
                                    value: spesification(item[index]),
                                    onChanged: (value) {
                                      String dimension = value!.substring(0, value.indexOf('•')).trim();
                                      setState(() {
                                        Cart.update(
                                          index: index,
                                          element: ['dimension', 'weight'],
                                          selectedIndex: item[index]['dimensions'].indexOf(dimension)
                                        );
                                      });
                                    },
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.secondary,
                                      height: 0
                                    ),
                                    items: spesifications(item[index]).map<DropdownMenuItem<String>>((element) {
                                      return DropdownMenuItem<String>(
                                        value: element,
                                        child: Text(element)
                                      );
                                    }).toList()
                                  ),
                                ),
                              ],
                            ),
                            secondary: AspectRatio(
                              aspectRatio: 1.25 / 1,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceVariant,
                                      borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: Image.asset(ItemDescription.getImage(item[index]['name']))
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Badge.count(
                                        count: int.parse(item[index]['count']),
                                        largeSize: 20,
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  );
                } else {
                  return const HandleEmptyOrder();
                }
              }
            ),
          ],
        ),
      )
    );
  }
}

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.orderOpen,
    required this.getCurrentLocation,
    required this.deliveryType
  });

  final ValueNotifier orderOpen;
  final Future getCurrentLocation;
  final String? deliveryType;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 400),
      child: ValueListenableBuilder(
        valueListenable: OrdersPageRoute.currentLocation,
        builder: (context, snapshot, child) {
          if (snapshot.isNotEmpty) {
            return ValueListenableBuilder(
            valueListenable: orderOpen,
            builder: (context, orderOpen, child) {
              return SizedBox(
                height: orderOpen ? null : 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                      child: Hero(
                        tag: 'My Home',
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Theme.of(context).colorScheme.primary, width: 6),
                              )
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Pengiriman', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w500
                                          )),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Text(snapshot['name'], style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                letterSpacing: 0,
                                                color: Theme.of(context).colorScheme.secondary,
                                              )),
                                            ],
                                          ),
                                        ],
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => pushAddress(context: context, hero: snapshot['name']),
                                        style: Styles.buttonFlatSmall(context: context),
                                        label: const Text('Ganti'),
                                        icon: const Icon(Icons.edit_location_alt),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary)
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(snapshot['district'],
                                              textAlign: TextAlign.justify,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                            Text('+62 ${snapshot['phone_number']}',
                                              textAlign: TextAlign.justify,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text('${snapshot['street']}, ${snapshot['subdistrict']}, ${snapshot['district']}, ${snapshot['province']}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.secondary,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0,
                                                wordSpacing: 2,
                                                height: 1.4
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        child: Icon(Icons.local_shipping, color: Theme.of(context).colorScheme.primary)
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Tipe Pengiriman', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.secondary
                                          )),
                                          const SizedBox(height: 4),
                                          Text(deliveryType ?? 'Memuat Data...',
                                            textAlign: TextAlign.justify,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: ElevatedButton.icon(
                                        onPressed: () => pushCheckout(context: context),
                                        style: Styles.buttonFlat(
                                          context: context,
                                          borderRadius: BorderRadius.circular(12),
                                          backgroundColor: Theme.of(context).colorScheme.primary.withGreen(160)
                                        ),
                                        icon: const Icon(Icons.arrow_forward, size: 22),
                                        label: const Text('Checkout'),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          );
          } else {
            return LinearProgressIndicator(color: Theme.of(context).colorScheme.primary, minHeight: 6);
          }
        }
      ),
    );
  }
}