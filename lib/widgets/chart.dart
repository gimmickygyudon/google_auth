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