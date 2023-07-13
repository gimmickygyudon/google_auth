import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_auth/functions/conversion.dart';
import 'package:google_auth/functions/date.dart';
import 'package:google_auth/functions/notification.dart';
import 'package:google_auth/functions/payments.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/functions/validate.dart';
import 'package:google_auth/routes/belanja/orders_page.dart';
import 'package:google_auth/strings/item.dart';
import 'package:google_auth/strings/user.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/button.dart';
import 'package:google_auth/widgets/cart.dart';
import 'package:google_auth/widgets/dialog.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:google_auth/widgets/profile.dart';
import 'package:google_auth/widgets/snackbar.dart';
import 'package:google_auth/widgets/text.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../functions/location.dart';
import '../../functions/permission.dart';
import '../../widgets/marker.dart';

class CheckoutRoute extends StatefulWidget {
  const CheckoutRoute({super.key, required this.checkedItems});

  final List<bool> checkedItems;

  @override
  State<CheckoutRoute> createState() => _CheckoutRouteState();
}

class _CheckoutRouteState extends State<CheckoutRoute>  with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  List<Map> tabs = [
    {
      'name': 'Barang',
      'icon': Icons.looks_one_outlined,
      'selectedIcon': Icons.looks_one
    }, {
      'name': 'Checkout',
      'icon': Icons.looks_two_outlined,
      'selectedIcon': Icons.looks_two
    },
  ];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this)..addListener(() {
      setState(() {});
    });
    _scrollController = ScrollController();

    PermissionService.requestNotification();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_tabController.index == 1) {
          _tabController.animateTo(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              toolbarHeight: kToolbarHeight + 10,
              title: Row(
                children: [
                  Image.asset('assets/logo IBM p C.png', height: 18),
                  const SizedBox(width: 8),
                  Text('Orders', style: Theme.of(context).textTheme.titleMedium),
                ]
              ),
              actions: [
                ProfileMenu(color: Theme.of(context).colorScheme.inverseSurface),
                const SizedBox(width: 12)
              ],
              bottom: TabBar(
                indicatorPadding: const EdgeInsets.only(bottom: 6),
                indicatorWeight: 8,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 4, color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(25.7)
                ),
                controller: _tabController,
                unselectedLabelColor: Theme.of(context).colorScheme.secondary,
                tabs: List.generate(tabs.length, (index) {
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Icon(_tabController.index == index ? tabs[index]['selectedIcon'] : tabs[index]['icon'], size: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(tabs[index]['name']),
                      ],
                    )
                  );
                }).toList()
              ),
            )
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              ItemPage(
                tabController: _tabController,
                checkedItems: widget.checkedItems
              ),
              // const LocationWidget(),
              DeliveryWidget(
                tabController: _tabController,
                scrollController: _scrollController,
                checkedItems: widget.checkedItems,
              )
            ]
          )
        )
      ),
    );
  }
}

class ItemPage extends StatefulWidget {
  const ItemPage({super.key, required this.checkedItems, required this.tabController});

  final List<bool> checkedItems;
  final TabController tabController;

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  bool isLoading = true;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
    super.initState();
  }

  String totalWeight() {
    double total = 0;
    for (var i = 0; i < CartWidget.cartNotifier.value.length; i++) {
      if (widget.checkedItems[i] == true) {
        total += double.parse(CartWidget.cartNotifier.value[i]['weight']) * int.parse(CartWidget.cartNotifier.value[i]['count']);
      }
    }

    return setWeight(weight: total, count: 1);
  }

  int totalCount() {
    int total = 0;
    for (var i = 0; i < CartWidget.cartNotifier.value.length; i++) {
      if (widget.checkedItems[i] == true) {
        total += int.parse(CartWidget.cartNotifier.value[i]['count']);
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CartWidget.cartNotifier,
      builder: (context, item, child) {
        return Scaffold(
          floatingActionButton: AnimatedSlide(
            curve: Curves.ease,
            duration: const Duration(milliseconds: 600),
            offset: Offset(isLoading ? 2 : 0, 0),
            child: Visibility(
              visible: isLoading ? false : true,
              child: FloatingActionButton.extended(
                heroTag: isLoading ? null : 'Checkout',
                elevation: 4,
                onPressed: () => widget.tabController.animateTo(1),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.surface,
                extendedIconLabelSpacing: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                icon: const Icon(Icons.check),
                label: const Text('Checkout')
              ),
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.025),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5), width: 0.5))
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          minVerticalPadding: 0,
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                            child: const Icon(Icons.layers, size: 30)
                          ),
                          title: Text(totalCount().toString(), style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            height: 1.5
                          )),
                          subtitle: Text('Jumlah Barang', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            letterSpacing: 0,
                            color: Theme.of(context).colorScheme.secondary
                          )),
                        ),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        child: ListTile(
                          minVerticalPadding: 0,
                          title: Text(totalWeight(), style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            height: 1.5,
                          )),
                          subtitle: Text('Tonase', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            letterSpacing: 0,
                            color: Theme.of(context).colorScheme.secondary
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                sliver: SliverList.builder(
                  itemCount: item.length,
                  itemBuilder: (context, index) {
                    return Visibility(
                      visible: widget.checkedItems[index],
                      child: Hero(
                        tag: index,
                        child: Material(
                          type: MaterialType.transparency,
                          child: ListTileTheme(
                            minVerticalPadding: 14,
                            child: OrderListItemWidget(item: item, index: index)
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class OrderListItemWidget extends StatefulWidget {
  const OrderListItemWidget({super.key, required this.item, required this.index});

  final List item;
  final int index;

  @override
  State<OrderListItemWidget> createState() => _OrderListItemWidgetState();
}

class _OrderListItemWidgetState extends State<OrderListItemWidget> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController(text: widget.item[widget.index]['count']);
    super.initState();
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
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ListTile(
          isThreeLine: true,
          visualDensity: const VisualDensity(vertical: 3),
          leading: AspectRatio(
            aspectRatio: 4/3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
                    borderRadius: BorderRadius.circular(4)
                  ),
                  child: Image.asset(ItemDescription.getImage(widget.item[widget.index]['name']))
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(ItemDescription.getLogo(widget.item[widget.index]['name']), height: 30, alignment: Alignment.topLeft, fit: BoxFit.scaleDown),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Badge.count(
                      largeSize: 20,
                      count: int.parse(widget.item[widget.index]['count']),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                    ),
                  ),
                )
              ],
            ),
          ),
          title: Text(widget.item[widget.index]['name'].toString().toTitleCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              height: 0
            )
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(widget.item[widget.index]['brand'].toString().toTitleCase(), style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary
              )),
              const SizedBox(height: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  padding: EdgeInsets.zero,
                  isDense: true,
                  borderRadius: BorderRadius.circular(10),
                  value: spesification(widget.item[widget.index]),
                  onChanged: (value) {
                    String dimension = value!.substring(0, value.indexOf('•')).trim();
                    setState(() {
                      Cart.update(
                        index: widget.index,
                        element: ['dimension', 'weight'],
                        selectedIndex: widget.item[widget.index]['dimensions'].indexOf(dimension)
                      );
                    });
                  },
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    letterSpacing: 0,
                    height: 0
                  ),
                  items: spesifications(widget.item[widget.index]).map<DropdownMenuItem<String>>((element) {
                    return DropdownMenuItem<String>(
                      value: element,
                      child: Text(element)
                    );
                  }).toList()
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 14),
          child: TextFormField(
            controller: _textEditingController,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: (value) {
              String count = Validate.validateQuantity(
                context: context,
                value: value,
                textEditingController: _textEditingController,
                deleteItem: true,
                index: widget.index
              );

              Cart.counts(index: widget.index, count: count);
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.onInverseSurface,
              contentPadding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              labelText: 'Jumlah',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              floatingLabelStyle: const TextStyle(letterSpacing: 0, fontSize: 14),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
              ),
              constraints: const BoxConstraints(
                maxHeight: 60,
                maxWidth: 90
              )
            )
          ),
        ),
      ],
    );
  }
}

class AddMinusWidget extends StatelessWidget {
  const AddMinusWidget({
    super.key, required this.index, required this.item,
  });

  final int index;
  final List item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () {
              String plus = (int.parse(CartWidget.cartNotifier.value[index]['count']) + 1).toString();
              Cart.counts(index: index, count: plus);
            },
            iconSize: 20,
            icon: const Icon(Icons.add)
          ),
          if (int.parse(item[index]['count']) > 1) IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () {
              String minus = (int.parse(CartWidget.cartNotifier.value[index]['count']) - 1).toString();
              Cart.counts(index: index, count: minus);
            },
            iconSize: 20,
            icon: const Icon(Icons.remove)
          ),
          if (int.parse(item[index]['count']) < 2) IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () {
              showDeleteDialog(
                context: context,
                onConfirm: () {
                  Cart.remove(index: [index]);
                }
              );
            },
            iconSize: 20,
            color: Theme.of(context).colorScheme.error,
            icon: const Icon(Icons.delete)
          ),
        ],
      ),
    );
  }
}

class LocationWidget extends StatefulWidget {
  const LocationWidget({super.key});

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> with AutomaticKeepAliveClientMixin {
  late Position latlang;
  Map currentLocation = {};

  late Future defineLocation;

  @override
  void initState() {
    defineLocation = _getCurrentLocation();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Future _getCurrentLocation() {
    return UserLocation.determinePosition().then((currentPosition) {
      return Geolocator.getLastKnownPosition().then((lastPosition) {
        double? distance;
        if(lastPosition != null) distance = Geolocator.bearingBetween(lastPosition.latitude, lastPosition.longitude, currentPosition.latitude, currentPosition.longitude);

        if (distance != null) {
          if (distance.abs() >= 10.0) {
            return UserLocation.redefineLocationName(currentPosition).then((value) {
              setState(() {
                currentLocation = {
                  'province': value.province,
                  'district': value.district,
                  'subdistrict': value.subdistrict,
                  'suburb': value.suburb,
                  'street': value.street
                };
              });

              return latlang = currentPosition;
            });
          } else {
            return UserLocation.defineLocationName(currentPosition).then((value) {
              setState(() {
                currentLocation = {
                  'province': value.province,
                  'district': value.district,
                  'subdistrict': value.subdistrict,
                  'suburb': value.suburb,
                  'street': value.street
                };
              });

              return latlang = currentPosition;
            });
          }
        }
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: defineLocation,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.025),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                Center(child: Text('Memuat Lokasi Tujuan...', style: Theme.of(context).textTheme.titleLarge)),
                LinearProgressIndicator(minHeight: 6, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return SlidingUpPanel(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20)
            ),
            panel: const Center(
              child: Text("This is the sliding Widget"),
            ),
            minHeight: 130,
            collapsed: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 16, bottom: 16),
                  height: 4,
                  width: 34,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12)
                  ),
                ),
              ],
            ),
            header: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20)
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.signpost_outlined, size: 16),
                        SizedBox(width: 6),
                        Text('Alamat'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 50
                      ),
                      child: Text(
                        currentLocation['street'],
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          height: 0,
                          letterSpacing: 0
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: FlutterMap(
              options: MapOptions(
                enableScrollWheel: true,
                center: LatLng(latlang.latitude - 0.06, latlang.longitude),
                zoom: 12,
              ),
              nonRotatedChildren: [
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                    ),
                  ],
                ),
              ],
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLabel(
                  latlang: latlang,
                  currentLocation: currentLocation,
                )
              ],
            ),
          );
        } else {
          return HandleLocationDisabled(
            buttonPressed: () {
              _getCurrentLocation().whenComplete(() => Navigator.pop(context));
            }
          );
        }
      }
    );
  }
}

class DeliveryWidget extends StatefulWidget {
  const DeliveryWidget({super.key, required this.checkedItems, required this.tabController, required this.scrollController});

  final List checkedItems;
  final TabController tabController;
  final ScrollController scrollController;

  @override
  State<DeliveryWidget> createState() => _DeliveryWidgetState();
}

class _DeliveryWidgetState extends State<DeliveryWidget> {
  String? selectedDate = DateNow();
  String? selectedTime = TimeNow();
  DateTime? date;
  TimeOfDay? time;
  String? payments;
  int paymentType = 0;
  bool isLoading = false, noteOpen = false;

  late TextEditingController referenceNumberTextController;
  late TextEditingController documentremarksTextController;

  @override
  void initState() {
    referenceNumberTextController = TextEditingController();
    documentremarksTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    referenceNumberTextController.dispose();
    documentremarksTextController.dispose();
    super.dispose();
  }

  int setPaymentType(int index) {
    setState(() => paymentType = index);
    return paymentType;
  }

  String totalWeight() {
    double total = 0;
    for (var i = 0; i < CartWidget.cartNotifier.value.length; i++) {
      if (widget.checkedItems[i] == true) {
        total += double.parse(CartWidget.cartNotifier.value[i]['weight']) * int.parse(CartWidget.cartNotifier.value[i]['count']);
      }
    }

    return setWeight(weight: total, count: 1);
  }

  int totalCount() {
    int total = 0;
    for (var i = 0; i < CartWidget.cartNotifier.value.length; i++) {
      if (widget.checkedItems[i] == true) {
        total += int.parse(CartWidget.cartNotifier.value[i]['count']);
      }
    }

    return total;
  }

  Future<void> onConfirm(String? deliveryType, int indexPaymentsType) async {
    List? itemList;
    List<int> itemindex = List.empty(growable: true);
    itemList = await Cart.getItems().then((value) {
      int i = -1;
      if (value != null) {
        return value.map((e) {
          i++;
          if (widget.checkedItems[i] == true) {
            itemindex.add(i);
            return value[i];
          } else {
            return null;
          }
        }).nonNulls.toList();
      } else {

        return null;
      }
    });

    Map? currentLocation = await LocationManager.getCurrentLocation().then((currentLocation) {
      return currentLocation;
    }).onError((error, stackTrace) {
      showSnackBar(context, snackBarError(context: context, content: error.toString()));
      return Future.error(error.toString());
    });

    void notif(Map value) {
      Cart.remove(index: itemindex);
      pushDashboard(context);
      showSnackBar(context, snackBarComplete(
        context: context,
        content: 'Barang Berhasil di Pesan',
        duration: const Duration(seconds: 2)
      ));

      int id() => (value['id_ousr'] is String) ? int.parse(value['id_ousr']) : value['id_ousr'];
      NotificationBody.showNotification(
        id: id(),
        title: '${value['delivery_name']}  -  $deliveryType',
        body: 'Barang Berhasil di Pesan.\nLihat Riwayat Pesanan Untuk Lebih Lengkapnya',
      );
    }

    void insertLocal() {
      Payment.insertPaymentLocal(
        Payment(
          id_opor: null,
          customer_reference_number: referenceNumberTextController.text,
          id_ousr: currentUser['id_ousr'].toString(),
          delivery_date: '$selectedDate - $selectedTime',
          delivery_type: deliveryType,
          document_remarks: documentremarksTextController.text,
          payment_type: indexPaymentsType.toString(),

          delivery_name: currentLocation?['name'],
          delivery_street: currentLocation?['street'],
          province: currentLocation?['province'],
          district: currentLocation?['district'],
          subdistrict: currentLocation?['subdistrict'],
          suburb: currentLocation?['suburb'],
          phone_number: currentLocation?['phone_number'],

          POR1s: jsonEncode(itemList),
          isSent: 0
        )
      ).then((value) => notif(value.toMap()));
    }

    List<int> locationIds = await LocationManager.getLocationsId().then((locationIds) async {
      return locationIds;
    }).onError((error, stackTrace) {
      insertLocal();
      return Future.error(error.toString());
    });

    Payment.insertPayment(
      Payment(
        id_opor: null,
        customer_reference_number: referenceNumberTextController.text,
        id_ousr: currentUser['id_ousr'].toString(),
        delivery_date: '$selectedDate - $selectedTime',
        delivery_type: deliveryType,
        document_remarks: documentremarksTextController.text,
        payment_type: indexPaymentsType.toString(),
        delivery_name: currentLocation?['name'],
        delivery_street: currentLocation?['street'],
        province: locationIds[0].toString(),
        district: locationIds[1].toString(),
        subdistrict: locationIds[2].toString(),
        suburb: locationIds[3].toString(),
        phone_number: currentLocation?['phone_number'],
        POR1s: itemList,
        isSent: 1
      )
    )
    .onError((error, stackTrace) {
      insertLocal();
      return Future.error(error.toString());
    })
    .then((value) => notif(value));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Themes.inputDecorationTheme(context: context)
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.025),
        body:  MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: CupertinoScrollbar(
            controller: widget.scrollController,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: ValueListenableBuilder(
                valueListenable: OrdersPageRoute.delivertype,
                builder: (context, deliveryType, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: CurrentAddressCard(
                          deliveryType: deliveryType,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shadowColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.05).withBlue(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Jadwal Pengiriman', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 2),
                                Text('Tanggal Dokumen: ${DateNow()}', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.85),
                                  letterSpacing: 0
                                )),
                                const SizedBox(height: 20),
                                ButtonListTile(
                                  dense: true,
                                  icon: const Icon(Icons.date_range),
                                  title: Text(selectedDate != null ? 'Tanggal Pengiriman' : 'Pilih Tanggal', style: Theme.of(context).textTheme.bodySmall?.copyWith()),
                                  subtitle: Text(selectedDate ?? DateNow(), style: Theme.of(context).textTheme.titleSmall?.copyWith()),
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1).withBlue(0),
                                  bgRadius: 18,
                                  borderRadius: BorderRadius.circular(12),
                                  trailing: const Icon(Icons.arrow_drop_down, size: 30),
                                  onTap: () => Date.showDate(context, date).then((value) {
                                    if (value == null) {
                                      return false;
                                    }
                                    setState(() {
                                      date = value;
                                      String string = DateFormat('EEEE, dd MMMM, ''yyyy', 'id').format(value);
                                      selectedDate = string;
                                    });
                                  }),
                                ),
                                const SizedBox(height: 20),
                                ButtonListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.schedule),
                                  title: Text(selectedTime != null ? 'Waktu Pengiriman' : 'Pilih Waktu', style: Theme.of(context).textTheme.bodySmall?.copyWith()),
                                  subtitle: Text(selectedTime ?? TimeNow(), style: Theme.of(context).textTheme.titleSmall?.copyWith()),
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1).withBlue(0),
                                  bgRadius: 18,
                                  borderRadius: BorderRadius.circular(12),
                                  trailing: const Icon(Icons.arrow_drop_down, size: 30),
                                  onTap: () => Date.showTime(context, time).then((value) {
                                    if (value == null) {
                                      return false;
                                    }
                                    setState(() {
                                      time = value;
                                      selectedTime = value.format(context);
                                    });
                                  }),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(25.7)
                         ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.confirmation_number_outlined,
                                        color: Theme.of(context).colorScheme.secondary,
                                        size: 22
                                      ),
                                      const SizedBox(width: 10),
                                      Text('Voucher Discount', style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        letterSpacing: 0,
                                        color: Theme.of(context).colorScheme.secondary,
                                      )),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: Styles.buttonFlatSmall(
                                      context: context,
                                      borderRadius: BorderRadius.circular(25.7),
                                      backgroundColor: Theme.of(context).colorScheme.secondary,
                                    ),
                                    child: const Text('Lihat')
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: CartWidget.cartNotifier,
                        builder: (context, value, child) {
                          return InkWell(
                            onTap: () => widget.tabController.animateTo(0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: ListTile(
                                            minVerticalPadding: 0,
                                            leading: CircleAvatar(
                                              backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                                              child: Icon(Icons.layers, size: 30, color: Theme.of(context).colorScheme.secondary)
                                            ),
                                            title: Text(totalCount().toString(), style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              height: 1.5
                                            )),
                                            subtitle: Text('Jumlah Barang', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontSize: 10,
                                              letterSpacing: 0,
                                              color: Theme.of(context).colorScheme.secondary
                                            )),
                                          ),
                                        ),
                                        const VerticalDivider(),
                                        Expanded(
                                          child: ListTile(
                                            minVerticalPadding: 0,
                                            title: Text(totalWeight(), style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              height: 1.5,
                                            )),
                                            subtitle: Text('Tonase', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontSize: 10,
                                              letterSpacing: 0,
                                              color: Theme.of(context).colorScheme.secondary
                                            )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      ),
                      const SizedBox(height: 12),
                      Theme(
                        data: Theme.of(context).copyWith(dividerColor: Theme.of(context).colorScheme.outlineVariant),
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return ExpansionTile(
                              onExpansionChanged: (value) {
                                setState(() {
                                  noteOpen = value;
                                });
                              },
                              title: Row(
                                children: [
                                  TextIcon(
                                    disable: noteOpen ? false : true,
                                    label: 'Catatan',
                                    icon: Icons.note_alt_outlined,
                                    iconSize: 22,
                                    bgRadius: 18,
                                  ),
                                  Expanded(child: Divider(indent: 16, endIndent: 8, height: 0, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.25)))
                                ],
                              ),
                              tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              childrenPadding: const EdgeInsets.symmetric(horizontal: 24),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2),
                                        child: Text('Catatan pengiriman barang dan rincian informasi barang.',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            letterSpacing: 0,
                                            color: Theme.of(context).colorScheme.secondary
                                          )
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      Column(
                                        children: [
                                          TextField(
                                            maxLines: 3,
                                            controller: documentremarksTextController,
                                            decoration: Styles.inputDecorationForm(
                                              context: context,
                                              placeholder: 'Spesial Instruksi',
                                              hintText: 'Contoh: Barang dibawah dengan alas plastik ...',
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                              labelStyle: const TextStyle(fontSize: 16, letterSpacing: 0),
                                              condition: documentremarksTextController.text.isNotEmpty
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          TextField(
                                            controller: referenceNumberTextController,
                                            decoration: Styles.inputDecorationForm(
                                              context: context,
                                              placeholder: 'Nomor Referensi',
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                              labelStyle: const TextStyle(fontSize: 16, letterSpacing: 0),
                                              condition: referenceNumberTextController.text.isNotEmpty
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 28)
                                    ],
                                  ),
                                )
                              ],
                            );
                          }
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ValueListenableBuilder(
                              valueListenable: OrdersPageRoute.delivertype,
                              builder: (context, deliverytype, child) {
                                return ElevatedButton.icon(
                                  onPressed: () {
                                    pushPayment(
                                      context: context,
                                      onConfirm: (indexPaymentsType) {
                                        return onConfirm(deliverytype, indexPaymentsType);
                                      },
                                      delivertype: deliverytype,
                                    );
                                  },
                                  style: Styles.buttonFlat(
                                    context: context,
                                    minimumSize: const Size(170, 54),
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  icon: const Icon(Icons.payment),
                                  label: const Text('Pembayaran')
                                );
                              }
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                }
              ),
            ),
          ),
        ),
      ),
    );
  }
}