import 'package:flutter/material.dart';
import 'package:google_auth/functions/location.dart';
import 'package:google_auth/functions/payments.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/routes/alamat/address.dart';
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

  static ValueNotifier<String?> delivertype = ValueNotifier(null);
}

class _OrdersPageRouteState extends State<OrdersPageRoute> with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> orderOpen = ValueNotifier(false);

  late ScrollController _scrollController;
  late TabController _tabController;

  List<bool> checkedItems = List.empty(growable: true);
  bool firstInit = false;

  List<Map> pages = [
    {
      'name': 'Buat Pesanan',
      'icon': Icons.shopping_bag_outlined
    }, {
      'name': 'Riwayat',
      'icon': Icons.history
    }
  ];

  @override
  void initState() {
    _scrollController = ScrollController();
    _tabController = TabController(length: pages.length, vsync: this);

    _getDatalocation();
    setDeliveryType();
    super.initState();
  }

  Future<void> setDeliveryType() async {
    await LocationManager.getCurrentLocation().then((value) {
      return Delivery.getType().then((type) {
        OrdersPageRoute.delivertype.value = type;
        return value;
      });
    });
  }

  _getDatalocation() {
    LocationManager.getDataLocation().then((value) {
      setState(() {
        AddressRoute.locations.value['locations'] = value;
      });

      return value;
    });
  }

  setOrderOpen(bool value) {
    setState(() {
      orderOpen.value = value;
    });
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
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          floating: true,
          pinned: true,
          title: const Text('Pesanan'),
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          centerTitle: true,
          actions: [
            ProfileMenu(color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 12)
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: pages.map((page) {
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(page['icon']),
                    const SizedBox(width: 8),
                    Text(page['name']),
                  ],
                )
              );
            }).toList()
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          Scaffold(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.1),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder(
                    valueListenable: OrdersPageRoute.delivertype,
                    builder: (context, deliveryType, child) {
                      return AddressCard(
                        onCancel: setOrderOpen,
                        orderOpen: orderOpen,
                        deliveryType: deliveryType,
                        checkedItems: checkedItems,
                      );
                    }
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
                                      checkedItems[index] = value!;
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
                                          alignment: Alignment.topLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Image.asset(ItemDescription.getLogo(item[index]['name']), height: 25, alignment: Alignment.topLeft, fit: BoxFit.scaleDown),
                                          ),
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
          ),
          const OrderHistoryPage()
        ],
      ),
    );
  }
}

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {

  late Future _purchaseOrder;

  @override
  void initState() {
    _purchaseOrder = Payment.getPaymentHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: FutureBuilder(
        future: _purchaseOrder,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const HandleLoading();
          } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return ListOrderHistory(index: index, item: snapshot.data[index]);
              }
            );
          } else {
            return const HandleNoInternet(message: 'Periksa Koneksi Internet Anda');
          }
        }
      ),
    );
  }
}


class ListOrderHistory extends StatefulWidget {
  const ListOrderHistory({super.key, required this.index, required this.item});

  final int index;
  final Map item;

  @override
  State<ListOrderHistory> createState() => _ListOrderHistoryState();
}

class _ListOrderHistoryState extends State<ListOrderHistory> {

  late bool isOpen;

  @override
  void initState() {
    isOpen = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
        ),
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: isOpen ? null : Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent
              ),
              child: ExpansionTile(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.05),
                title: Text('Orders: ${widget.item['purchase_order_code']}', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  letterSpacing: 0
                )),
                subtitle: IntrinsicHeight(
                  child: Row(
                    children: [
                      Text(widget.item['delivery_date'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary
                      )),
                      const VerticalDivider(),
                      Icon(Icons.local_shipping, size: 18, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text(widget.item['delivery_type'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary
                      )),
                    ],
                  ),
                ),
                trailing: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
                  child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary)
                ),
                onExpansionChanged: (value) {
                  setState(() {
                    isOpen = value;
                  });
                },
                children: [
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: widget.item['POR1s'].length,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: 120,
                                  child: Stack(
                                    children: [
                                      Badge.count(
                                        alignment: Alignment.topLeft,
                                        offset: const Offset(0, 10),
                                        count: widget.item['POR1s'][index]['order_qty'],
                                        largeSize: 20,
                                        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                                        textStyle: Theme.of(context).textTheme.labelLarge,
                                        textColor: Theme.of(context).colorScheme.inverseSurface,
                                        child: AspectRatio(
                                          aspectRatio: 1/1,
                                          child: Image.asset('assets/Indostar Board.png'),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Image.asset('assets/INDOSTAR LOGO POST.png', height: 25, alignment: Alignment.topLeft, fit: BoxFit.scaleDown),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Indostarbes', style: Theme.of(context).textTheme.titleMedium?.copyWith()),
                                    Text('Indostar', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.secondary
                                    )),
                                    const SizedBox(height: 8),
                                    const Row(
                                      children: [
                                        Text('3000 x 800 x 3.5'),
                                        SizedBox(width: 20),
                                        Text('4.9 Ton'),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                            Divider(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5), height: 40)
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            Container(
              color: isOpen ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.05) : null,
              child: Divider(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5))
            ),
            Container(
              color: isOpen ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.05) : null,
              padding: const EdgeInsets.fromLTRB(16, 8, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('X20 Barang', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 2),
                      Text('10 Ton', style: Theme.of(context).textTheme.titleMedium)
                    ],
                  ),
                  Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    message: 'Pesanan Belum Terkirim. Periksa Koneksi Internet Anda',
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5)
                        )
                      ),
                      child: Row(
                        children: [
                          Text('Belum Terkirim', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            letterSpacing: 0,
                            color: Theme.of(context).colorScheme.tertiary
                          )),
                          const SizedBox(width: 6),
                          Icon(Icons.circle_outlined, size: 16, color: Theme.of(context).colorScheme.tertiary),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.orderOpen,
    required this.deliveryType,
    this.checkedItems,
    this.padding, this.borderRadius,
    this.onCancel
  });

  final ValueNotifier orderOpen;
  final String? deliveryType;
  final List<bool>? checkedItems;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Function? onCancel;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 400),
      child: ValueListenableBuilder(
        valueListenable: AddressRoute.locations,
        builder: (context, locations, child) {
          Map? snapshot;
          if (locations['locations'].isNotEmpty) snapshot = locations?['locations'][locations?['locationindex']];

          if (snapshot != null) {
            return ValueListenableBuilder(
            valueListenable: orderOpen,
            builder: (context, orderOpen, child) {
              return SizedBox(
                height: orderOpen ? null : 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                      child: Hero(
                        tag: snapshot?['name'],
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: Theme.of(context).colorScheme.primary,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: borderRadius ?? BorderRadius.circular(20)
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Theme.of(context).colorScheme.inversePrimary, width: 6),
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
                                          Row(
                                            children: [
                                              Text('Alamat Pengiriman', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: Theme.of(context).colorScheme.surface,
                                              )),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(snapshot?['name'], style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: Theme.of(context).colorScheme.inversePrimary,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0,
                                              )),
                                            ],
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                        onPressed: () => pushAddress(context: context, hero: snapshot?['name']),
                                        style: Styles.buttonInverseFlatSmall(context: context),
                                        child: const Text('Ubah'),
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
                                            Text(snapshot?['district'],
                                              textAlign: TextAlign.justify,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.inversePrimary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text('+62 ${snapshot?['phone_number']}',
                                              textAlign: TextAlign.justify,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.surface,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text('${snapshot?['street']}, ${snapshot?['subdistrict']}, ${snapshot?['district']}, ${snapshot?['province']}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.surfaceVariant,
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
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.inversePrimary,
                                          )),
                                          const SizedBox(height: 4),
                                          Text(deliveryType ?? 'Memuat Data...',
                                            textAlign: TextAlign.justify,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.surface,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (checkedItems == null) const SizedBox(height: 8),
                                  if (checkedItems != null) Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              if (onCancel != null) onCancel!(false);
                                            },
                                            style: Styles.buttonFlat(context: context),
                                            child: const Text('Batal')
                                          ),
                                          const SizedBox(width: 16),
                                          ElevatedButton.icon(
                                            onPressed: () => pushCheckout(context: context, checkedItems: checkedItems!),
                                            style: Styles.buttonFlat(
                                              context: context,
                                              borderRadius: BorderRadius.circular(12),
                                              backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                                              foregroundColor: Theme.of(context).colorScheme.inversePrimary
                                            ),
                                            icon: const Icon(Icons.arrow_forward, size: 22),
                                            label: const Text('Checkout'),
                                          ),
                                        ],
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
          } else if (orderOpen.value == true) {
            return const HandleEmptyAddress();
          } else {
            return const SizedBox();
          }
        }
      ),
    );
  }
}