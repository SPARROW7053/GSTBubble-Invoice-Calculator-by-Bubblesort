import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/client.dart';
import '../../core/providers/business_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/legal_dialog.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});
  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bizNameCtrl, _ownerCtrl, _gstinCtrl, _panCtrl, _phoneCtrl, _emailCtrl, _addressCtrl, _prefixCtrl, _termsCtrl;

  @override
  void initState() {
    super.initState();
    final p = context.read<BusinessProvider>().profile;
    _bizNameCtrl = TextEditingController(text: p.businessName);
    _ownerCtrl = TextEditingController(text: p.ownerName);
    _gstinCtrl = TextEditingController(text: p.gstin);
    _panCtrl = TextEditingController(text: p.pan);
    _phoneCtrl = TextEditingController(text: p.phone);
    _emailCtrl = TextEditingController(text: p.email);
    _addressCtrl = TextEditingController(text: p.address);
    _prefixCtrl = TextEditingController(text: p.invoicePrefix);
    _termsCtrl = TextEditingController(text: p.paymentTerms);
  }

  @override
  void dispose() {
    for (final c in [_bizNameCtrl, _ownerCtrl, _gstinCtrl, _panCtrl, _phoneCtrl, _emailCtrl, _addressCtrl, _prefixCtrl, _termsCtrl]) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bizProvider = context.watch<BusinessProvider>();
    final profile = bizProvider.profile;

    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.accentCoral, Color(0xFFFF8C5E)]),
            borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.business_rounded, color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          Text('My Business', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => showAppLegalDialog(context),
          ),
          IconButton(
            icon: Icon(context.watch<ThemeProvider>().isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Logo section
            _buildLogoSection(isDark, profile, bizProvider),
            const SizedBox(height: 16),
            // Business details
            _sectionCard(isDark, 'Business Details', Icons.store_rounded, [
              _field(_bizNameCtrl, 'Business Name', Icons.business, (v) => bizProvider.updateProfileField('businessName', v)),
              _field(_ownerCtrl, 'Owner Name', Icons.person, (v) => bizProvider.updateProfileField('ownerName', v)),
              _field(_gstinCtrl, 'GSTIN', Icons.numbers, (v) => bizProvider.updateProfileField('gstin', v)),
              _field(_panCtrl, 'PAN', Icons.credit_card, (v) => bizProvider.updateProfileField('pan', v)),
              _field(_phoneCtrl, 'Phone', Icons.phone, (v) => bizProvider.updateProfileField('phone', v), keyboard: TextInputType.phone),
              _field(_emailCtrl, 'Email', Icons.email, (v) => bizProvider.updateProfileField('email', v), keyboard: TextInputType.emailAddress),
              _field(_addressCtrl, 'Address', Icons.location_on, (v) => bizProvider.updateProfileField('address', v), maxLines: 3),
            ]),
            const SizedBox(height: 16),
            // Settings
            _sectionCard(isDark, 'Invoice Settings', Icons.settings_rounded, [
              _field(_prefixCtrl, 'Invoice Prefix (e.g. INV)', Icons.tag, (v) => bizProvider.updateProfileField('invoicePrefix', v)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Default GST Rate', style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<double>(initialValue: profile.defaultGstRate,
                    items: [0,5,12,18,28].map((r) => DropdownMenuItem(value: r.toDouble(), child: Text('$r%'))).toList(),
                    onChanged: (v) { if (v != null) bizProvider.updateProfileField('defaultGstRate', v); }),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Currency', style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(initialValue: profile.currency,
                    items: ['INR','USD','EUR'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) { if (v != null) bizProvider.updateProfileField('currency', v); }),
                ])),
              ]),
              const SizedBox(height: 10),
              _field(_termsCtrl, 'Payment Terms Template', Icons.payment, (v) => bizProvider.updateProfileField('paymentTerms', v), maxLines: 3),
            ]),
            const SizedBox(height: 16),
            // Saved Clients
            _buildClientsSection(isDark, bizProvider),
            const SizedBox(height: 16),
            // Legal Section
            _buildLegalSection(isDark),
            const SizedBox(height: 30),
          ]),
        ),
      ),
    );
  }

  Widget _sectionCard(bool isDark, String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: AppColors.accentCoral, size: 20), const SizedBox(width: 8),
          Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon, Function(String) onChanged, {TextInputType? keyboard, int maxLines = 1}) {
    return Padding(padding: const EdgeInsets.only(bottom: 10),
      child: TextField(controller: ctrl, decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, size: 20)),
        keyboardType: keyboard, maxLines: maxLines, onChanged: onChanged));
  }

  Widget _buildLogoSection(bool isDark, BusinessProfile profile, BusinessProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => _pickLogo(provider),
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.3), width: 2, strokeAlign: BorderSide.strokeAlignOutside),
            ),
            child: profile.logoPath != null
                ? ClipRRect(borderRadius: BorderRadius.circular(16),
                    child: Image.asset(profile.logoPath!, fit: BoxFit.cover, errorBuilder: (_, e, st) => const Icon(Icons.business, size: 36, color: AppColors.accentCoral)))
                : const Icon(Icons.add_a_photo_rounded, size: 28, color: AppColors.accentCoral),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Business Logo', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Tap to upload your logo\nShown on invoices', style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        ])),
      ]),
    );
  }

  Future<void> _pickLogo(BusinessProvider provider) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (img != null) await provider.updateProfileField('logoPath', img.path);
  }

  Widget _buildClientsSection(bool isDark, BusinessProvider provider) {
    return _sectionCard(isDark, 'Saved Clients (${provider.clients.length})', Icons.people_rounded, [
      if (provider.clients.isEmpty)
        Padding(padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(child: Text('No saved clients yet', style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))))
      else
        ...provider.clients.map((client) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg, borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            title: Text(client.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(client.gstin.isNotEmpty ? 'GSTIN: ${client.gstin}' : client.address, style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _showClientDialog(provider, client: client)),
              IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error), onPressed: () => provider.deleteClient(client.id)),
            ]),
          ),
        )),
      const SizedBox(height: 8),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(
        onPressed: () => _showClientDialog(provider),
        icon: const Icon(Icons.person_add_rounded), label: const Text('Add Client'),
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.accentCoral, side: const BorderSide(color: AppColors.accentCoral),
          padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      )),
    ]);
  }

  void _showClientDialog(BusinessProvider provider, {Client? client}) {
    final nameCtrl = TextEditingController(text: client?.name ?? '');
    final gstinCtrl = TextEditingController(text: client?.gstin ?? '');
    final addressCtrl = TextEditingController(text: client?.address ?? '');
    final phoneCtrl = TextEditingController(text: client?.phone ?? '');
    final emailCtrl = TextEditingController(text: client?.email ?? '');
    final isEditing = client != null;

    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(isEditing ? 'Edit Client' : 'Add Client', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Client Name', prefixIcon: Icon(Icons.person_outline, size: 20))),
        const SizedBox(height: 10),
        TextField(controller: gstinCtrl, decoration: const InputDecoration(hintText: 'GSTIN', prefixIcon: Icon(Icons.numbers, size: 20))),
        const SizedBox(height: 10),
        TextField(controller: addressCtrl, decoration: const InputDecoration(hintText: 'Address', prefixIcon: Icon(Icons.location_on_outlined, size: 20)), maxLines: 2),
        const SizedBox(height: 10),
        TextField(controller: phoneCtrl, decoration: const InputDecoration(hintText: 'Phone', prefixIcon: Icon(Icons.phone, size: 20)), keyboardType: TextInputType.phone),
        const SizedBox(height: 10),
        TextField(controller: emailCtrl, decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_outlined, size: 20)), keyboardType: TextInputType.emailAddress),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          if (nameCtrl.text.isEmpty) return;
          if (isEditing) {
            client.name = nameCtrl.text; client.gstin = gstinCtrl.text; client.address = addressCtrl.text;
            client.phone = phoneCtrl.text; client.email = emailCtrl.text;
            provider.updateClient(client);
          } else {
            provider.addClient(Client(name: nameCtrl.text, gstin: gstinCtrl.text, address: addressCtrl.text, phone: phoneCtrl.text, email: emailCtrl.text));
          }
          Navigator.pop(ctx);
        }, child: Text(isEditing ? 'Update' : 'Add')),
      ],
    ));
  }

  Widget _buildLegalSection(bool isDark) {
    return _sectionCard(isDark, 'Legal', Icons.gavel_rounded, [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.privacy_tip_outlined),
        title: Text('Privacy Policy', style: GoogleFonts.inter(fontSize: 14)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showLegalDialog('Privacy Policy', 'This application does not collect, transmit, or store any personal data externally. All invoices, clients, and business details are stored locally on your device. \n\nWe do not use tracking or analytics software that identifies you. If you choose to upload an image logo, it remains strictly on your device.\n\nFor more detailed terms or questions, please contact the developer.'),
      ),
      Divider(height: 1, color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.description_outlined),
        title: Text('Terms and Conditions', style: GoogleFonts.inter(fontSize: 14)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showLegalDialog('Terms and Conditions', 'By using GSTBubble — Invoice & Calculator, you agree that the app is provided "as is" without any guarantees. \n\nThe calculations provided by the GST Calculator and Invoice Generator should be verified before being used for official tax or legal purposes. The developers are not responsible for any calculation errors or any financial discrepancies resulting from the use of this app.\n\nYou are responsible for ensuring that your invoices comply with your local tax authority\'s rules and regulations.'),
      ),
    ]);
  }

  void _showLegalDialog(String title, String content) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      content: SingleChildScrollView(child: Text(content, style: GoogleFonts.inter(fontSize: 14))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
      ],
    ));
  }
}
