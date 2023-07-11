// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_auth/functions/customer.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/strings/user.dart';
import 'package:google_auth/widgets/button.dart';
import 'package:google_auth/widgets/chart.dart';
import 'package:google_auth/widgets/chip.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:intl/intl.dart';

class CreditDueWidget extends StatefulWidget {
  const CreditDueWidget({super.key});

  @override
  State<CreditDueWidget> createState() => _CreditDueWidgetState();
}

class _CreditDueWidgetState extends State<CreditDueWidget> {
  late bool noData;

  late Future<CreditDueReport> _creditDueReport;
  late String total_balance, total_balance_due;
  late double percent_balance, percent_balance_due;

  late CreditDueData? creditDueLastData;

  @override
  void initState() {
    _creditDueReport = setCreditDueReport();

    _defaultCustomerListener();
    super.initState();
  }

  Future<CreditDueReport> setCreditDueReport() async {
    String? id_ocst = await Customer.getDefaultCustomer().then((customer) => customer?.id_ocst);

    if (id_ocst != null) {
      return CreditDueReport.retrieve(id_ocst: id_ocst).then((value) {
        noData = false;
        return defineCreditDue(value);
      });
    } else {
      noData = true;
      creditDueLastData = CreditDueData(invoice_code: '', due_date: DateNowSQL(), balance_due: '0.0', umur_piutang: '0');
      return defineCreditDue(CreditDueReport(total_balance: 'Rp0.0', total_balance_due: 'Rp0.0', percent_balance: 69, percent_balance_due: 31, data: [creditDueLastData!]));
    }
  }

  CreditDueReport defineCreditDue(CreditDueReport creditDueReport) {
    var dueData = creditDueReport.data?.map((e) {
      if (double.parse(e.umur_piutang) <= 0) return e;
    }).nonNulls.toList();

    setState(() {
      total_balance = creditDueReport.total_balance;
      total_balance_due = creditDueReport.total_balance_due;
      percent_balance = creditDueReport.percent_balance;
      percent_balance_due = creditDueReport.percent_balance_due;

      creditDueLastData = dueData?.first;
    });

    return creditDueReport;
  }

  _defaultCustomerListener() {
    Customer.defaultCustomer.addListener(() {
      if (mounted) setCreditDueReport();
    });
  }

  @override
  void dispose() {
    Customer.defaultCustomer.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _creditDueReport,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: HandleLoading(),
          );
        } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return DisableWidget(
            disable: noData,
            border: false,
            overlay: (context) {
              return const HandleNoData();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Akumulasi Piutang', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            letterSpacing: 0,
                          )),
                          Text('Total Piutang Jatuh Tempo.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              height: 2,
                              fontSize: 10,
                              letterSpacing: 0,
                            )
                          )
                        ],
                      ),
                      ChipSmall(
                        bgColor: CreditDueReport.description(context)[0]['color'],
                        label: '$percent_balance_due%',
                        labelColor: Theme.of(context).colorScheme.surface
                      )
                    ],
                  ),
                  Row(
                    children: [
                      CreditDueChart(
                        radius: 90,
                        selectedRadius: 100,
                        creditDueReport: CreditDueReport(
                          total_balance: total_balance,
                          total_balance_due: total_balance_due,
                          percent_balance: percent_balance,
                          percent_balance_due: percent_balance_due
                        ),
                      ),
                      const SizedBox(width: 32),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Piutang', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.secondary
                          )),
                          const SizedBox(height: 2),
                          Text(total_balance, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.arrow_downward, size: 16, color: Theme.of(context).colorScheme.error, weight: 700, grade: 200),
                              const SizedBox(width: 4),
                              Text(total_balance_due, style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                letterSpacing: 0,
                                color: Theme.of(context).colorScheme.error
                              )),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  color: CreditDueReport.description(context)[1]['color'],
                                  borderRadius: BorderRadius.circular(2)
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('Total Piutang', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 10,
                                letterSpacing: 0
                              )),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  color: CreditDueReport.description(context)[0]['color'],
                                  borderRadius: BorderRadius.circular(2)
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('Jatuh Tempo', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 10,
                                letterSpacing: 0
                              )),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          child: Row(
                            children: [
                              Icon(Icons.circle, size: 10, color: CreditDueReport.description(context)[0]['color']),
                              const SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Badge(
                                    offset: const Offset(24, 1),
                                    backgroundColor: CreditDueReport.description(context)[1]['color'].withOpacity(0.1),
                                    label: Text(' ${double.parse(creditDueLastData!.umur_piutang).toStringAsFixed(0)} Hari ',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: CreditDueReport.description(context)[1]['color'],
                                        fontSize: 8,
                                      ),
                                    ),
                                    child: Text(
                                      NumberFormat.compactSimpleCurrency(locale: 'id-ID', decimalDigits: 2).format(double.parse(creditDueLastData!.balance_due)),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 9
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButtonOpen(
                            label: 'Rincian Piutang',
                            onPressed: () => pushCreditDetailReport(
                              context: context,
                              onPop: () => setState(() {}),
                              setCreditDueReport: setCreditDueReport
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const HandleNoData();
        }
      }
    );
  }
}