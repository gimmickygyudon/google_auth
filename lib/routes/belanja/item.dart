import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/strings/item.dart';
import 'package:google_auth/widgets/cart.dart';
import 'package:google_auth/widgets/handle.dart';

import '../../styles/theme.dart';

class ItemRoute extends StatefulWidget {
  const ItemRoute({
    super.key,
    required this.brand,
    required this.hero,
    required this.items,
    required this.background,
    required this.color,
    required this.logo
  });

  final List<Map> items;
  final String brand, hero, background, logo;
  final Color color;

  @override
  State<ItemRoute> createState() => _ItemRouteState();
}

class _ItemRouteState extends State<ItemRoute> {

  late final Future<List?> _getItems;

  @override
  void initState() {
    _getItems = Item.getItems(brand: widget.brand);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: Themes.appBarTheme(context),
      ),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              systemOverlayStyle: SystemUiOverlayStyle.light,
              toolbarHeight: kToolbarHeight + 10,
              collapsedHeight: kToolbarHeight + 50,
              expandedHeight: kToolbarHeight + 100,
              automaticallyImplyLeading: false,
              forceElevated: true,
              pinned: true,
              floating: true,
              scrolledUnderElevation: 8,
              shadowColor: widget.color.withOpacity(0.5),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              title: TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                label: Text(' Kembali', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white
                )),
                icon: const Icon(Icons.arrow_back, color: Colors.white)
              ),
              actions: const [
                CartWidget(color: Colors.white),
                SizedBox(width: 12),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image(image: AssetImage(widget.logo), height: 36, width: 200, alignment: Alignment.centerLeft),
                      ],
                    ),
                  ],
                ),
                background: ClipRRect(
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12),),
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: widget.color, width: 3)),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Theme.of(context).hoverColor,
                          Theme.of(context).colorScheme.shadow,
                        ]
                      )
                    ),
                    child: Image.asset(widget.background,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(30, 12, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hasil Terbaru', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      letterSpacing: 0
                    )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.grid_view)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder(
              future: _getItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 16, 30),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 260, mainAxisSpacing: 24, crossAxisSpacing: 24,
                        mainAxisExtent: 230
                      ),
                      delegate: SliverChildListDelegate(
                        snapshot.data!.map((element) {
                          String dimension = Item.defineDimension(element['OITMs'].first['spesification']);
                          String weight = Item.defineWeight(element['OITMs'].first['weight']);
                          return ItemWidget(
                            onTap: () {
                              pushItemDetailPage(
                                context: context,
                                brand: widget.brand,
                                item: element,
                                hero: element['description'],
                                color: widget.color
                              );
                            },
                            color: widget.color,
                            item: element,
                            dimension: dimension,
                            weight: weight,
                          );
                        }).toList()
                      ),
                    )
                  );
                } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: HandleNoInternet(message: 'Periksa Koneksi Internet Anda', color: widget.color)
                    ),
                  );
                }
                return const SliverToBoxAdapter(
                  child: Center(
                    child: HandleLoading()
                  ),
                );
              },
            ),
          ]
        ),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    super.key,
    required this.onTap,
    required this.color,
    required this.item,
    required this.dimension,
    required this.weight,
  });

  final Function onTap;
  final Color color;
  final Map item;
  final String dimension, weight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(spreadRadius: -4, blurRadius: 8, offset: const Offset(0, 4), color: Theme.of(context).shadowColor.withOpacity(0.15))
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: PhysicalModel(
                  color: Colors.transparent,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(20),
                  shadowColor: color.withOpacity(0.25),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Hero(
                      tag: item['description'],
                      child: Image.asset(ItemDescription.getImage(item['description']), fit: BoxFit.contain)
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              minVerticalPadding: 0,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              title: Text(item['description'].toString().toTitleCase()),
              titleTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                letterSpacing: 0
              ),
              subtitle: Row(
                children: [
                  Text('$weight Kg', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary
                  )),
                ],
              ),
            ),
            const Divider(indent: 12, endIndent: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  Icon(Icons.square_foot, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 2),
                  Text(dimension, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 0
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
