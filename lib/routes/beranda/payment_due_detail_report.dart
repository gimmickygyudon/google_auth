// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_auth/functions/customer.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:google_auth/widgets/profile.dart';
import 'package:intl/intl.dart';

import '../../functions/date.dart';
import '../../widgets/chip.dart';
import 'delivery_report.dart';

class PaymentDueDetailReport extends StatefulWidget {
  const PaymentDueDetailReport({super.key});

  @override
  State<PaymentDueDetailReport> createState() => _PaymentDueDetailReportState();
}

class _PaymentDueDetailReportState extends State<PaymentDueDetailReport> {
  late Future<PaymentDueReport> _paymentDueReport;
  late PaymentDueReport paymentDueReport;

  bool showAll = true;

  @override
  initState() {
    _paymentDueReport = setPaymentDueReport();
    super.initState();
  }

  Future<PaymentDueReport> setPaymentDueReport() async {
    String? id_ocst = await Customer.getDefaultCustomer().then((customer) => customer?.id_ocst);
    if (id_ocst != null) {
      if (showAll) {
        return PaymentDueReport.retrieveTotal(id_osct: id_ocst).then((value) async {
          paymentDueReport = definePaymentDue(value);
          return paymentDueReport;
        });
      } else {
        int month = Date.months.indexOf(Date.selectedMonth);
        return PaymentDueReport.retrieveLastMonth(id_ocst: id_ocst, from: DateTime(int.parse(Date.selectedYears), month + 1), to: DateTime(int.parse(Date.selectedYears), month + 1))
        .then((value) {
          if (value.isEmpty) return defineError();
          return definePaymentDue(value);
        });
      }
    } else {
      return defineError();
    }
  }

  definePaymentDue(Map value) {
    List<PaymentDueData> data = value['data'].map<PaymentDueData>((e) {
      return PaymentDueData(
        invoice_code: e['invoice_code'],
        payment_date: e['payment_date'],
        total_payment: e['total_payment']
      );
    }).toList();

    setState(() {
      paymentDueReport = PaymentDueReport(total: value['total'].toString(), count: value['count'], data: data);
    });

    return paymentDueReport;
  }

  defineError() {
    return PaymentDueReport(total: '0', count: 0, data: [PaymentDueData(invoice_code: '', payment_date: DateFormat('MMMM ''yyyy', 'id').format(DateTime.now()), total_payment: '0')]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 6, right: 12),
          child: CustomerSelectWidget(onChanged: () {
            setPaymentDueReport();
          }),
        ),
        actions: [
          ProfileMenu(color: Theme.of(context).colorScheme.inverseSurface),
          const SizedBox(width: 12)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        child: FutureBuilder(
          future: _paymentDueReport,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const HandleLoading();
            } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return Theme(
                data: Theme.of(context).copyWith(
                  cardTheme: const CardTheme(elevation: 0, margin: EdgeInsets.zero),
                  dividerTheme: DividerThemeData(color: Theme.of(context).colorScheme.onInverseSurface),
                ),
                child: PaginatedDataTable(
                  source: PaymentDueTable(context: context, data: paymentDueReport.data),
                  columns: [
                    DataColumn(
                      label: Row(
                        children: [
                          const Text('INVOCE CODE', style: TextStyle(
                            fontSize: 12,
                          )),
                          const SizedBox(width: 8),
                          ChipSmall(
                            bgColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                            label: paymentDueReport.count.toString(),
                            labelColor: Theme.of(context).colorScheme.primary
                          )
                        ],
                      )
                    ),
                    DataColumn(
                      label: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('NOMINAL PAYMENT', style: TextStyle(
                            fontSize: 12,
                          )),
                          ChipSmall(
                            bgColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                            label: NumberFormat.simpleCurrency(locale: 'id-ID', decimalDigits: 0).format(double.parse(paymentDueReport.total.toString())),
                            labelColor: Theme.of(context).colorScheme.primary
                          )
                        ],
                      )
                    ),
                  ],
                  columnSpacing: 80,
                  horizontalMargin: 0,
                  headingRowHeight: 60,
                  dataRowMinHeight: 30,
                  dataRowMaxHeight: 55,
                  rowsPerPage: 10,
                  showCheckboxColumn: true,
                ),
              );
            } else {
              return const HandleNoData();
            }
          }
        ),
      ),
    );
  }
}

class PaymentDueTable extends DataTableSource {
  final List<PaymentDueData>? data;
  final BuildContext context;

  PaymentDueTable({required this.context, required this.data});

  Color get error => Theme.of(context).colorScheme.error;

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data!.length;
  @override
  int get selectedRowCount => 0;
  @override
  DataRow getRow(int index) {
    return DataRow(
      cells: [
        DataCell(
          Text(data![index].invoice_code, style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 10,
          ))
        ),
        DataCell(
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(NumberFormat.simpleCurrency(locale: 'id-ID', decimalDigits: 0).format(double.parse(data![index].total_payment)), style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 10,
              )),
              const SizedBox(height: 2),
              Text(DateFormat('EEEE, dd MMMM ''yyyy', 'id').format(DateTime.parse(data![index].payment_date)), style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 8,
              )),
            ],
          )
        ),
      ]
    );
  }
}