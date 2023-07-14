// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_auth/functions/customer.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/widgets/button.dart';
import 'package:google_auth/widgets/chart.dart';
import 'package:google_auth/widgets/dropdown.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:google_auth/widgets/text.dart';
import 'package:intl/intl.dart';

import '../../strings/user.dart';

class PaymentDueWidget extends StatefulWidget {
  const PaymentDueWidget({super.key});

  @override
  State<PaymentDueWidget> createState() => _PaymentDueWidgetState();
}

class _PaymentDueWidgetState extends State<PaymentDueWidget> {
  late List<String> datesRange;
  late String dateRange;
  late String date;
  late bool noData;

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
      Future<Map> deliveryOrder;

      switch (dateRange.toUpperCase()) {
        case 'MINGGU INI':
          date = '${getCurrentStartEndWeek(DateTime.now(), format: 'dd MMMM').keys.first}  -  ${getCurrentStartEndWeek(DateTime.now(), format: 'dd MMMM').values.first}';
          deliveryOrder = PaymentDueReport.retrieveWeek(id_ocst: id_ocst, date: DateTime.now());
        break;

        case 'BULAN INI':
          LastDateFrom lastDate = LastDateFrom.months(interval: 0);

          date = DateFormat('MMMM ''yyyy', 'id').format(lastDate.to);
          deliveryOrder = PaymentDueReport.retrieveLastMonth(id_ocst: id_ocst, from: lastDate.from, to: lastDate.to);
        break;

        case '3 BULAN':
          LastDateFrom lastDate = LastDateFrom.months(interval: 3);

          date = '${DateFormat('MMMM ''yyyy', 'id').format(lastDate.from)}  -  ${DateFormat('MMMM ''yyyy', 'id').format(lastDate.to)}';
          deliveryOrder = PaymentDueReport.retrieveLastMonth(id_ocst: id_ocst, from: lastDate.from, to: lastDate.to);
        break;

        case '6 BULAN':
          LastDateFrom lastDate = LastDateFrom.months(interval: 6);

          date = '${DateFormat('MMMM ''yyyy', 'id').format(lastDate.from)}  -  ${DateFormat('MMMM ''yyyy', 'id').format(lastDate.to)}';
          deliveryOrder = PaymentDueReport.retrieveLastMonth(id_ocst: id_ocst, from: lastDate.from, to: lastDate.to);
        break;

        case 'TOTAL':
          deliveryOrder = PaymentDueReport.retrieveTotal(id_osct: id_ocst).then((value) {
            String firstDate = value['data'].first['payment_date'];
            String lastDate = value['data'].last['payment_date'];

            date = '${DateFormat('MMMM ''yyyy', 'id').format(DateTime.parse(firstDate))}  -  ${DateFormat('MMMM ''yyyy', 'id').format(DateTime.parse(lastDate))}';
            return value;
          });
        default:
          return setInitialPaymentReport();
      }

    return await deliveryOrder.then((value) {
      if (value.isEmpty) setInitialPaymentReport();

      return definePaymentDue(value);
    }).onError((error, stackTrace) => setInitialPaymentReport());
    } else {
      return setInitialPaymentReport();
    }
  }

  definePaymentDue(Map value) {
    setState(() {
      var data = value['data'].map<PaymentDueData>((e) {
        return PaymentDueData.toObject(e);
      }).toList();

      paymentDueReport = PaymentDueReport(
        total: NumberFormat.compactSimpleCurrency(locale: 'id-ID', decimalDigits: 2).format(value['total']),
        count: value['count'],
        data: data,
      );
      noData = false;
    });

    return paymentDueReport;
  }

  setInitialPaymentReport() {
    if (mounted) {
      setState(() {
        noData = true;
        date = DateFormat('EEEE, dd MMMM ''yyyy', 'id').format(DateTime.now());
        paymentDueReport = const PaymentDueReport(total: 'Rp0.0', count: 0, data: []);
      });
    }
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
                        setPaymentDueReport();
                      });
                    },
                  )
                ],
              ),
              const SizedBox(height: 12),
              DisableWidget(
                disable: noData,
                border: false,
                overlay: (context) {
                  return const Center(
                    heightFactor: 2,
                    child: HandleNoData()
                  );
                },
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(date,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.primary
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: LineChartSample2(
                            data: paymentDueReport.data,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Tooltip(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Theme.of(context).colorScheme.inverseSurface
                          ),
                          preferBelow: false,
                          triggerMode: TooltipTriggerMode.tap,
                          richMessage: TextSpan(
                            text: 'Tekan',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              letterSpacing: 0,
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.surface
                            ),
                            children: [
                              WidgetSpan(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 1),
                                  child: CircleAvatar(
                                    radius: 6,
                                    child: CircleAvatar(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      radius: 3
                                    )
                                  ),
                                )
                              ),
                              const TextSpan(text: 'Untuk Melihat Nominal Payment Anda')
                            ]
                          ),
                          child: TextIcon(
                            bgRadius: 10,
                            iconSize: 16,
                            label: 'Bantuan', icon: Icons.help,
                            textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                              letterSpacing: 0
                            ),
                          ),
                        ),
                        TextButtonOpen(
                          onPressed: () => pushPaymentDetailReport(
                            context: context,
                            onPop: () => setState(() {}) ,
                            setPaymentDueReport: setPaymentDueReport
                          ),
                          label: 'Rincian Payment'
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}