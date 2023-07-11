// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_auth/functions/customer.dart';
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

  late Future<PaymentDueReport> _paymentDueReport;
  late PaymentDueReport paymentDueReport;

  @override
  void initState() {
    datesRange = ['Minggu Ini', 'Bulan Ini', '3 Bulan', '6 Bulan', 'Total'];
    dateRange = datesRange.last;
    _paymentDueReport = setPaymentDueReport();

    setInitialPaymentReport();
    _defaultCustomerListener();
    super.initState();
  }

  @override
  void dispose() {
    Customer.defaultCustomer.removeListener(() { });
    super.dispose();
  }

  _defaultCustomerListener() {
    Customer.defaultCustomer.addListener(() {
      if (mounted) setPaymentDueReport();
    });
  }

  Future<PaymentDueReport> setPaymentDueReport() async {
    String? id_ocst = await Customer.getDefaultCustomer().then((customer) => customer?.id_ocst);

    if (id_ocst != null) {
      return PaymentDueReport.retrieveTotal(id_osct: id_ocst).then((value) {
        return definePaymentDue(value);
      });
    } else {
      return setInitialPaymentReport();
    }
  }

  definePaymentDue(PaymentDueReport value) {
    setState(() {
      paymentDueReport = value;
    });

    return paymentDueReport;
  }

  setInitialPaymentReport() {
    paymentDueReport = const PaymentDueReport(total: 'Rp0.0', count: 0, data: []);
    return paymentDueReport;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: FutureBuilder<PaymentDueReport>(
        future: _paymentDueReport,
        builder: (context, snapshot) {
          return Column(
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
                      Text(paymentDueReport.total, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: LineChartSample2(
                  data: paymentDueReport.data,
                ),
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
          );
        }
      ),
    );
  }
}