import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/strings/item.dart';
import 'package:google_auth/widgets/card.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:google_auth/widgets/label.dart';

class BelanjaRoute extends StatefulWidget {
  const BelanjaRoute({super.key});

  @override
  State<BelanjaRoute> createState() => _BelanjaRouteState();
}

List<Map> recommendItems = Item.recommenditems;

class _BelanjaRouteState extends State<BelanjaRoute>  with AutomaticKeepAliveClientMixin {
  late Future _getItems;
  bool keepAlive = true;
  late String brand;

  @override
  void initState() {
    brand = 'Indostar';
    _getItems = Item.getItems(brand: brand);
    super.initState();
  }

  List getSuggestions(List value, {required int count}) {
    List randomChoice = List.empty(growable: true);
    Set<int> setOfInts = {};

    for (var i = 0; i < count; i++) {
      setOfInts.add(Random().nextInt(value.length));
    }

    setOfInts.toList().forEach((index) {
      randomChoice.add(value[index]);
    });

    return randomChoice;
  }

  @override
  bool get wantKeepAlive => keepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.1),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) {},
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            height: 1.55
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                            border: InputBorder.none,
                            hintText: 'Board Matric',
                            suffixIcon: const LabelSearch(),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 2
                              )
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2
                              )
                            ),
                            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.35),
                              letterSpacing: 0,
                              height: 2
                            ),
                          ),
                        ),
                      ]
                    ),
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder(
                    future: _getItems,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const HandleLoading();
                      } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                        List itemSuggestion = getSuggestions(snapshot.data, count: 4);
                        return SizedBox(
                          height: 40,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: itemSuggestion.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: FilterChip(
                                  onSelected: (value) {
                                    pushItemDetailPage(
                                      context: context,
                                      brand: brand,
                                      hero: itemSuggestion[index]['description'],
                                      color: Colors.blue,
                                      item: itemSuggestion[index]
                                    );
                                  },
                                  avatar: CircleAvatar(
                                    child: Image.asset(ItemDescription.getImage(itemSuggestion[index]['description']))
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.7)),
                                  side: BorderSide.none,
                                  backgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
                                  label: Text(itemSuggestion[index]['description'].toString().toTitleCase()),
                                  labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    letterSpacing: 0
                                  ),
                                ),
                              );
                            },
                          )
                        );
                      } else {
                        return const HandleNoInternet(message: 'Tidak Terkoneksi ke Internet');
                      }
                    }
                  ),
                  Divider(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.75), height: 36),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Row(
                      children: [
                        Text('Penjualan Terbaik', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          letterSpacing: 0
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder(
                    future: _getItems,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const HandleLoading();
                      } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                        return SizedBox(
                          height: 160,
                          child: ListView.builder(
                            itemCount: snapshot.data.length,
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return CardItemSmall(
                                item: snapshot.data[index],
                                hero: snapshot.data[index]['description'],
                                brand: brand,
                                color: Colors.blue,
                              );
                            }
                          ),
                        );
                      } else {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() => keepAlive = false);
                        });
                        return const HandleNoInternet(message: 'Tidak Tersambung ke Internet');
                      }
                    }
                  ),
                  const SizedBox(height: 38),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.grade, color: Colors.orange),
                            const SizedBox(width: 6),
                            Text('Rekomendasi', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              letterSpacing: 0
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      scrollDirection: Axis.horizontal,
                      children: recommendItems.map((element) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => pushItemPage(
                              context: context,
                              brand: element['name'],
                              hero: element['name'],
                              items: element['subitem'],
                              background: element['bg'],
                              color: element['color'],
                              logo: element['img']
                            ),
                            child: Hero(
                              tag: element['name'],
                              child: CardItem(item: element)
                            )
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CardItem extends StatelessWidget {
  const CardItem({super.key, required this.item});

  final Map item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.5,
      height: 200,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Container(
          foregroundDecoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: item['color'], width: 4))
          ),
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(item['bg'])
                  ),
                ),
                foregroundDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(context).hoverColor,
                      Colors.black26,
                    ]
                  )
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 52),
                child: Image.asset(item['img']),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ButtonStyle(
                      shape: const MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                      alignment: FractionalOffset.centerLeft,
                      visualDensity: const VisualDensity(vertical: -4),
                      backgroundColor: MaterialStatePropertyAll(item['color'])
                    ),
                    icon: Text('Lihat Produk', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      letterSpacing: 0
                    )),
                    label: const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
