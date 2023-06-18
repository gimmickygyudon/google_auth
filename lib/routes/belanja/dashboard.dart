import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/widgets/label.dart';

class BelanjaRoute extends StatefulWidget {
  const BelanjaRoute({super.key});

  @override
  State<BelanjaRoute> createState() => _BelanjaRouteState();
}

List<Map> recommendItems = Item.recommenditems;

class _BelanjaRouteState extends State<BelanjaRoute> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
                SizedBox(
                  height: 40,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: FilterChip(
                          onSelected: (value) {},
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.7)),
                          side: BorderSide.none,
                          backgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.15),
                          label: Text('Produk $index'),
                          labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 0
                          ),
                        ),
                      );
                    }),
                  )
                ),
                Divider(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5), height: 36),
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
                SizedBox(
                height: 150,
                child: ListView.builder(
                  itemCount: 6,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 160,
                      padding: const EdgeInsets.only(right: 16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Card(
                            elevation: 0,
                            margin: EdgeInsets.zero,
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            clipBehavior: Clip.antiAlias,
                            child: AspectRatio(
                              aspectRatio: 4 / 4,
                              child: index == 1 ? Banner(
                                message: 'PROMO',
                                location: BannerLocation.topStart,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                                  child: Image.asset('assets/Indostar Board.png'),
                                ),
                              )
                              : Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                                child: Image.asset('assets/Indostar Board.png'),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(10, 2, 0, 6),
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceTint,
                                ),
                                foregroundDecoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.inversePrimary, width: 4))
                                ),
                                child: Text('Indostar Board', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.surface,
                                  letterSpacing: 0,
                                ))
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
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
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 40),
                  child: Row(
                    children: [
                      Icon(Icons.movie, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Text('Video Terbaru', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        letterSpacing: 0
                      )),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 14, 30, 0),
                  child: SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Stack(
                          children: [
                            Card(
                              margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              child: Image.network('https://img.youtube.com/vi/krCJczMVbx0/0.jpg'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Image.asset('assets/Logo Indostar.png', height: 16)
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(12)
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: IconButton(
                                  onPressed: () => launchURL(url: 'https://www.youtube.com/watch?v=krCJczMVbx0'),
                                  style: ButtonStyle(
                                    foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary),
                                    backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.background)
                                  ),
                                  icon: const Icon(Icons.play_arrow)
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
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
