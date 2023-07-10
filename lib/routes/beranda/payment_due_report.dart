import 'package:flutter/material.dart';
import 'package:google_auth/widgets/button.dart';
import 'package:google_auth/widgets/chart.dart';
import 'package:google_auth/widgets/dropdown.dart';

class PaymentDueWidget extends StatefulWidget {
  const PaymentDueWidget({super.key});

  @override
  State<PaymentDueWidget> createState() => _PaymentDueWidgetState();
}

class _PaymentDueWidgetState extends State<PaymentDueWidget> {
  late List<String> datesRange;
  late String dateRange;

  @override
  void initState() {
    datesRange = ['Minggu Ini', 'Bulan Ini', '3 Bulan', '6 Bulan', 'Setahun'];
    dateRange = datesRange[1];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Terbayar', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.secondary,
                  )),
                  const SizedBox(height: 2),
                  Text('Rp105.4 Jt', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500
                  ))
                ],
              ),
              DropdownLight(
                value: dateRange,
                values: datesRange,
                onChanged: (value) {
                  setState(() {
                    dateRange = value;
                  });
                },
              )
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: LineChartSample2(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButtonOpen(
                onPressed: () {},
                label: 'Rincian Payment'
              ),
            ],
          )
        ],
      ),
    );
  }
}