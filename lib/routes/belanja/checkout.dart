import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_auth/functions/conversion.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/routes/belanja/orders_page.dart';
import 'package:google_auth/strings/item.dart';
import 'package:google_auth/strings/user.dart';
import 'package:google_auth/widgets/cart.dart';
import 'package:google_auth/widgets/dialog.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:google_auth/widgets/profile.dart';
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
            expandedHeight: kToolbarHeight + 72,
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
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(18, 0, 0, 56),
              title: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(TextSpan(
                      children: [
                        TextSpan(text: DateNow(), style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          letterSpacing: 0
                        )),
                      ]
                    )),
                    const VerticalDivider(width: 24),
                    Icon(Icons.local_shipping, size: 16, color: Theme.of(context).colorScheme.primary.withBlue(50).withGreen(150)),
                    const SizedBox(width: 6),
                    Text('Tipe Pengiriman: FRANCO', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary.withBlue(50).withGreen(150),
                      letterSpacing: 0
                    ))
                  ],
                ),
              ),
              expandedTitleScale: 1,
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(child: Text('Barang')),
                Tab(child: Text('Tujuan')),
                Tab(child: Text('Pengiriman'))
              ]
            ),
          )
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            ItemPage(checkedItems: widget.checkedItems),
            const LocationWidget(),
            const DeliveryWidget()
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 20),
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
    defineLocation = _getLocation();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Future _getLocation() {
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
          return const Center(child: HandleLoading());
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
            minHeight: 120,
            collapsed: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 16),
                  height: 4,
                  width: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
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
                padding: const EdgeInsets.all(24),
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
                        maxWidth: MediaQuery.of(context).size.width
                      ),
                      child: Expanded(
                        child: Text(
                          currentLocation['street'],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            height: 0,
                            letterSpacing: 0
                          ),
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
                center: LatLng(latlang.latitude, latlang.longitude),
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
          return const HandleNoInternet(message: 'Periksa Koneksi Internet Anda');
        }
      }
    );
  }
}

class DeliveryWidget extends StatefulWidget {
  const DeliveryWidget({super.key});

  @override
  State<DeliveryWidget> createState() => _DeliveryWidgetState();
}

class _DeliveryWidgetState extends State<DeliveryWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder(
              valueListenable: OrdersPageRoute.delivertype,
              builder: (context, deliveryType, child) => AddressCard(
                orderOpen: ValueNotifier(true),
                deliveryType: deliveryType,
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.zero,
              ),
            )
          ],
        ),
      ),
    );
  }
}