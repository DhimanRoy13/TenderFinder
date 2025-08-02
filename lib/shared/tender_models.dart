// Shared Tender model and InfoRow widget
import 'package:flutter/material.dart';

class Tender {
  final String title;
  final String tenderId;
  final String type;
  final String inviter;
  final String docPrice;
  final String securityAmt;
  final String publishedOn;
  final String closedOn;
  final String place;
  final String daysRemaining;
  final String alsoPublishedOn;
  final String image;

  Tender({
    required this.title,
    required this.tenderId,
    required this.type,
    required this.inviter,
    required this.docPrice,
    required this.securityAmt,
    required this.publishedOn,
    required this.closedOn,
    required this.place,
    required this.daysRemaining,
    required this.alsoPublishedOn,
    required this.image,
  });

  factory Tender.fromJson(Map<String, dynamic> json) {
    return Tender(
      title: json['Title'] ?? '',
      tenderId: json['Tender_ID'] ?? '',
      type: json['Type'] ?? '',
      inviter: json['Inviter'] ?? '',
      docPrice: json['Doc_Price'] ?? '',
      securityAmt: json['Security_Amt'] ?? '',
      publishedOn: json['Published_On'] ?? '',
      closedOn: json['Closed_On'] ?? '',
      place: json['Place'] ?? '',
      daysRemaining: json['Days_Remaining']?.toString() ?? '',
      alsoPublishedOn: json['Also_Published_On'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final double fontSize;
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label left aligned
          Container(
            constraints: const BoxConstraints(minWidth: 0, maxWidth: 110),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          // Colon centered in a fixed width
          Container(
            width: 18,
            alignment: Alignment.center,
            child: Text(
              ':',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Value left aligned, fills remaining space
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black87, fontSize: fontSize),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
