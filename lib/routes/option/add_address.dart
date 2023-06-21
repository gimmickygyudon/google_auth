import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/widgets/dialog.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../functions/location.dart';
import '../../styles/painter.dart';
import '../../styles/theme.dart';
import '../../widgets/button.dart';

class AddressAddRoute extends StatefulWidget {
  const AddressAddRoute({super.key, required this.hero});

  final String hero;

  @override
  State<AddressAddRoute> createState() => _AddressAddRouteState();

  static ValueNotifier isValidated = ValueNotifier(false);
}

class _AddressAddRouteState extends State<AddressAddRoute> {
  late Position latlang;
  late Future defineLocation;
  UserLocation? userLocation;
  List<Map> locations = List.empty(growable: true);
  late List _locations;
  Map currentLocation = {};

  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    setLocation();
    getLocation();
    super.initState();
  }

  void getLocation() {
    defineLocation = UserLocation.determinePosition()
    .onError((error, stackTrace) => Future.error(error.toString()))
    .then((currentPosition) async {
      await Geolocator.getLastKnownPosition().then((lastPosition) async {
        double? distance;
        if(lastPosition != null) distance = Geolocator.bearingBetween(lastPosition.latitude, lastPosition.longitude, currentPosition.latitude, currentPosition.longitude);

        if(distance != null) {
          if (distance.abs() >= 10.0) {
            return userLocation = await UserLocation.redefineLocationName(currentPosition);
          } else {
            // TODO move this to class location
            return userLocation = await UserLocation.defineLocationName(currentPosition).then((value) {
              setState(() {
                currentLocation = {
                  'province': value.province,
                  'district': value.district,
                  'subdistrict': value.subdistrict,
                  'suburb': value.suburb,
                  'street': value.street
                };
              });
              return value;
            });
          }
        }
      });
      return latlang = currentPosition;
    });
  }

  void setLocation() {
    _locations = [
      {
        'controller': TextEditingController(),
        'focusNode': FocusNode(),
        'options': LocationName.filterProvince,
        'name': 'Provinsi',
        'icon': Icons.landscape,
        'value': null,
      }, {
        'controller': TextEditingController(),
        'focusNode': FocusNode(),
        'options': LocationName.filterDistrict,
        'name': 'Kabupaten / Kota',
        'icon': Icons.location_city,
        'visible': true,
        'value': null,
      }, {
        'controller': TextEditingController(),
        'focusNode': FocusNode(),
        'options': LocationName.filterSubdistrict,
        'icon': Icons.domain,
        'name': 'Kecamatan',
        'value': null,
      }, {
        'controller': TextEditingController(),
        'focusNode': FocusNode(),
        'options': LocationName.filterSuburb,
        'name': 'Kelurahan / Desa',
        'icon': Icons.holiday_village,
        'value': null,
      }, {
        'controller': TextEditingController(),
        'focusNode': FocusNode(),
        'options': Future.value,
        'name': 'Alamat',
        'icon': Icons.signpost_rounded,
        'value': null,
      }
    ];

    locations.add(_locations[0]);
  }

  double range(int multi) {
    return 600.0 + (100 * multi) - MediaQuery.of(context).viewInsets.bottom;
  }

  void disposeLocation() {
    for (var element in locations) {
      element['controller'].dispose();
      element['focusNode'].dispose();
    }
  }

  void setLocationValue({required String value, required int index}) {
    // FIXME: bad coding
    if (index == 4) {
      locations[index]['value'] = value;
    } else {
      locations[index]['options']().then((element) {
        return element.where((String option) {
          return option == value.toUpperCase().replaceAll('(', '').replaceAll(')', '');
        });
      }).then((value) {
        setState(() {
          String string = value.toString().replaceAll('(', '').replaceAll(')', '').toTitleCase();
          List<Map> list = locations;

          if (string.isNotEmpty) {
            locations[index]['value'] = string;
            LocationName.selectedLocationName[index] = string.toUpperCase();

            if (list.contains(_locations[index + 1]) == false) {
              list.add(_locations[index + 1]);
            }

            for (int i = index + 1; i < locations.length; i++) {
              locations[i]['value'] = null;
              locations[i]['controller'].text = '';
              LocationName.selectedLocationName[i] = null;
            }

            locations = list;
            print(LocationName.selectedLocationName);

            if (index != locations.length) locations[index + 1]['visible'] = true;
            if (index - 1 != locations.length) {
              locations[index + 1]['focusNode'].requestFocus();
            }
          } else {
            for (int i = index + 1; i < locations.length; i++) {
              locations[i]['value'] = null;
              locations[i]['controller'].text = '';
              LocationName.selectedLocationName[i] = null;
              locations.removeRange(i, locations.length);
            }
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    LocationName.selectedLocationName = List.filled(5, null, growable: false);
    disposeLocation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: Themes.appBarTheme(context),
        inputDecorationTheme: Themes.inputDecorationThemeForm(context: context)
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alamat Baru'),
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 700),
                curve: Curves.fastOutSlowIn,
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    height: currentLocation.isNotEmpty ? null : 0,
                    width: null,
                    child: Hero(
                      tag: 'Location',
                      child: ButtonListTile(
                        onTap: () {
                          setState(() {

                            List currentLocation_ = [
                              {
                                'value': currentLocation['province'],
                                'icon': Icons.landscape
                              }, {
                                'value': currentLocation['district'],
                                'icon': Icons.location_city
                              }, {
                                'value': currentLocation['subdistrict'],
                                'icon': Icons.domain
                              }, {
                                'value': currentLocation['suburb'],
                                'icon': Icons.holiday_village
                              }, {
                                'value': currentLocation['street'],
                                'icon': Icons.signpost_rounded
                              },
                            ];

                            showAddressDialog(
                              context: context,
                              locations: currentLocation_,
                              hero: 'Location'
                            );
                          });
                        },
                        icon: const Icon(Icons.near_me),
                        title: const Text('Lokasi Sekarang'),
                        subtitle: currentLocation['suburb'] != null
                        ? Text(currentLocation['street'].toString().substring(0, currentLocation['street'].toString().indexOf(',')), style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary
                        ))
                        : Text('Memuat Lokasi...', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary
                        ))
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Lokasi Anda', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      letterSpacing: 0
                    )),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_horiz),
                      itemBuilder: (context) {
                        return [ const PopupMenuItem(child: Text('Reset Lokasi')) ];
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: FutureBuilder(
                  future: defineLocation,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        padding: const EdgeInsets.only(top: 24),
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: const Center(child: HandleLoading(strokeWidth: 3)),
                      );
                    } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: FlutterMap(
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
                        ),
                      );
                    } else {
                      return const HandleNoInternet(message: 'Tidak Ada Koneksi Internet');
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Icon(Icons.info_outline, size: 16),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text('Gunakan Lokasi Saat Ini atau Masukan Alamat Anda.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          letterSpacing: 0
                        )
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Masukan Alamat', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      letterSpacing: 0
                    )),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_horiz),
                      itemBuilder: (context) {
                        return [ const PopupMenuItem(child: Text('Alamat Sekarang')) ];
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: List.generate(locations.length, (index) {
                    Widget widget = Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: FutureBuilder(
                        future: locations[index]['options'](),
                        builder: (context, snapshot) {
                          return AutoCompleteLocationTextfield(
                            onTap: () {
                              return Timer(const Duration(milliseconds: 400), () {
                                _scrollController.animateTo(range(index + 1),
                                  duration: const Duration(milliseconds: 200), curve: Curves.ease
                                );
                              });
                            },
                            onDoneEditing: (value) {
                              setLocationValue(value: value, index: index);
                            },
                            isLoading: snapshot.connectionState == ConnectionState.waiting || snapshot.hasError,
                            element: locations[index],
                            options: snapshot.data as List<String>?,
                          );
                        }
                      ),
                    );
                    return widget;
                  }).toList()
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali')
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Hero(
                      tag: 'Simpan',
                      child: ValueListenableBuilder(
                        valueListenable: AddressAddRoute.isValidated,
                        builder: (context, value, child) {
                          return ElevatedButton(
                            onPressed: value ? () => showAddressDialog(
                              context: context,
                              hero: 'Simpan',
                              locations: locations
                            ) : null,
                            style: Styles.buttonForm(context: context),
                            child: const Text('Simpan')
                          );
                        }
                      ),
                    ),
                  )
                ],
              )
            ],
          )
        )
      ),
    );
  }
}

class MarkerLabel extends StatelessWidget {
  const MarkerLabel({super.key, required this.latlang, required this.currentLocation});

  final Position latlang;
  final Map currentLocation;

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          point: LatLng(latlang.latitude, latlang.longitude),
          width: 60,
          height: 60,
          builder: (context) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                  ),
                ),
                PhysicalModel(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(50),
                  elevation: 2,
                  shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.5),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            );
          },
        ),
        Marker(
          rotate: true,
          width: 210,
          height: 58,
          point: LatLng(latlang.latitude, latlang.longitude),
          builder: (context) {
            return Transform.translate(
              offset: const Offset(0, -44),
              child: Column(
                children: [
                  PhysicalModel(
                    elevation: 4,
                    shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 0, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            child: Icon(Icons.location_on, size: 22, color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(currentLocation['suburb'], style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                height: 0,
                                letterSpacing: 0
                              )),
                              Text(currentLocation['subdistrict'], style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 10,
                                height: 0,
                                letterSpacing: 0
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  CustomPaint(painter: Triangle(Theme.of(context).colorScheme.surface)),
                ],
              )
            );
          },
        )
      ],
    );
  }
}

class LocationTextField extends StatefulWidget {
  const LocationTextField({
    super.key,
    required this.element,
    required this.textEditingController,
    required this.focusNode,
    required this.onDoneEditing,
    this.onTap, required this.isLoading
  });

  final Map element;
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final Function(String)? onDoneEditing;
  final Function? onTap;

  final bool isLoading;

  @override
  State<LocationTextField> createState() => _LocationTextFieldState();
}

class _LocationTextFieldState extends State<LocationTextField> {

  @override
  void initState() {
    widget.element['focusNode'].addListener(() {
      if (widget.element['focusNode'].hasFocus == false) {
        if (widget.onDoneEditing != null) widget.onDoneEditing!(widget.textEditingController.text.trim());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.element['focusNode'].removeListener(() { });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.textEditingController,
      focusNode: widget.element['focusNode'],
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      onEditingComplete: () {},
      onSubmitted: (value) {
        if (widget.onDoneEditing != null) widget.onDoneEditing!(value.trim());
      },
      onChanged: (value) {
        widget.element['value'] == value.trim();
        if (value.trim().isNotEmpty && widget.element['name'] == 'Alamat') {
          widget.element['value'] = value;
          AddressAddRoute.isValidated.value = true;
        } else {
          AddressAddRoute.isValidated.value = false;
        }
      },
      textInputAction: TextInputAction.next,
      maxLines: widget.element['name'] == 'Alamat' ? 3 : null,
      decoration: Styles.inputDecorationForm(
        context: context,
        icon: widget.element['name'] == 'Alamat' ? null : Icon(widget.element['icon']),
        placeholder: widget.element['name'],
        hintText: widget.element['placeholder'],
        labelStyle: const TextStyle(fontSize: 16),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        condition: false,
        suffixIcon: widget.isLoading
          ? Transform.scale(
            scale: 0.5,
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.tertiary),
              ),
          )
          : null
      ),
      keyboardType: TextInputType.name,
    );
  }
}


class AutoCompleteLocationTextfield extends StatefulWidget {
  const AutoCompleteLocationTextfield({
    super.key,
    required this.element,
    required this.options,
    this.onTap,
    this.onDoneEditing, required this.isLoading,
  });

  final Map element;
  final Function? onTap;
  final List<String>? options;
  final Function(String)? onDoneEditing;

  final bool isLoading;

  @override
  State<AutoCompleteLocationTextfield> createState() => _AutoCompleteLocationTextfieldState();
}

class _AutoCompleteLocationTextfieldState extends State<AutoCompleteLocationTextfield> {
  // List<String> options = <String>['aardvark', 'bobcat', 'chameleon'];

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete(
      textEditingController: widget.element['controller'],
      focusNode: widget.element['focusNode'],
      optionsBuilder: (textEditingValue) {
        if (widget.options != null && widget.element['name'] != 'Alamat') {
          return widget.options!.where((String option) {
            return option.trim().toUpperCase().contains(textEditingValue.text.trim().toUpperCase());
          });
        } else {
          return const Iterable<String>.empty();
        }
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 58,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Theme.of(context).colorScheme.primary, width: 4),
                    )
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          onSelected(options.toList()[index].toTitleCase());
                        },
                        title: Text(options.toList()[index].toTitleCase()),
                        titleTextStyle: Theme.of(context).textTheme.bodyMedium,
                      );
                    }
                  ),
                ),
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return LocationTextField(
          onTap: widget.onTap,
          element: widget.element,
          textEditingController: textEditingController,
          focusNode: focusNode,
          onDoneEditing: widget.onDoneEditing,
          isLoading: widget.isLoading,
        );
      },
      onSelected: (String selection) {
        if (widget.onDoneEditing != null) widget.onDoneEditing!(selection.trim());
        debugPrint('You just selected $selection');
      },
    );
  }
}