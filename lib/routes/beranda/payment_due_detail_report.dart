// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_auth/functions/customer.dart';
import 'package:google_auth/functions/string.dart';
import 'package:google_auth/strings/user.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:google_auth/widgets/listtile.dart';
import 'package:google_auth/widgets/profile.dart';
import 'package:intl/intl.dart';

import '../../functions/date.dart';
import '../../widgets/chip.dart';
import '../../widgets/dropdown.dart';
import '../../widgets/text.dart';

class PaymentDueDetailReport extends StatefulWidget {
  const PaymentDueDetailReport({super.key});

  @override
  State<PaymentDueDetailReport> createState() => _PaymentDueDetailReportState();
}

class _PaymentDueDetailReportState extends State<PaymentDueDetailReport> {
  late Future<PaymentDueReport> _paymentDueReport;
  late PaymentDueReport paymentDueReport;

  bool showAll = false, noData = false;
  String paymentTotal = '0.0', date = DateNow();

  @override
  initState() {
    setInitialTotal();
    _paymentDueReport = setPaymentDueReport();
    super.initState();
  }

  setInitialTotal() async {
    String? id_ocst = await Customer.getDefaultCustomer().then((customer) => customer?.id_ocst);
    if (id_ocst != null) {
      PaymentDueReport.retrieveTotal(id_osct: id_ocst).then((value) {
        paymentTotal = value['total'].toString();
      });
    }
  }

  Future<PaymentDueReport> setPaymentDueReport() async {
    String? id_ocst = await Customer.getDefaultCustomer().then((customer) => customer?.id_ocst);
    if (id_ocst != null) {
      if (showAll) {
        return PaymentDueReport.retrieveTotal(id_osct: id_ocst).then((value) async {
          String firstDate = value['data'].first['payment_date'];
          String lastDate = value['data'].last['payment_date'];
          date = '${DateFormat('MMMM ''yyyy', 'id').format(DateTime.parse(firstDate))}  -  ${DateFormat('MMMM ''yyyy', 'id').format(DateTime.parse(lastDate))}';

          paymentDueReport = definePaymentDue(value);
          paymentTotal = paymentDueReport.total;
          return paymentDueReport;
        });
      } else {
        int month = Date.months.indexOf(Date.selectedMonth);
        int lastDayOfMonth = DateTime(int.parse(Date.selectedYears), (month + 1)).lastDayOfMonth;
        return PaymentDueReport.retrieveLastMonth(id_ocst: id_ocst,
          from: DateTime(int.parse(Date.selectedYears), (month + 1)),
          to: DateTime(int.parse(Date.selectedYears), (month + 1), lastDayOfMonth)
        )
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
      return PaymentDueData.toObject(e);
    }).toList();

    setState(() {
      noData = false;
      paymentDueReport = PaymentDueReport(total: value['total'].toString(), count: value['count'], data: data);
    });

    return paymentDueReport;
  }

  defineError() {
    setState(() {
      noData = true;
      paymentDueReport = PaymentDueReport(total: '0', count: 0,
        data: [PaymentDueData(invoice_code: '', payment_date: DateFormat('y-MM-d').format(DateTime.now()), total_payment: '0', payment_duration: '0')]
      );
    });

    return paymentDueReport;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 6, right: 12),
          child: DropdownCustomerSelect(onChanged: () {
            showAll = true;
            setPaymentDueReport();
          }),
        ),
        actions: [
          ProfileMenu(color: Theme.of(context).colorScheme.inverseSurface),
          const SizedBox(width: 12)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextIcon(
                    label: 'Akumulasi Pembayaran',
                    icon: Icons.wallet
                  ),
                  Text('Rincian detail pembayaran anda selama ini.', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    letterSpacing: 0
                  )),
                ],
              ),
            ),
            Divider(indent: 30, endIndent: 30, height: 50, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Text('Total Pembayaran', style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    letterSpacing: 0
                  )),
                  Text(NumberFormat.simpleCurrency(locale: 'id-ID', decimalDigits: 0).format(double.parse(paymentTotal)),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 30, 30, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ListTileCheckBox(
                    title: 'Lihat Semua',
                    selected: showAll,
                    onChanged: (value) {
                      showAll = value;
                      setPaymentDueReport();
                    },
                  ),
                  const SizedBox(width: 30),
                  DisableWidget(
                    disable: showAll,
                    border: false,
                    borderRadius: BorderRadius.zero,
                    opacity: 1,
                    overlay: (context) {
                      return ChipSmall(label: date);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        DropdownLight(
                          value: Date.selectedMonth,
                          values: Date.months,
                          onChanged: (value) {
                            Date.selectedMonth = value;
                            setPaymentDueReport();
                          },
                        ),
                        const SizedBox(width: 12),
                        DropdownLight(
                          value: Date.selectedYears,
                          values: Date.years,
                          onChanged: (value) {
                            Date.selectedYears = value;
                            setPaymentDueReport();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: FutureBuilder(
                future: _paymentDueReport,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const HandleLoading();
                  } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    return DisableWidget(
                      disable: noData,
                      overlayAligment: Alignment.topCenter,
                      overlay: (context) {
                        return const HandleNoData();
                      },
                      border: false,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          cardTheme: const CardTheme(elevation: 0, margin: EdgeInsets.zero),
                          dividerTheme: DividerThemeData(color: Theme.of(context).colorScheme.onInverseSurface),
                        ),
                        child: PaginatedDataTable(
                          source: PaymentDueTable(
                            context: context,
                            data: showAll ? paymentDueReport.data.reversed.toList() : paymentDueReport.data
                          ),
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
                          rowsPerPage: 9,
                        ),
                      ),
                    );
                  } else {
                    return const HandleNoData();
                  }
                }
              ),
            ),
          ],
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
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('EEEE, dd MMMM ''yyyy', 'id').format(DateTime.parse(data![index].payment_date)), style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 9,
              )),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5)
                ),
                child: Text(' ${data![index].payment_duration} Hari ',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          )
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
              Text(data![index].invoice_code, style: TextStyle(
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