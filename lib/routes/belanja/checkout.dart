import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_auth/functions/conversion.dart';
import 'package:google_auth/functions/date.dart';
import 'package:google_auth/functions/payments.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/functions/sql_client.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/routes/belanja/orders_page.dart';
import 'package:google_auth/strings/item.dart';
import 'package:google_auth/strings/user.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/bottomsheet.dart';
import 'package:google_auth/widgets/button.dart';
import 'package:google_auth/widgets/cart.dart';
import 'package:google_auth/widgets/dialog.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:google_auth/widgets/profile.dart';
import 'package:google_auth/widgets/snackbar.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../functions/location.dart';
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

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            toolbarHeight: kToolbarHeight + 10,
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Orders: ', style: Theme.of(context).textTheme.titleMedium),
                  TextSpan(text: '0001/VI/23', style: Theme.of(context).textTheme.bodyLarge)
                ]
              )
            ),
            actions: [
              ProfileMenu(color: Theme.of(context).colorScheme.inverseSurface),
              const SizedBox(width: 12)
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(child: Text('Barang')),
                Tab(child: Text('Tujuan')),
                Tab(child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 20),
                    SizedBox(width: 6),
                    Text('Checkout'),
                  ],
                ))
              ]
            ),
          )
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            ItemPage(checkedItems: widget.checkedItems),
            const LocationWidget(),
            DeliveryWidget(
              tabController: _tabController,
              scrollController: _scrollController,
              checkedItems: widget.checkedItems,
            )
          ]
        )
      )
    );
  }
}

class ItemPage extends StatefulWidget {
  const ItemPage({super.key, required this.checkedItems});

  final List<bool> checkedItems;

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  List setSpesifications(Map data) {
    List<String> spesifications = List.generate(data['dimensions'].length, (i) => '${data['dimensions'][i] + '  •  *' + setWeight(weight: double.parse(data['weights'][i]), count: double.parse(data['count']))}');
    return spesifications;
  }

  int selectedIndex(Map data) => data['dimensions'].indexOf(data['dimension']);
  List spesifications(Map data) => setSpesifications(data);
  String spesification(Map data) => spesifications(data)[selectedIndex(data)];

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
          backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.025),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5), width: 0.5))
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jumlah Barang', style: Theme.of(context).textTheme.labelLarge),
                      Text(totalCount().toString(), style: Theme.of(context).textTheme.labelLarge)
                    ],
                  ),
                ),
                Divider(height: 0, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tonase', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary
                      )),
                      Text(totalWeight(), style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary
                      ))
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
                      child: ListTileTheme(
                        minVerticalPadding: 14,
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            ListTile(
                              visualDensity: const VisualDensity(vertical: 2),
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
                                      child: Image.asset(ItemDescription.getImage(item[index]['name']))
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Image.asset(ItemDescription.getLogo(item[index]['name']), height: 30, alignment: Alignment.topLeft, fit: BoxFit.scaleDown),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Badge.count(
                                          count: int.parse(item[index]['count']),
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              isThreeLine: true,
                              title: Text(item[index]['name'].toString().toTitleCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              )),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(item[index]['brand'].toString().toTitleCase(), style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary
                                  )),
                                  const SizedBox(height: 8),
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
                            ),
                            Container(
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
                            ),
                          ],
                        )
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
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Themes.inputDecorationTheme(context: context)
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.025),
        body:  MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 6,
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
                          orderOpen: ValueNotifier(true),
                          deliveryType: deliveryType,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shadowColor: Colors.transparent,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.05).withBlue(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Theme.of(context).colorScheme.primary.withBlue(50).withOpacity(0.4), width: 6),
                              )
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Jadwal Pengiriman', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 2),
                                Text('Tanggal Dokumen: ${DateNow()}', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary.withBlue(50).withOpacity(0.85),
                                  letterSpacing: 0
                                )),
                                const SizedBox(height: 20),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Theme.of(context).colorScheme.primary.withBlue(50).withOpacity(0.4), width: 6),
                                      )
                                    ),
                                    child: ButtonListTile(
                                      dense: true,
                                      icon: const Icon(Icons.date_range),
                                      title: Text(selectedDate != null ? 'Tanggal Pengiriman' : 'Pilih Tanggal', style: Theme.of(context).textTheme.bodySmall?.copyWith()),
                                      subtitle: Text(selectedDate ?? DateNow(), style: Theme.of(context).textTheme.titleSmall?.copyWith()),
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1).withBlue(0),
                                      bgRadius: 18,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12)
                                      ),
                                      trailing: const Icon(Icons.expand_more),
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
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Theme.of(context).colorScheme.primary.withBlue(50).withOpacity(0.4), width: 6),
                                      )
                                    ),
                                    child: ButtonListTile(
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.schedule),
                                      title: Text(selectedTime != null ? 'Waktu Pengiriman' : 'Pilih Waktu', style: Theme.of(context).textTheme.bodySmall?.copyWith()),
                                      subtitle: Text(selectedTime ?? TimeNow(), style: Theme.of(context).textTheme.titleSmall?.copyWith()),
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1).withBlue(0),
                                      bgRadius: 18,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12)
                                      ),
                                      trailing: const Icon(Icons.expand_more),
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
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)
                            ),
                            borderRadius: BorderRadius.circular(12)
                         ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Voucher Discount', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                  )),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: Styles.buttonFlatSmall(
                                      context: context,
                                      borderRadius: BorderRadius.circular(8),
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
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    widget.scrollController.animateTo(0, duration: const Duration(milliseconds: 800), curve: Curves.ease);
                                    widget.tabController.animateTo(0);
                                  },
                                  child: Ink(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Jumlah Barang', style: Theme.of(context).textTheme.labelLarge),
                                        Text(totalCount().toString(), style: Theme.of(context).textTheme.labelLarge)
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(height: 0, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Tonase', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.primary
                                      )),
                                      Text(totalWeight(), style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.primary
                                      ))
                                    ],
                                  ),
                                ),
                                Divider(height: 0, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                              ],
                            ),
                          );
                        }
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                showPaymentSheet(
                                  context: context,
                                  onConfirm: (indexPaymentsType) async {
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

                                    insertLocal() {
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
                                      );
                                    }

                                    List<int> locationIds = await LocationManager.getLocationsId().then((locationIds) async {
                                      return locationIds;
                                    }).onError((error, stackTrace) {
                                      // showSnackBar(context, snackBarError(context: context, content: error.toString()));
                                      insertLocal();
                                      return Future.error(error.toString());
                                    });

                                    SQL.insert(api: 'po', item: {
                                      'id_usr1': null,
                                      'id_ousr': currentUser['id_ousr'],
                                      'delivery_name': currentLocation?['name'],
                                      'delivery_street': currentLocation?['street'],
                                      'id_oprv': locationIds[0],
                                      'id_octy': locationIds[1],
                                      'id_osdt': locationIds[2],
                                      'id_ovil': locationIds[3],
                                      'phone_number': currentLocation?['phone_number'],

                                      'id_opor': null,
                                      'customer_reference_number': referenceNumberTextController.text,
                                      'delivery_date': '$selectedDate - $selectedTime',
                                      'delivery_type': deliveryType,
                                      'document_remarks': documentremarksTextController.text,
                                      'payment_type': indexPaymentsType.toString(),

                                      'por1': itemList
                                    })
                                    .then((_) {
                                      Cart.remove(index: itemindex);
                                      pushDashboard(context);
                                      showSnackBar(context, snackBarComplete(
                                        context: context,
                                        content: 'Barang Berhasil di Pesan',
                                        duration: const Duration(seconds: 2)
                                      ));
                                    });
                                  }
                                );
                              },
                              style: Styles.buttonForm(
                                context: context,
                              ),
                              label: const Text('Pembayaran'),
                              icon: const Icon(Icons.expand_more)
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.text_snippet_outlined),
                                Text(' Catatan', style: Theme.of(context).textTheme.titleMedium),
                                Expanded(child: Divider(indent: 16, endIndent: 8, height: 0, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)))
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              maxLines: 3,
                              controller: documentremarksTextController,
                              decoration: Styles.inputDecorationForm(
                                context: context,
                                placeholder: 'Spesial Instruksi',
                                hintText: 'Contoh: Barang dibawah dengan alas plastik',
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelStyle: const TextStyle(fontSize: 16, letterSpacing: 0),
                                condition: false
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
                                condition: false
                              ),
                            )
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