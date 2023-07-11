// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_auth/functions/customer.dart';
import 'package:google_auth/routes/beranda/delivery_report.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/chip.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:intl/intl.dart';

import '../../widgets/text.dart';

class CreditDueDetailReport extends StatefulWidget {
  const CreditDueDetailReport({super.key, required this.setCreditDueReport});

  final Future<CreditDueReport> Function() setCreditDueReport;

  @override
  State<CreditDueDetailReport> createState() => _CreditDueDetailReportState();
}

class _CreditDueDetailReportState extends State<CreditDueDetailReport> {
  bool noData = false;

  late Future<CreditDueReport> _creditDueReport;
  late String total_balance, total_balance_due;
  late double percent_balance, percent_balance_due;
  late List<CreditDueData>? _creditDueData;

  late int dues;

  @override
  void initState() {
    _creditDueReport = widget.setCreditDueReport().then((value) {
      return defineCreditDue(value);
    });
    super.initState();
  }

  CreditDueReport defineCreditDue(CreditDueReport creditDueReport) {
    dues = 0;
    creditDueReport.data?.forEach((element) {
      if (double.parse(element.umur_piutang) >= 0) dues++;
    });

    if (creditDueReport.data == null) {
      noData = true;
    } else {
      noData = false;
    }

    setState(() {
      total_balance = creditDueReport.total_balance;
      total_balance_due = creditDueReport.total_balance_due;
      percent_balance = creditDueReport.percent_balance;
      percent_balance_due = creditDueReport.percent_balance_due;
      _creditDueData = creditDueReport.data;
    });
    return creditDueReport;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: Themes.appBarTheme(context)
      ),
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 12),
              child: CustomerSelectWidget(onChanged: () {
                widget.setCreditDueReport().then((value) {
                  return defineCreditDue(value);
                });
              }),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextIcon(
                label: 'Invoice Piutang',
                icon: Icons.trending_down
              ),
              Text('Rincian detail piutang anda selama ini.', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                letterSpacing: 0
              )),
              Divider(height: 60, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
              FutureBuilder(
                future: _creditDueReport,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: HandleLoading());
                  } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    return DisableWidget(
                      disable: noData,
                      border: false,
                      overlay: (context) {
                        return const HandleNoData();
                      },
                      child: Column(
                        children: [
                          HeaderInvoiceWidget(
                            creditDueReport: _creditDueReport,
                            total_balance: total_balance,
                            total_balance_due: total_balance_due,
                            percent_balance: percent_balance,
                            percent_balance_due: percent_balance_due
                          ),
                          DataTableBalanceDue(data: _creditDueData, dues: dues)
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                }
              ),
            ],
          ),
        )
      ),
    );
  }
}


class HeaderInvoiceWidget extends StatelessWidget {
  const HeaderInvoiceWidget({super.key, required this.creditDueReport, required this.total_balance, required this.total_balance_due, required this.percent_balance, required this.percent_balance_due});

  final Future<CreditDueReport> creditDueReport;
  final String total_balance, total_balance_due;
  final double percent_balance, percent_balance_due;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(size: 16, Icons.arrow_downward, color: CreditDueReport.description(context)[0]['color']),
                  const SizedBox(width: 6),
                  Text('Jatuh Tempo', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: CreditDueReport.description(context)[0]['color'],
                    letterSpacing: 0
                  )),
                ],
              ),
              Text('Total Piutang', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: CreditDueReport.description(context)[1]['color'],
                letterSpacing: 0
              ))
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(total_balance_due, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: CreditDueReport.description(context)[0]['color'],
                fontWeight: FontWeight.w500,
                letterSpacing: 0
              )),
              Text(total_balance, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: CreditDueReport.description(context)[1]['color'],
                fontWeight: FontWeight.w500,
                letterSpacing: 0
              ))
            ],
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder(
            curve: Curves.fastOutSlowIn,
            duration: const Duration(milliseconds: 400),
            tween: Tween<double>(
              begin: 0,
              end: percent_balance_due / 100,
            ),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                borderRadius: BorderRadius.circular(4),
                minHeight: 10,
                valueColor: AlwaysStoppedAnimation<Color>(CreditDueReport.description(context)[0]['color']),
                value: value,
              );
            }
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$percent_balance_due%', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: CreditDueReport.description(context)[0]['color'],
                letterSpacing: 0
              )),
              Text('$percent_balance%', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: CreditDueReport.description(context)[1]['color'],
                letterSpacing: 0
              ))
            ],
          ),
        ],
      )
    );
  }
}


class DataTableBalanceDue extends StatelessWidget {
  const DataTableBalanceDue({super.key, required this.data, required this.dues});

  final List<CreditDueData>? data;
  final int dues;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Theme(
         data: Theme.of(context).copyWith(
           cardTheme: const CardTheme(elevation: 0, margin: EdgeInsets.zero),
           dividerTheme: DividerThemeData(color: Theme.of(context).colorScheme.onInverseSurface),
         ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: data == null ? null : PaginatedDataTable(
            source: MyData(context: context, data: data),
            columns: [
              DataColumn(
                label: Row(
                  children: [
                    const Text('JATUH TEMPO', style: TextStyle(
                      fontSize: 12,
                    )),
                    const SizedBox(width: 8),
                    ChipSmall(
                      bgColor: CreditDueReport.description(context)[0]['color'].withOpacity(0.1),
                      label: dues.toString(),
                      labelColor: Theme.of(context).colorScheme.error
                    )
                  ],
                )
              ),
              const DataColumn(
                label: Text('NOMINAL PIUTANG', style: TextStyle(
                  fontSize: 12,
                ))
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
        ),
       ),
    );
  }
}

class MyData extends DataTableSource {
  final List<CreditDueData>? data;
  final BuildContext context;

  MyData({required this.context, required this.data});

  Color get error => Theme.of(context).colorScheme.error;

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data!.length;
  @override
  int get selectedRowCount => 0;
  @override
  DataRow getRow(int index) {
    bool due = double.parse(data![index].umur_piutang) >= 0;
    return DataRow(
      cells: [
        DataCell(
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Badge(
                    offset: const Offset(24, 1),
                    label: Text(' ${double.parse(data![index].umur_piutang).toStringAsFixed(0)} Hari ',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: due ? error : CreditDueReport.description(context)[1]['color'],
                        fontSize: 8,
                      ),
                    ),
                    backgroundColor: due ? CreditDueReport.description(context)[0]['color'].withOpacity(0.1) : CreditDueReport.description(context)[1]['color'].withOpacity(0.1),
                    child: Text(data![index].due_date, style: TextStyle(
                      color: due ? error : null,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(data![index].invoice_code, style: TextStyle(
                color: due ? CreditDueReport.description(context)[0]['color'] : Theme.of(context).colorScheme.secondary,
                fontSize: 8,
              ))
            ],
          )
        ),
        DataCell(
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(NumberFormat.simpleCurrency(locale: 'id-ID', decimalDigits: 2).format(double.parse(data![index].balance_due)), style: TextStyle(
                color: due ? error : null,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              )),
              const SizedBox(height: 2),
              Text(NumberFormat.compactSimpleCurrency(locale: 'id-ID', decimalDigits: 2, name: '').format(double.parse(data![index].balance_due)), style: TextStyle(
                color: due ? error.withOpacity(0.75) : Theme.of(context).colorScheme.secondary,
                fontSize: 8,
              )),
            ],
          )
        ),
      ]
    );
  }
}