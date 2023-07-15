import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_auth/widgets/chip.dart';

class Badge extends StatelessWidget {
  const Badge(
    this.svgAsset, {super.key,
    required this.size,
    required this.borderColor,
  });
  final String svgAsset;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: const Center(
        child: FlutterLogo(),
      ),
    );
  }
}

class BadgePie extends StatelessWidget {
  const BadgePie({super.key, required this.label, required this.iconColor});

  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.25),
      elevation: 6,
      borderRadius: BorderRadius.circular(4),
      child: ChipSmall(
        leading: Container(
          height: 10,
          width: 10,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: iconColor,
          ),
        ),
        label: label,
        textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 10
        ),
        borderRadius: BorderRadius.circular(4),
        bgColor: Theme.of(context).colorScheme.background,
        labelColor: Theme.of(context).colorScheme.inverseSurface
      ),
    );
  }
}