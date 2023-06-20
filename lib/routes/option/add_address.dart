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
  late List<Map> locations;

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
                locations[0]['placeholder'] = value.province;
                locations[1]['placeholder'] = value.district;
                locations[2]['placeholder'] = value.subdistrict;
                locations[3]['placeholder'] = value.suburb;
                locations[4]['placeholder'] = value.street;
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
    locations = [
      {
        'controller': TextEditingController(),
        'focusNode': FocusNode(),
        'options': LocationName.getProvince,
        'name': 'Provinsi',
        'icon': Icons.landscape,
        'visible': true,
        'value': null,
        'placeholder': null
      }, {
        'controller': TextEditingController(),
        'focusNode': FocusNode(),
        'options': LocationName.getDistrict,
        'name': 'Kabupaten / Kota',
        'icon': Icons.location_city,
        'visible': false,
        'value': null,
        'placeholder': null
      }, {
        'controller': TextEditingController(),
        'focusNode': FocusNode(),
        'options': LocationName.getSubdistrict,
        'icon': Icons.domain,
        'name': 'Kecamatan',
        'visible': false,
        'value': null,
        'placeholder': null
      }, {
        'controller': TextEditingController(),
        'focusNode': FocusNode(),
        'options': LocationName.getSuburb,
        'name': 'Kelurahan / Desa',
        'icon': Icons.holiday_village,
        'visible': false,
        'value': null,
        'placeholder': null
      }, {
        'controller': TextEditingController(),
        'focusNode': FocusNode(),
        'options': null,
        'name': 'Alamat',
        'icon': Icons.signpost_rounded,
        'visible': false,
        'value': null,
        'placeholder': null
      }
    ];
  }

  double range(int multi) {
    return 500.0 + (80 * multi) - MediaQuery.of(context).viewInsets.bottom;
  }

  void disposeLocation() {
    for (var element in locations) {
      element['controller'].dispose();
      element['focusNode'].dispose();
    }
  }

  void setLocationValue({required String value, required int index}) {
    locations[index]['options']().then((element) {
      return element.where((String option) {
        return option == value.toUpperCase();
      });
    }).then((value) {
      setState(() {
        String string = value.toString().replaceAll('(', '').replaceAll(')', '').toTitleCase();

        if (value.isNotEmpty) {
          locations[index]['value'] = string;
          locations[index]['visible'] = true;

          for (int i = index + 1; i < locations.length; i++) {
            locations[i]['visible'] = false;
            locations[i]['value'] = null;
            locations[i]['controller'].text = '';
          }
          if (index != locations.length) locations[index + 1]['visible'] = true;
        } else {
          for (int i = index + 1; i < locations.length; i++) {
            locations[i]['visible'] = false;
            locations[i]['value'] = null;
            locations[i]['controller'].text = '';
          }
        }
      });

      if (index - 1 != locations.length) {
        locations[index + 1]['focusNode'].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
              ButtonListTile(
                icon: Icons.near_me,
                title: const Text('Lokasi Sekarang'),
                subtitle: locations[4]['placeholder'] != null
                ? Text(locations[4]['placeholder'].toString().substring(0, locations[4]['placeholder'].toString().indexOf(',')), style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary
                ))
                : Text('Memuat Lokasi...', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary
                ))
              ),
              const SizedBox(height: 20),
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
                              MarkerLabel(latlang: latlang, locations: locations)
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
                    Widget widget = Visibility(
                      visible: locations[index]['visible'],
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: AutoCompleteLocationTextfield(
                          onTap: () {
                            return Timer(const Duration(milliseconds: 400), () {
                              _scrollController.animateTo(range(index + 1),
                                duration: const Duration(milliseconds: 200), curve: Curves.ease
                              );
                            });
                          },
                          onDoneEditing: (value) {
                            if (index == locations.length - 1) {
                              locations[index]['value'] = value.toTitleCase();
                            } else {
                              setLocationValue(value: value, index: index);
                            }
                          },
                          element: locations[index],
                          options: locations[index]['options'],
                        ),
                      ),
                    );
                    Timer(const Duration(milliseconds: 400), () {
                      _scrollController.animateTo(range(index + 1),
                        duration: const Duration(milliseconds: 200), curve: Curves.ease
                      );
                    });
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
  const MarkerLabel({super.key, required this.latlang, required this.locations});

  final Position latlang;
  final List<Map> locations;

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
                              Text(locations[3]['placeholder'], style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                height: 0,
                                letterSpacing: 0
                              )),
                              Text(locations[2]['placeholder'], style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    this.onTap
  });

  final Map element;
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final Function(String)? onDoneEditing;
  final Function? onTap;

  @override
  State<LocationTextField> createState() => _LocationTextFieldState();
}

class _LocationTextFieldState extends State<LocationTextField> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
        if (widget.onDoneEditing != null) widget.onDoneEditing!(value);
      },
      onChanged: (value) {
        if (value.trim().isNotEmpty && widget.element['name'] == 'Alamat') {
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
        condition: false
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
    this.onDoneEditing,
  });

  final Map element;
  final Function? onTap;
  final Future<List<String>> Function()? options;
  final Function(String)? onDoneEditing;

  @override
  State<AutoCompleteLocationTextfield> createState() => _AutoCompleteLocationTextfieldState();
}

class _AutoCompleteLocationTextfieldState extends State<AutoCompleteLocationTextfield> {
  // List<String> _kOptions = <String>['aardvark', 'bobcat', 'chameleon'];

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete(
      textEditingController: widget.element['controller'],
      focusNode: widget.element['focusNode'],
      optionsBuilder: (textEditingValue) async {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }

        if (widget.options != null) {
          return widget.options!().then((value) {
            return value.where((String option) {
              return option.contains(textEditingValue.text.toUpperCase());
            });
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
          onDoneEditing: widget.onDoneEditing
        );
      },
      onSelected: (String selection) {
        if (widget.onDoneEditing != null) widget.onDoneEditing!(selection);
        debugPrint('You just selected $selection');
      },
    );
  }
}