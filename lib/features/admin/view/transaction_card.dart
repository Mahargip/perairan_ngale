import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:perairan_ngale/models/customer.dart';
import 'package:perairan_ngale/models/transaksi.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:perairan_ngale/shared/date_helper.dart';
import 'package:perairan_ngale/shared/styles.dart';
import 'package:perairan_ngale/utils/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionCardNormal extends StatelessWidget {
  const TransactionCardNormal({super.key, required this.transaksi});

  final Transaksi transaksi;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Styles.smallerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, String>>(
              future: _getCustomerDetails(transaksi.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final customerDetails = snapshot.data!;
                  return _buildHistoryItemWidget(
                    context,
                    customerDetails['name']!,
                    customerDetails['alamatTower'] ?? 'Dicatat oleh Admin',
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>> _getCustomerDetails(String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance
        .collection('Customer')
        .doc(userId)
        .get();

    if (snapshot.exists) {
      final customer = Customer.fromFirestore(snapshot);
      return {
        'name': customer.nama,
        'alamatTower': customer.alamatTower,
      };
    } else {
      return {
        'name': 'Admin',
        'alamatTower': '',
      };
    }
  }

  Widget _buildHistoryItemWidget(BuildContext context, String customerName, String alamatTower) {
    final saldo = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp')
        .format(transaksi.saldo);
    return Container(
      decoration: BoxDecoration(
        color: ColorValues.white,
        borderRadius: BorderRadius.circular(Styles.defaultBorder),
        border: Border.all(
          color: ColorValues.grey30,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Styles.defaultPadding),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: Styles.defaultPadding),
              child: Icon(
                IconsaxPlusLinear.card,
                size: Styles.bigIcon,
                color: Colors.black,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        customerName.split(' ').length > 1
                            ? '${customerName.split(' ')[0]} ${customerName.split(' ')[1][0]}'
                            : customerName,
                        style: context.textTheme.bodyMediumBold,
                        maxLines: 1,
                      ),
                      Text(
                        DateHelper.formatDateToDayMonthYearTime(
                            transaksi.tanggal),
                        style: context.textTheme.bodySmallGrey,
                      ),
                    ],
                  ),
                  Text(
                    '$saldo',
                    style: context.textTheme.bodyMediumBold.copyWith(
                      color: transaksi.status == 'pembayaran'
                          ? Colors.green
                          : transaksi.status == 'pengeluaran'
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                  Text(
                    transaksi.deskripsi,
                    style: context.textTheme.bodySmallBold,
                    maxLines: 1,
                  ),
                  Text(
                    alamatTower.isNotEmpty
                        ? "Dicatat oleh Petugas $alamatTower"
                        : "Dicatat oleh Admin",
                    style: context.textTheme.bodySmallGrey,
                  ),
                  const SizedBox(
                    height: Styles.smallSpacing,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
