import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showAppLegalDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Text('Legal Information', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Privacy Policy', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'This application does not collect, transmit, or store any personal data externally. All invoices, clients, and business details are stored locally on your device.\n\nWe do not use tracking or analytics software that identifies you. If you choose to upload an image logo, it remains strictly on your device.',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 20),
            Text('Terms and Conditions', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'By using GSTBubble — Invoice & Calculator, you agree that the app is provided "as is" without any guarantees.\n\nThe calculations provided by the GST Calculator and Invoice Generator should be verified before being used for official tax or legal purposes. The developers are not responsible for any calculation errors or any financial discrepancies resulting from the use of this app.\n\nYou are responsible for ensuring that your invoices comply with your local tax authority\'s rules and regulations.',
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    ),
  );
}
