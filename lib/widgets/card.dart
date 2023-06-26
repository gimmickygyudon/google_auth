import 'package:flutter/material.dart';

class CardItemSmall extends StatelessWidget {
  const CardItemSmall({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: Padding(
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
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 6),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceTint,
                ),
                foregroundDecoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.inversePrimary, width: 4))
                ),
                child: Text('Indostar Board', textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.surface,
                  letterSpacing: 0,
                ))
              ),
            ),
          ),
        ],
      ),
    );
  }
}