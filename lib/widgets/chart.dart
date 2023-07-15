import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_auth/functions/customer.dart';
import 'package:google_auth/widgets/badge.dart';
import 'package:intl/intl.dart';

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({super.key, required this.data});

  final List<PaymentDueData> data;

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  late List<Color> gradientColors, gradientColorsBelow;

  @override
  initState() {
    super.initState();
  }

  setGradientColors(BuildContext context) {
    gradientColors = [
      Theme.of(context).colorScheme.primaryContainer,
      Theme.of(context).colorScheme.primary,
    ];

    gradientColorsBelow = [
      Theme.of(context).colorScheme.background,
      Theme.of(context).colorScheme.primaryContainer,
      Theme.of(context).colorScheme.primary.withOpacity(0.5),
      Theme.of(context).colorScheme.primary,
    ];
  }

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    setGradientColors(context);
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.925,
          child: LineChart(
            curve: Curves.easeOutQuart,
            duration: const Duration(milliseconds: 400),
            showAvg ? avgData() : mainData(),
          ),
        ),
        Visibility(
          visible: false,
          child: SizedBox(
            width: 60,
            height: 34,
            child: TextButton(
              onPressed: () {
                setState(() {
                  showAvg = !showAvg;
                });
              },
              child: Text(
                'avg',
                style: TextStyle(
                  fontSize: 12,
                  color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('MAR', style: style);
        break;
      case 5:
        text = const Text('JUN', style: style);
        break;
      case 8:
        text = const Text('SEP', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
    );
    String text;

    if (widget.data.isNotEmpty && widget.data.length > value.toInt()) {
      text = (double.parse(widget.data[value.toInt()].total_payment) / 1000000).toStringAsFixed(0);
    } else {
      return Container();
    }

    return Text('$text Jt', style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        drawHorizontalLine: false,
        horizontalInterval: 1.5,
        verticalInterval: 1.5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            interval: 1.5,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 50,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
      ),
      minX: 0,
      minY: 0,
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Theme.of(context).colorScheme.primary,
          tooltipRoundedRadius: 8,
          fitInsideHorizontally: true,
          getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
            return lineBarsSpot.map((lineBarSpot) {
              return LineTooltipItem(
                NumberFormat.simpleCurrency(locale: 'id-ID', decimalDigits: 0).format(lineBarSpot.y * 10000000),
                children: [
                  const TextSpan(text: '\n'),
                  TextSpan(
                    text: DateFormat('dd MMMM ''yyyy', 'id').format(DateTime.parse(widget.data[lineBarSpot.x.toInt()].payment_date)),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      letterSpacing: 0,
                      color: Theme.of(context).colorScheme.surface
                    )
                  )
                ],
                TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        )
      ),
      lineBarsData: [mainDataBar()],
    );
  }

  LineChartBarData mainDataBar() {
    return LineChartBarData(
      spots: mainDataFlSpot(),
      isCurved: true,
      gradient: LinearGradient(
        colors: gradientColors,
      ),
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (p0, p1, p2, p3) {
          return FlDotCirclePainter(
            radius: 4,
            color: Theme.of(context).colorScheme.primary,
            strokeColor: Theme.of(context).colorScheme.primaryContainer,
            strokeWidth: 4
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: gradientColorsBelow
              .map((color) => color.withOpacity(0.2))
              .toList(),
        ),
      ),
    );
  }

  List<FlSpot> mainDataFlSpot() {
    List<FlSpot> list = List.empty(growable: true);
    for (int i = 0; i < widget.data.length; i++) {
      list.add(FlSpot(i.toDouble(), double.parse(widget.data[i].total_payment) / 10000000));
    }

    return list;
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
      ),
      minX: 0,
      minY: 0,
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (int i = 0; i < widget.data.length; i++) ...[
              FlSpot(i.toDouble(), double.parse(widget.data[i].total_payment) / 10000000)
            ]
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class CreditDueChart extends StatefulWidget {
  const CreditDueChart({super.key, this.radius, this.selectedRadius, required this.creditDueReport});

  final double? radius, selectedRadius;
  final CreditDueReport? creditDueReport;

  @override
  State<StatefulWidget> createState() => CreditDueChartState();
}

class CreditDueChartState extends State<CreditDueChart> {
  int touchedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: 180,
      child: PieChart(
        swapAnimationCurve: Curves.easeOutQuart,
        swapAnimationDuration: const Duration(milliseconds: 600),
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(
            show: false,
          ),
          sectionsSpace: 2,
          centerSpaceRadius: 0,
          sections: showingSections(
            creditDueReport: widget.creditDueReport,
            radius: widget.radius,
            selectedRadius: widget.selectedRadius
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections({
    double? radius, double? selectedRadius,
    required CreditDueReport? creditDueReport
  }) {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 12.0 : 12.0;

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: CreditDueReport.description(context)[0]['color'].withOpacity(0.7),
            value: creditDueReport?.percent_balance_due,
            title: '${creditDueReport?.percent_balance_due}%',
            radius: isTouched ? selectedRadius : radius,
            titleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.surface
            ),
            badgeWidget: BadgePie(
              label: widget.creditDueReport!.total_balance_due,
              iconColor: CreditDueReport.description(context)[0]['color']
            ),
            badgePositionPercentageOffset: 1,
          );
        case 1:
          return PieChartSectionData(
            color: CreditDueReport.description(context)[1]['color'].withOpacity(0.7),
            value: creditDueReport?.percent_balance,
            title: '${creditDueReport?.percent_balance}%',
            radius: isTouched ? selectedRadius : radius,
            titleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.surface
            ),
            badgeWidget: BadgePie(
              label: widget.creditDueReport!.total_balance,
              iconColor: CreditDueReport.description(context)[1]['color']
            ),
            badgePositionPercentageOffset: 1,
          );
        default:
          throw Exception('Oh no');
      }
    });
  }
}


class DeliveryChartWidget extends StatelessWidget {
  final DeliveryOrder deliveryOrder;
  final bool showOutstanding;

  const DeliveryChartWidget({Key? key, required this.showOutstanding, required this.deliveryOrder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: PieChart(
        swapAnimationCurve: Curves.easeOutQuart,
        swapAnimationDuration: const Duration(milliseconds: 800),
        PieChartData(
          sections: _chartSections(context, deliveryOrder),
          centerSpaceRadius: 45.0,
        )
      )
    );
  }

  List<PieChartSectionData> _chartSections(BuildContext context, DeliveryOrder sectors) {
    final List<PieChartSectionData> list = [];
    final List sectorsList = [sectors.tonage.weight, sectors.outstanding_tonage.weight, (sectors.target - sectors.tonage.weight < 0.0 ? 0.0 : sectors.target - sectors.tonage.weight)];
    final List sectorsCount = [sectors.tonage.count, sectors.outstanding_tonage.count];

    for (var i = 0; i < sectorsList.length; i++) {
      const double radius = 35.0;
      final data = PieChartSectionData(
        color: DeliveryOrder.description(context: context)[i]['color'],
        value: sectorsList[i],
        radius: radius,
        showTitle: false,
        badgePositionPercentageOffset: 1,
        badgeWidget: (i != 2) ? BadgePie(
          label: '${sectorsCount[i]} Delivery',
          iconColor: DeliveryOrder.description(context: context)[i]['color']
        ) : null,
        title: DeliveryOrder.description(context: context)[i]['name'],
      );
      if (i != 1 || showOutstanding) list.add(data);
    }
    return list;
  }
}


class PurchaseOrderBarChart extends StatefulWidget {
  const PurchaseOrderBarChart({
    super.key,
    required this.dark, required this.normal, required this.light,
    required this.titlebottom,
    required this.colors, required this.borderRadius,
    required this.deliveryOrder,
    required this.showOutstanding
  });

  final DeliveryOrder deliveryOrder;

  final Color dark;
  final Color normal;
  final Color light;

  final List<Color> colors;
  final List titlebottom;
  final BorderRadius borderRadius;

  final bool showOutstanding;

  @override
  State<StatefulWidget> createState() => PurchaseOrderBarChartState();
}

class PurchaseOrderBarChartState extends State<PurchaseOrderBarChart> {
  Widget bottomTitles(double value, TitleMeta meta) {
    if (value.toInt() == 1 && widget.showOutstanding == false) {
      return Container();
    }

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
                  swapAnimationCurve: Curves.easeOutQuart,
                  swapAnimationDuration: const Duration(milliseconds: 600),
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
                      sectors: widget.deliveryOrder,
                      barsWidth: barsWidth,
                      barsSpace: barsSpace,
                      light: widget.light,
                      borderRadius: widget.borderRadius,

                      showOutstanding: widget.showOutstanding
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    Text('${widget.deliveryOrder.tonage.weight}', style: Theme.of(context).textTheme.labelLarge)
                  ],
                ),
              ),
              Stack(
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.ease,
                    child: SizedBox(
                      width: widget.showOutstanding ? null : 0,
                      child: Row(
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
                                Text('${widget.deliveryOrder.outstanding_tonage.weight}', style: Theme.of(context).textTheme.labelLarge)
                              ],
                            ),
                          ),
                          const VerticalDivider(indent: 8, endIndent: 8),
                        ],
                      ),
                    ),
                  ),
                  if (widget.showOutstanding == false) const VerticalDivider(indent: 8, endIndent: 8),
                ],
              ),
              Row(
                children: [
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
                        Text('${widget.deliveryOrder.target}', style: Theme.of(context).textTheme.labelLarge)
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

    required bool showOutstanding
  }) {
    return [
      BarChartGroupData(
        x: 0,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            color: Colors.transparent,
            borderSide: BorderSide(color: widget.dark),
            toY: sectors.tonage.weight,
            rodStackItems: [
              BarChartRodStackItem(0, sectors.tonage.weight, widget.dark),
            ],
            borderRadius: borderRadius,
            width: barsWidth,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barsSpace: showOutstanding ? barsSpace : null,
        barRods: [
          BarChartRodData(
            color: Colors.transparent,
            borderSide: BorderSide(color: widget.normal),
            toY: showOutstanding ? sectors.outstanding_tonage.weight : 0,
            rodStackItems: [
              BarChartRodStackItem(0, sectors.outstanding_tonage.weight, widget.normal),
            ],
            borderRadius: borderRadius,
            width: showOutstanding ? barsWidth : 0,
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