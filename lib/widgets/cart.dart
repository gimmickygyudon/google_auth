import 'package:flutter/material.dart';
import 'package:google_auth/functions/conversion.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/strings/item.dart';
import 'package:google_auth/strings/user.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/handle.dart';

class CartWidget extends StatefulWidget {
  const CartWidget({super.key, this.color, this.bgColor, this.icon});

  final Color? color;
  final Color? bgColor;
  final IconData? icon;

  static final ValueNotifier<List> cartNotifier = ValueNotifier(List.empty(growable: true));

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {

  final GlobalKey<State<StatefulBuilder>> cartListkey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  void removeItem(List<int> index) {
    Cart.remove(index: index).whenComplete(() => cartListkey.currentState?.setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CartWidget.cartNotifier,
      builder: (context, items, child) {
        return Stack(
          children: [
            PopupMenuButton(
              padding: EdgeInsets.zero,
              elevation: 8,
              position: PopupMenuPosition.under,
              shadowColor: Theme.of(context).colorScheme.shadow,
              surfaceTintColor: Theme.of(context).colorScheme.inversePrimary,
              constraints: const BoxConstraints(maxWidth: 500, minWidth: 500),
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
                            onPressed: () => pushAddress(context: context, hero: 'Lokasi'),
                            style: Styles.buttonFlatSmall(context: context),
                            label: const Text('Lokasi'),
                            icon: const Icon(Icons.share_location_sharp)
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(DateNow(), style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 10,
                          letterSpacing: 0
                        )),
                      )
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
                  onTap: () => pushOrdersPage(context: context, hero: 'hero'),
                  child: ValueListenableBuilder(
                    valueListenable: CartWidget.cartNotifier,
                    builder: (context, items, child) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: items.isNotEmpty
                        ? AnimatedSize(
                          alignment: Alignment.topCenter,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 400, minHeight: 0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: CartListWidget(
                                    index: index,
                                    onDelete: removeItem,
                                    item: items[index],
                                  ),
                                );
                              },
                            ),
                          ),
                        ) : const HandleEmptyCart(),
                      );
                    }
                  )
                ),
                PopupMenuItem(
                  height: 0,
                  child: ValueListenableBuilder(
                    valueListenable: CartWidget.cartNotifier,
                    builder: (context, item, child) {
                    if (item.isEmpty) {
                      return const SizedBox();
                    } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Divider(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                        );
                      }
                    }
                  )
                ),
                PopupMenuItem(
                  height: 0,
                  child: ValueListenableBuilder(
                    valueListenable: CartWidget.cartNotifier,
                    builder: (context, items, child) {
                      if (items.isNotEmpty) {
                        return Padding(
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
                            Hero(
                              tag: 'Order Button',
                              child: ElevatedButton.icon(
                                onPressed: () => pushOrdersPage(context: context, hero: 'Order Button'),
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
                            ),
                          ],
                        ),
                      );
                      } else {
                        return const SizedBox();
                      }
                    }
                  )
                )
              ],
              child: CircleAvatar(
                backgroundColor: widget.bgColor ?? Colors.transparent,
                child: Icon(
                  widget.icon ?? (items.isNotEmpty
                    ? Icons.shopping_bag
                    : Icons.shopping_bag_outlined),
                  color: widget.color,
                ),
              ),
            ),
            if(items.isNotEmpty) Badge.count(
              count: items.length,
              largeSize: 18,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            )
          ],
        );
      }
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
                onPressed: () => onDelete([index]),
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
