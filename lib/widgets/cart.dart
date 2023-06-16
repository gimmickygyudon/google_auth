import 'package:flutter/material.dart';
import 'package:google_auth/functions/conversion.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/strings/item.dart';
import 'package:google_auth/strings/user.dart';
import 'package:google_auth/widgets/handle.dart';

class CartWidget extends StatefulWidget {
  const CartWidget({super.key, this.color, this.bgColor, this.icon});

  final Color? color;
  final Color? bgColor;
  final IconData? icon;

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {

  final GlobalKey<State<StatefulBuilder>> cartListkey = GlobalKey();
  late bool isEmpty;
  late Future _getItems;

  @override
  void initState() {
    _getItems = Cart.getItems();
    setEmpty();
    super.initState();
  }

  void setEmpty() async {
    isEmpty = await Cart.getItems().then((value) {
      if (value == null || value.isEmpty) {
        isEmpty = true;
        return isEmpty;
      } else {
        isEmpty = false;
        return isEmpty;
      }
    });
  }

  void removeItem(int index) {
    Cart.remove(index: index).whenComplete(() => cartListkey.currentState?.setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      elevation: 8,
      shadowColor: Theme.of(context).colorScheme.shadow,
      surfaceTintColor: Theme.of(context).colorScheme.inversePrimary,
      constraints: const BoxConstraints(maxWidth: 400, minWidth: 400),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined),
                      SizedBox(width: 6),
                      Text('Belanja')
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(0),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                      )),
                      visualDensity: VisualDensity.compact,
                      padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
                      iconSize: const MaterialStatePropertyAll(18),
                      textStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 0
                      ))
                    ),
                    label: const Text('Lokasi'),
                    icon: const Icon(Icons.near_me_outlined)
                  )
                ],
              ),
              Text.rich(TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  letterSpacing: 0,
                  color: Theme.of(context).colorScheme.secondary
                ),
                children: [
                  TextSpan(text: DateNow())
                ]
              )),
            ],
          )
        ),
        PopupMenuItem(
          height: 0,  
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Divider(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
          )
        ),
      ] + [
        PopupMenuItem(
          child: StatefulBuilder(
            key: cartListkey,
            builder: (context, setState) {
              return FutureBuilder(
                future: _getItems,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    return AnimatedSize(
                    alignment: Alignment.topCenter,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 400, minHeight: 0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data?.length ?? 0,  
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: CartListWidget(
                              index: index,
                              onDelete: removeItem,
                              item: snapshot.data?[index],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return const HandleLoading();
                  } else {
                    isEmpty = true;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.layers_outlined, size: 46),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 32),
                                SizedBox(width: 8),
                                Icon(Icons.local_shipping, size: 46),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('Sepertinya Anda Belum Memesan', style: Theme.of(context).textTheme.labelMedium),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            }
          )
        ),
        PopupMenuItem(
          height: 0,  
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Divider(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
          )
        ),
        if (!isEmpty) PopupMenuItem(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Cart.removeAll().whenComplete(() {
                      cartListkey.currentState?.setState(() {});
                    });
                  },
                  style: ButtonStyle(
                    iconSize: const MaterialStatePropertyAll(18),
                    textStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600
                    )),
                    foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary),
                    overlayColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.error.withOpacity(0.25))
                  ),
                  icon: const Icon(Icons.remove_circle),
                  label: const Text('Hapus Daftar')
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                    )),
                    elevation: const MaterialStatePropertyAll(0),
                    foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.surface),
                    backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primary),
                    overlayColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.inversePrimary)
                  ),
                  icon: const Icon(Icons.playlist_add, size: 26),
                  label: const Text('Buat Pesanan')
                ),
              ],
            ),
          )
        )
      ],
      child: CircleAvatar(
        backgroundColor: widget.bgColor ?? Colors.transparent,
        child: Icon(
          widget.icon ?? Icons.shopping_bag_outlined,
          color: widget.color,
        ),
      ),
    );
  }
}

class CartListWidget extends StatelessWidget {
  const CartListWidget({
    super.key,
    required this.index, 
    required this.item, 
    required this.onDelete
  });

  final int index;
  final Map? item;
  final Function onDelete;

  @override
  Widget build(BuildContext context) {

    int selectedIndex = item?['dimensions'].indexOf(item?['dimension']);

    // TODO: may error in future
    List<String> spesifications = List.generate(item?['dimensions'].length, (index) {
      return '${item?['dimensions'][index] + '  •  *' + setWeight(weight: double.parse(item?['weights'][index]), count: double.parse(item?['count']))}';
    });
    String spesification = spesifications[selectedIndex];

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 8, right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).primaryColorLight.withOpacity(0.5)
                    ),
                    child: Stack(
                      children: [
                        Image.asset(ItemDescription.getImage(item?['name']), width: 60, fit: BoxFit.cover),
                      ],
                    )
                  ),
                  Positioned.fill(
                    right: 12,
                    bottom: 6,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Badge.count(
                        count: int.parse(item?['count']),
                        largeSize: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      )
                    ),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [ 
                        Row(
                          children: [
                            Text('${item?['name'].toString().toTitleCase()}', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              height: 0
                            )),
                            Text(' #00${index + 1}', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.secondary
                            ))
                          ],
                        ),
                        Text(item?['brand'], style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        )),
                      ],
                    ),
                  ),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(10),
                          value: spesification,
                          onChanged: (value) {
                            String dimension = value!.substring(0, value.indexOf('•')).trim();
                            setState(() {
                              Cart.update(
                                index: index, 
                                element: ['dimension', 'weight'],
                                selectedIndex: item?['dimensions'].indexOf(dimension)
                              );
                              spesification = value;
                            });
                          },
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            height: 0
                          ),
                          items: spesifications.map<DropdownMenuItem<String>>((element) {
                            return DropdownMenuItem<String>(
                              value: element,
                              child: Text(element)
                            );
                          }).toList()
                        ),
                      );
                    }
                  )
                ],
              ),
            ],
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => onDelete(index),
                style: ButtonStyle(
                  visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                  textStyle: MaterialStatePropertyAll(
                    Theme.of(context).textTheme.labelSmall
                  ),
                  foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary)
                ),
                icon: const Icon(Icons.cancel)
              ),
            ],
          )
        ]
      ),
    );
  }
}
