import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_auth/functions/customer.dart';

class POChartWidget extends StatelessWidget {
  final DeliveryOrder sectors;

  const POChartWidget(this.sectors, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: PieChart(
        PieChartData(
          sections: _chartSections(context, sectors),
          centerSpaceRadius: 45.0,
        )
      )
    );
  }

  List<PieChartSectionData> _chartSections(BuildContext context, DeliveryOrder sectors) {
    final List<PieChartSectionData> list = [];
    final List sectorsList = [sectors.tonage, sectors.outstanding_tonage, (sectors.target - sectors.tonage < 0.0 ? 0.0 : sectors.target - sectors.tonage)];

    for (var i = 0; i < sectorsList.length; i++) {
      const double radius = 30.0;
      final data = PieChartSectionData(
        color: DeliveryOrder.description(context: context)[i]['color'],
        value: sectorsList[i],
        radius: radius,
        showTitle: false,
        title: DeliveryOrder.description(context: context)[i]['name'],
      );
      list.add(data);
    }
    return list;
  }
}


class POBarChart extends StatefulWidget {
  const POBarChart({
    super.key,
    required this.dark,
    required this.normal,
    required this.light,
    required this.titlebottom,
    required this.colors, required this.borderRadius, required this.sectors
  });

  final DeliveryOrder sectors;

  final Color dark;
  final Color normal;
  final Color light;

  final List<Color> colors;
  final List titlebottom;
  final BorderRadius borderRadius;

  @override
  State<StatefulWidget> createState() => POBarChartState();
}

class POBarChartState extends State<POBarChart> {
  Widget bottomTitles(double value, TitleMeta meta) {
    TextStyle? style = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: 9,
      letterSpacing: 0,
      color: Theme.of(context).colorScheme.secondary
    );

    String text;

    switch (value.toInt()) {
      case 0:
        text = widget.titlebottom[0];
        break;
      case 1:
        text = widget.titlebottom[1];
        break;
      case 2:
        text = widget.titlebottom[2];
        break;
      default:
        text = '';
        break;
    }

    return SideTitleWidget(
      space: 20,
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    if (value == meta.max) {
      return Container();
    }
    TextStyle? style = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 10,
      letterSpacing: 0,
      color: Theme.of(context).colorScheme.secondary
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        '${meta.formattedValue} Ton',
        style: style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1.60,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barsSpace = 8.0 * constraints.maxWidth / 100;
                final barsWidth = 16.0 * constraints.maxWidth / 100;
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.center,
                    barTouchData: BarTouchData(
                      enabled: false,
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: bottomTitles,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: leftTitles,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      checkToShowHorizontalLine: (value) => value % 10 == 0,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.25),
                        strokeWidth: 1,
                      ),
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    groupsSpace: barsSpace,
                    barGroups: getData(
                      sectors: widget.sectors,
                      barsWidth: barsWidth,
                      barsSpace: barsSpace,
                      light: widget.light,
                      borderRadius: widget.borderRadius
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(widget.titlebottom[0], style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          height: 2,
                          letterSpacing: 0
                        )),
                      ],
                    ),
                    Text('${widget.sectors.tonage}', style: Theme.of(context).textTheme.labelLarge)
                  ],
                ),
              ),
              Row(
                children: [
                  const VerticalDivider(indent: 8, endIndent: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.titlebottom[1], style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          height: 2,
                          letterSpacing: 0
                        )),
                        Text('${widget.sectors.outstanding_tonage}', style: Theme.of(context).textTheme.labelLarge)
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const VerticalDivider(indent: 8, endIndent: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.titlebottom[2], style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          height: 2,
                          letterSpacing: 0
                        )),
                        Text('${widget.sectors.target}', style: Theme.of(context).textTheme.labelLarge)
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  List<BarChartGroupData> getData({
    required double barsWidth,
    required double barsSpace,
    required Color light,
    required BorderRadius borderRadius,
    required DeliveryOrder sectors,
  }) {
    return [
      BarChartGroupData(
        x: 0,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            color: Colors.transparent,
            borderSide: BorderSide(color: widget.dark),
            toY: sectors.tonage,
            rodStackItems: [
              BarChartRodStackItem(0, sectors.tonage, widget.dark),
            ],
            borderRadius: borderRadius,
            width: barsWidth,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            color: Colors.transparent,
            borderSide: BorderSide(color: widget.normal),
            toY: sectors.outstanding_tonage,
            rodStackItems: [
              BarChartRodStackItem(0, sectors.outstanding_tonage, widget.normal),
            ],
            borderRadius: borderRadius,
            width: barsWidth,
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            color: Colors.transparent,
            borderSide: BorderSide(color: widget.light),
            toY: sectors.target,
            rodStackItems: [
              BarChartRodStackItem(0, sectors.target, widget.light),
            ],
            borderRadius: borderRadius,
            width: barsWidth,
          ),
        ],
      ),
    ];
  }
}