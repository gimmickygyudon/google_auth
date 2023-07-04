import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_auth/functions/location.dart';
import 'package:google_auth/functions/payments.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/routes/alamat/address.dart';
import 'package:google_auth/strings/item.dart';
import 'package:google_auth/strings/user.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/cart.dart';
import 'package:google_auth/widgets/dialog.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:google_auth/widgets/label.dart';
import 'package:google_auth/widgets/notification.dart';
import 'package:google_auth/widgets/profile.dart';

import '../../functions/conversion.dart';

class OrdersPageRoute extends StatefulWidget {
  const OrdersPageRoute({super.key, this.page});

  final int? page;

  @override
  State<OrdersPageRoute> createState() => _OrdersPageRouteState();

  static ValueNotifier<String?> delivertype = ValueNotifier(null);
}

class _OrdersPageRouteState extends State<OrdersPageRoute> with SingleTickerProviderStateMixin {

  late ScrollController _scrollController;
  late TabController _tabController;

  List<Map> pages = [
    {
      'name': 'Buat Pesanan',
      'icon': Icons.local_shipping_outlined
    }, {
      'name': 'Riwayat',
      'icon': Icons.history
    }
  ];

  @override
  void initState() {
    _scrollController = ScrollController();
    _tabController = TabController(length: pages.length, vsync: this, initialIndex: widget.page ?? 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          floating: true,
          pinned: true,
          title: const Text('Pesanan Anda'),
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
        children: const [
          OrderPage(),
          OrderHistoryPage()
        ],
      ),
    );
  }
}

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final ValueNotifier<bool> orderOpen = ValueNotifier(false);
  List<bool> checkedItems = List.empty(growable: true);
  bool firstInit = false;

  @override
  initState() {
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
    LocationManager.getLocalDataLocation().then((value) {
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
    return Scaffold(
      bottomNavigationBar: AnimatedSize(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (checkedItems.isNotEmpty) const NotificationSmallWidget(
              message: 'Pilih barang yang akan di pesan.',
              icon: Icons.info
            ),
            BottomAppBar(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              height: checkedItems.isEmpty ? 0 : 82,
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
                  Hero(
                    tag: 'Checkout',
                    child: ElevatedButton.icon(
                      onPressed: checkedItems.contains(true) ? () {
                        pushCheckout(context: context, checkedItems: checkedItems);
                      } : null,
                      style: ButtonStyle(
                        elevation: const MaterialStatePropertyAll(0),
                        padding: const MaterialStatePropertyAll(EdgeInsets.fromLTRB(18, 4, 14, 4)),
                        backgroundColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.disabled)) {
                            return null;
                          } else if (orderOpen.value) {
                            return Theme.of(context).colorScheme.tertiary;
                          } else {
                            return Theme.of(context).colorScheme.primary;
                          }
                        }),
                        foregroundColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.disabled)) {
                            return null;
                          } else {
                            return Theme.of(context).colorScheme.surface;
                          }
                        }),
                        overlayColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.inversePrimary),
                        iconSize: MaterialStatePropertyAll(orderOpen.value ? null : 24)
                      ),
                      icon: Text(orderOpen.value ? 'Batal ' : 'Checkout'),
                      label: Icon(orderOpen.value ? Icons.cancel : Icons.arrow_forward)
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder(
                valueListenable: OrdersPageRoute.delivertype,
                builder: (context, deliveryType, child) {
                  return CurrentAddressCard(
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
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (checkedItems.isNotEmpty) TextButton.icon(
                      onPressed: () => setState(() {
                        if (checkedItems.every((element) => element == true)) {
                          checkedItems = List.filled(checkedItems.length, false);

                          orderOpen.value = false;
                        } else {
                          checkedItems = List.filled(checkedItems.length, true);
                        }
                      }),
                      icon: Icon(checkedItems.every((element) => element == true) ? Icons.check_box : Icons.check_box_outline_blank, size: 22),
                      label: const Text('Pilih Semua'),
                    ),
                    ValueListenableBuilder(
                      valueListenable: CartWidget.cartNotifier,
                      builder: (context, item, child) {
                        return Visibility(
                          visible: item.isNotEmpty,
                          child: Row(
                            children: [
                              Icon(Icons.layers_outlined, color: Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 6),
                              Text(item.length.toString(), style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.secondary
                              )),
                            ],
                          ),
                        );
                      },
                    )
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
                                  width: 3
                                )
                              ),
                              isThreeLine: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              selected: checkedItems[index],
                              selectedTileColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.75),
                              tileColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.1),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                              checkboxShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              title: Text(item[index]['name'].toString().toTitleCase(), style: Theme.of(context).textTheme.titleMedium),
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
        ),
      )
    );
  }
}

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> with AutomaticKeepAliveClientMixin {

  late Future _purchaseOrder;
  bool isLocal = false, keepAlive = false;

  @override
  void initState() {
    _purchaseOrder = Payment.getPaymentHistory(id_ousr: currentUser['id_ousr'].toString())
      .onError((error, stackTrace) async {
        isLocal = true;
        List? payments = await Payment.getPaymentHistoryLocal(id_ousr: currentUser['id_ousr'].toString());
        return payments;
      })
      .then((value) {
        if (isLocal == false) {
          return Payment.syncPaymentHistory(id_ousr: currentUser['id_ousr'].toString()).then((_) {
            return _purchaseOrder = Payment.getPaymentHistory(id_ousr: currentUser['id_ousr'].toString()).then((value) {
              return _purchaseOrder = Future.value(value);
            });
          });
        }
        return value;
      });

    super.initState();
  }

  @override
  bool get wantKeepAlive => keepAlive;

  void setKeepAlive(bool value) {
    // FIXME: Loops prints ?
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        keepAlive = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: FutureBuilder(
        future: _purchaseOrder,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            setKeepAlive(false);
            return const HandleLoading();
          } else if (snapshot.data == null || snapshot.data.isEmpty) {
            setKeepAlive(false);
            return const HandleEmptyOrder();
          } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            isLocal == true ? setKeepAlive(false) : setKeepAlive(true);
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return ListOrderHistory(index: index, item: snapshot.data[index], isLocal: isLocal);
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
  const ListOrderHistory({super.key, required this.index, required this.item, required this.isLocal});

  final int index;
  final Map item;
  final bool isLocal;

  @override
  State<ListOrderHistory> createState() => _ListOrderHistoryState();
}

class _ListOrderHistoryState extends State<ListOrderHistory> {

  late bool isOpen;
  late List<Future> _getItem;
  late ScrollController _scrollController;

  @override
  void initState() {
    isOpen = false;
    _scrollController = ScrollController();
    setGetitem();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void setGetitem() {
    _getItem = List.empty(growable: true);

    if (widget.isLocal == false) {
      for (var i = 0; i < widget.item['POR1s'].length; i++) {
        _getItem.add(Item.getItem(id_oitm: widget.item['POR1s'][i]['id_oitm']));
      }
    } else {
      for (var i = 0; i < widget.item['POR1s'].length; i++) {
        _getItem.add(Future.value(widget.item['POR1s'][i]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
                title: Text(widget.isLocal ? '# 00${widget.index + 1}' : 'Pesanan: ${widget.item['purchase_order_code']}', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 0
                )),
                subtitle: IntrinsicHeight(
                  child: Row(
                    children: [
                      Text('${widget.item['delivery_date']}', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        letterSpacing: 0,
                        color: Theme.of(context).colorScheme.secondary
                      )),
                      const VerticalDivider(width: 20),
                      Icon(
                        Icons.local_shipping,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary.withBlue(50).withOpacity(0.85),
                      ),
                      const SizedBox(width: 8),
                      Text(widget.item['delivery_type'], style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        letterSpacing: 0,
                        color: Theme.of(context).colorScheme.primary.withBlue(50).withOpacity(0.85),
                      )),
                    ],
                  ),
                ),
                trailing: const Icon(Icons.arrow_drop_down),
                onExpansionChanged: (value) {
                  setState(() {
                    isOpen = value;
                  });
                },
                children: [
                  AddressCard(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.zero,
                    deliveryType: widget.item['delivery_type'],
                    item: widget.item,
                    locationId: widget.item['id_usr1'],
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.1),
                    height: 300,
                    child:  MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: CupertinoScrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: widget.item['POR1s'].length,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemBuilder: (context, index) {
                            return FutureBuilder(
                              future: _getItem[index],
                              builder: (context, snapshot) {
                                print(widget.item['POR1s'][index]['count']);
                                // FIXME: variable naming
                                String? count() {
                                  if (widget.item['POR1s'][index]['order_qty'] != null) {
                                    return widget.item['POR1s'][index]['order_qty'].toString();
                                  } else {
                                    return widget.item['POR1s'][index]['count'];
                                  }
                                }

                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const HandleLoading();
                                } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                  return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 10),
                                          height: 100,
                                          child: Stack(
                                            children: [
                                              AspectRatio(
                                                aspectRatio: 1/1,
                                                child: Image.asset(ItemDescription.getImage(
                                                  Item.defineName(widget.isLocal ? snapshot.data['name'] :  snapshot.data['item_description']))
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(4),
                                                  child: Image.asset(ItemDescription.getLogo(Item.defineName(widget.isLocal ? snapshot.data['name'] :  snapshot.data['item_description'])),
                                                    height: 25, alignment: Alignment.topLeft, fit: BoxFit.scaleDown,
                                                    width: 100,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            IntrinsicHeight(
                                              child: Row(
                                                children: [
                                                  Text(Item.defineName(widget.isLocal ? snapshot.data['name'] :  snapshot.data['item_description']), style: Theme.of(context).textTheme.titleSmall?.copyWith()),
                                                  const VerticalDivider(width: 30, indent: 5, endIndent: 5),
                                                  Text('x${count()}', style: Theme.of(context).textTheme.labelLarge?.copyWith())
                                                ],
                                              ),
                                            ),
                                            Text('Indostar', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.secondary
                                            )),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(Item.defineDimension(widget.isLocal ? snapshot.data['dimension'] : snapshot.data['spesification']), style: Theme.of(context).textTheme.bodySmall),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                                  child: Text('-'),
                                                ),
                                                Text(setWeight(count: 1, weight: double.parse(Item.defineWeight(snapshot.data['weight']))), style: Theme.of(context).textTheme.bodySmall),
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                      child: Divider(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                                    )
                                  ],
                                );
                                } else {
                                  return const HandleNoInternet(message: 'Periksa Koneksi Internet Anda');
                                }
                              }
                            );
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              color: isOpen ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.05) : null,
              child: Divider(
                color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                height: 0,
                endIndent: isOpen ? 0 : 16, indent: isOpen ? 0 : 16,
              )
            ),
            Container(
              color: isOpen ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.05) : null,
              padding: const EdgeInsets.fromLTRB(16, 14, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.layers_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('${widget.item['POR1s'].length.toString()}  Model Barang', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // TODO: total weight and jumlah
                      // if(totalWeight != null) Text(totalWeight!, style: Theme.of(context).textTheme.titleMedium)
                    ],
                  ),
                  widget.isLocal ? const LabelNoSend() : const LabelSend()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressCard extends StatefulWidget {
  const AddressCard({
    super.key,
    required this.deliveryType,
    required this.locationId,
    this.padding,
    this.borderRadius,
    this.item,
  });

  final String? deliveryType;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final String? locationId;
  final Map? item;

  @override
  State<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  late Future location;
  AsyncMemoizer locationMemoizer = AsyncMemoizer();

  @override
  void initState() {
    if (widget.locationId != null) {
      location = locationMemoizer.runOnce(() {
        return LocationManager.getDataLocation(id: widget.locationId!)?.then((value) async {
          Map location = LocationManager(
            name: value['delivery_name'],
            phone_number: value['phone_number'],
            province: await LocationName.getProvinceName(id: value['id_oprv']).then((value) => value.toString().toTitleCase()),
            district: await LocationName.getDistrictName(id: value['id_octy']).then((value) => value.toString().toTitleCase()),
            subdistrict: await LocationName.getSubDistrictName(id: value['id_osdt']).then((value) => value.toString().toTitleCase()),
            suburb: await LocationName.getSuburbName(id: value['id_ovil']).then((value) => value.toString().toTitleCase()),
            street: value['delivery_street']
          ).toMap();
          return location;
        });
      });
    } else {
      location = Future.value(
        LocationManager(
          name: widget.item?['delivery_name'],
          phone_number: widget.item?['phone_number'],
          province: widget.item?['province'],
          district: widget.item?['district'],
          subdistrict: widget.item?['subdistrict'],
          suburb: widget.item?['suburb'],
          street: widget.item?['delivery_street']
        ).toMap()
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: location,
      builder: (context, location) {
        if (location.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        } else if (location.connectionState == ConnectionState.done && location.hasData) {
          return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
              child: Hero(
                tag: location.data['name'],
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  color: Theme.of(context).colorScheme.primary,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(20)
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
                                    Text(location.data['name'], style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.inversePrimary,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0,
                                    )),
                                  ],
                                ),
                              ],
                            ),
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
                                  Text(location.data['district'],
                                    textAlign: TextAlign.justify,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.inversePrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text('+62 ${location.data['phone_number']}',
                                    textAlign: TextAlign.justify,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.surface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text('${location.data['street']}, ${location.data['subdistrict']}, ${location.data['district']}, ${location.data['province']}',
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
                                Text(widget.deliveryType ?? 'Memuat Data...',
                                  textAlign: TextAlign.justify,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.surface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
        } else {
          return const HandleNoInternet(message: 'Periksa Koneksi Internet Anda');
        }
      }
    );
  }
}


class CurrentAddressCard extends StatelessWidget {
  const CurrentAddressCard({
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
                      padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      child: Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: Theme.of(context).colorScheme.primary,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: borderRadius ?? BorderRadius.circular(12)
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
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Lokasi Pengiriman', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.inversePrimary,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.5
                                            )),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(snapshot?['name'], style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              color: Theme.of(context).colorScheme.surface,
                                              fontWeight: FontWeight.w500,
                                            )),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: OutlinedButton(
                                      onPressed: () => pushAddress(context: context, hero: snapshot?['name']),
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.inversePrimary.withOpacity(0.1)),
                                        foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.inversePrimary),
                                        side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.inversePrimary)),
                                      ),
                                      child: const Text('Ubah'),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
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
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
                                            ),
                                            child: Text('${snapshot?['street']}, ${snapshot?['subdistrict']}, ${snapshot?['district']}, ${snapshot?['province']}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.surface,
                                                letterSpacing: 0,
                                                wordSpacing: 2,
                                                height: 1.4
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
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
                              ),
                              if (checkedItems == null) const SizedBox(height: 12),
                              if (checkedItems != null) Padding(
                                padding: const EdgeInsets.only(top: 24),
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
                                          backgroundColor: Theme.of(context).colorScheme.surface,
                                          foregroundColor: Theme.of(context).colorScheme.primary
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