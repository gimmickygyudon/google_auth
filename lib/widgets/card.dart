import 'package:flutter/material.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/strings/item.dart';

class CardItemSmall extends StatelessWidget {
  const CardItemSmall({super.key, required this.item, required this.brand, required this.color, required this.hero});

  final Map item;
  final String brand, hero;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.25),
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          pushItemDetailPage(
            context: context,
            brand: brand,
            color: color,
            hero: hero,
            item: item
          );
        },
        child: SizedBox(
          width: 170,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: AspectRatio(
                  aspectRatio: 4 / 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Hero(
                      tag: hero,
                      child: Image.asset(ItemDescription.getImage(item['description']))
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Text(Item.defineDimension(item['OITMs'].first['spesification']), style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 0,
                        color: Theme.of(context).colorScheme.inverseSurface,
                        fontSize: 8
                      )),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
                      child: Text('${Item.defineWeight(item['OITMs'].first['weight'])} Kg', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 0,
                        color: Theme.of(context).colorScheme.surface,
                        fontSize: 8
                      )),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(0, 6, 0, 4),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceTint,
                    ),
                    foregroundDecoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Theme.of(context).colorScheme.inversePrimary, width: 2))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(item['description'].toString().toTitleCase(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.surface,
                        letterSpacing: 0
                      )),
                    )
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