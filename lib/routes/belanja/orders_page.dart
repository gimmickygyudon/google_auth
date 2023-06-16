import 'package:flutter/material.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/strings/item.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/cart.dart';
import 'package:google_auth/widgets/profile.dart';

import '../../functions/conversion.dart';

class OrdersPageRoute extends StatefulWidget {
  const OrdersPageRoute({super.key, required this.hero});

  final String hero;

  @override
  State<OrdersPageRoute> createState() => _OrdersPageRouteState();
}

class _OrdersPageRouteState extends State<OrdersPageRoute> {
  List checkedItems = List.empty(growable: true);

  bool orderOpen = false;

  @override
  void initState() {
    super.initState();
  }

  List setSpesifications(Map data) {
    List<String> spesifications = List.generate(data['dimensions'].length, (i) {
       return '${data['dimensions'][i] + '  •  *' + setWeight(weight: double.parse(data['weights'][i]), count: double.parse(data['count']))}';
    });

    return spesifications;
  }

  int selectedIndex(Map data) => data['dimensions'].indexOf(data['dimension']);
  List spesifications(Map data) => setSpesifications(data);
  String spesification(Map data) => spesifications(data)[selectedIndex(data)];

  // TODO: Dirty Code Fix Duplicate Later
  Future<void> _showAlertDialog({required Function onConfirm}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.info, size: 48),
          iconColor: Theme.of(context).colorScheme.primary,
          title: const Text('Hapus Pesanan'),
          titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(height: 6),
                Text('Barang yang Anda pilih akan terhapus dari pesanan Anda.'),
                SizedBox(height: 24),
                Text('Hapus daftar pesanan?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary)
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.error)
              ),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: Themes.appBarTheme(context)
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Buat Pesanan', style: Theme.of(context).textTheme.titleMedium),
          centerTitle: true,
          actions: [
            ProfileMenu(color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 8)
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          height: 64,
          elevation: 20,
          shadowColor: Theme.of(context).colorScheme.shadow,
          surfaceTintColor: Theme.of(context).colorScheme.inversePrimary,
          child: ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), 
                child: const Text('Kembali')
              ),
              ElevatedButton.icon(
                onPressed: checkedItems.contains(true) 
                ? () {
                  orderOpen 
                  ? setState(() => orderOpen = false) 
                  : setState(() => orderOpen = true);
                }
                : null,
                style: ButtonStyle(
                  elevation: const MaterialStatePropertyAll(0),
                  padding: const MaterialStatePropertyAll(EdgeInsets.fromLTRB(18, 4, 14, 4)),
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if(states.contains(MaterialState.disabled)) {
                      return null;
                    } else if (orderOpen) {
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
                  iconSize: MaterialStatePropertyAll(orderOpen ? null : 28)
                ),
                icon: Text(orderOpen ? 'Batal ' : 'Checkout'),
                label: Icon(orderOpen ? Icons.cancel : Icons.arrow_drop_down)
              )
            ],
          ),
        ),
        body: Hero(
          tag: widget.hero,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSize(
                  curve: Curves.ease,
                  duration: const Duration(milliseconds: 400),
                  child: SizedBox(
                    height: orderOpen ? null : 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                          child: Card(
                            margin: EdgeInsets.zero,
                            elevation: 0,
                            color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.35),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                                          Text('Pengiriman', style: Theme.of(context).textTheme.titleLarge?.copyWith()),
                                          const SizedBox(height: 4),
                                          Text('Alamat Kirim', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.secondary
                                          )),
                                        ],
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {},
                                        style: ButtonStyle(
                                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8)
                                          )),
                                          elevation: const MaterialStatePropertyAll(0),
                                          backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5)),
                                        ),
                                        label: const Text('Ubah'),
                                        icon: const Icon(Icons.explore),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 12),
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
                                            Text('Kabupaten Malang',
                                              textAlign: TextAlign.justify,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text('+62 341 441111',
                                              textAlign: TextAlign.justify,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text('Jl. Rogonoto No.57B, Gondorejo Ledok, Tamanharjo, Kec. Singosari, Kabupaten Malang, Jawa Timur 65153',
                                              textAlign: TextAlign.justify,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.secondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
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
                                          Text('FRANCO',
                                            textAlign: TextAlign.justify,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextButton.icon(
                              onPressed: () {}, 
                              icon: const Text('Detail Order'),
                              label: const Icon(Icons.arrow_forward)
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
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
                      Text(checkedItems.where((element) => element == true).length.toString()),
                      const SizedBox(width: 12),
                      Text('Dipilih', style: Theme.of(context).textTheme.displaySmall),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filled(
                        onPressed: () {
                          setState(() {
                            checkedItems = List.filled(checkedItems.length, true);
                          });
                        }, 
                        style: ButtonStyle(
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                          )),
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.disabled)) return null;
                            return Theme.of(context).colorScheme.inversePrimary.withOpacity(0.15);
                          }),
                          foregroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.disabled)) return null;
                            return Theme.of(context).colorScheme.primary;
                          }),
                        ),
                        icon: const Icon(Icons.checklist)
                      ),
                      IconButton.filled(
                        onPressed: checkedItems.contains(true) 
                        ? () {
                          void removeItems() {
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
                                  if (checkedItems.contains(true) == false) orderOpen = false;
                                  
                                });
                              });
                              
                            }); 
                          }
                          _showAlertDialog(onConfirm: removeItems);
                        }
                        : null, 
                        style: ButtonStyle(
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                          )),
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.disabled)) return null;
                            return Theme.of(context).colorScheme.error.withOpacity(0.15);
                          }),
                          foregroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.disabled)) return null;
                            return Theme.of(context).colorScheme.error.withOpacity(0.9);
                          }),
                        ),
                        icon: const Icon(Icons.delete)
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: CartWidget.cartNotifier,
                  builder: (context, item, child) {
                    if (item.isNotEmpty) {
                      return ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(12),
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
                                    if (checkedItems.contains(true) == false) orderOpen = false;
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
                      return const Placeholder();
                    }
                  }
                ),
              ],
            ),
          )
        )
      ),
    );
  }
}