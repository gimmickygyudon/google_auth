import 'package:flutter/material.dart';
import 'package:google_auth/functions/push.dart';

class BelanjaRoute extends StatefulWidget {
  const BelanjaRoute({super.key});

  @override
  State<BelanjaRoute> createState() => _BelanjaRouteState();
}

List<Map> recommendItems = [
  {
    'name': 'Indostar',
    'subitem': [ 
      {
        'name': 'Indostar Plank'
      }, {
        'name': 'Indostar Board'
      }, {
        'name': 'Indostarbes'
      }
    ],
    'img': 'assets/Logo Indostar.png',
    'color': Colors.blueGrey
  },
  {
    'name': 'ECO',
    'subitem': [ 
      {
        'name': 'ECO Board'
      }, {
        'name': 'ECObes'
      }
    ],
    'img': 'assets/Logo Merk ECO.png',
    'color': Colors.lightGreen
  }
];

class _BelanjaRouteState extends State<BelanjaRoute> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  surfaceTintColor: Colors.transparent,
                  color: Theme.of(context).hoverColor,
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) {},
                        style: Theme.of(context).textTheme.titleMedium,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
                          border: InputBorder.none,
                          hintText: 'Bahan apa yang anda cari ?',
                          hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)
                          ),
                          suffixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.only(left: 6, right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.7),
                              color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 2),
                                Text('Cari', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary
                                ))
                              ],
                            )
                          )
                        ),
                      ),
                    ]
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: FilterChip(
                          onSelected: (value) {},
                          avatar: const FlutterLogo(),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide.none,
                          backgroundColor: Theme.of(context).hoverColor,
                          label: const Text('Produk'),
                        ),
                      );
                    }),
                  )
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.recommend, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 6),
                        Text('Rekomendasi', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary
                        )),
                      ],
                    ),
                    TextButton(onPressed: () {}, child: const Text('Lihat Semua'))
                  ],
                ),
                SizedBox(
                  height: 164,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: recommendItems.map((element) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => pushItemPage(
                            context: context, 
                            hero: element['name'],
                            items: element['subitem'], 
                          ),
                          child: Hero(
                            tag: element['name'],
                            child: CardItem(item: element)
                          )
                        ),
                      );
                    }).toList(),
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
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: item['color'], width: 6))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: item['color'].withOpacity(0.30),
                padding: const EdgeInsets.all(12),
                height: 100,
                child: Image.asset(item['img']),
              ),
              Container(
                color: item['color'].withOpacity(0.15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 0,
                        letterSpacing: 0,
                        color: Theme.of(context).colorScheme.secondary
                      )),
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 4, 6, 4),
                        decoration: BoxDecoration(
                          color: item['color'],
                          borderRadius: BorderRadius.circular(25.7)
                        ),
                        child: Row(
                          children: [
                            Text('Lihat', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.surface)
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 18, color: Theme.of(context).colorScheme.surface),
                          ],
                        )
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}