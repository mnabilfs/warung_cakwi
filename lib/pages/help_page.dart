import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

// 🔍 MARKER: HELP_DOCUMENTATION
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Bantuan', style: TextStyle(color: colorScheme.primary)),
        backgroundColor: colorScheme.surfaceContainerHighest,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          _buildHeader(colorScheme, textTheme),
          const SizedBox(height: 24),
          
          // FAQ Section
          _buildSectionTitle('FAQ', Icons.quiz_outlined, colorScheme, textTheme),
          const SizedBox(height: 12),
          ..._buildFAQItems(colorScheme, textTheme),
          
          const SizedBox(height: 24),
          
          // Contact Section
          _buildSectionTitle('Hubungi Kami', Icons.support_agent, colorScheme, textTheme),
          const SizedBox(height: 12),
          _buildContactCard(colorScheme, textTheme),
          
          const SizedBox(height: 24),
          
          // App Info
          _buildAppInfo(colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.help_outline, size: 40, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Butuh Bantuan?',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Temukan jawaban di sini',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFAQItems(ColorScheme colorScheme, TextTheme textTheme) {
    final faqs = [
      {
        'q': 'Bagaimana cara memesan?',
        'a': 'Pilih menu, tekan tombol keranjang, lalu checkout dengan pilih metode bayar.',
      },
      {
        'q': 'Apakah bisa bayar online?',
        'a': 'Saat ini hanya tersedia Bayar di Tempat. QRIS segera hadir!',
      },
      {
        'q': 'Bagaimana jika pesanan salah?',
        'a': 'Hubungi kami via WhatsApp untuk pengembalian atau penggantian.',
      },
      {
        'q': 'Jam operasional warung?',
        'a': 'Buka setiap hari 08.00 - 21.00 WIB.',
      },
    ];

    return faqs.map((faq) => _FAQItem(
      question: faq['q']!,
      answer: faq['a']!,
      colorScheme: colorScheme,
      textTheme: textTheme,
    )).toList();
  }

  Widget _buildContactCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _ContactRow(
            icon: Icons.chat,
            iconColor: Colors.green,
            title: 'WhatsApp',
            subtitle: '+62 823-3757-7433',
            onTap: () => _launchWhatsApp(),
          ),
          const Divider(height: 24),
          _ContactRow(
            icon: Icons.location_on,
            iconColor: Colors.red,
            title: 'Alamat',
            subtitle: 'Jl. Contoh No. 123, Kota',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.restaurant_menu, size: 32, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            'Warung Cakwi',
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Versi 1.0.0',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _launchWhatsApp() async {
    final url = Uri.parse('https://wa.me/6282337577433');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Tidak dapat membuka WhatsApp');
    }
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _FAQItem({
    required this.question,
    required this.answer,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: widget.textTheme.bodyMedium?.copyWith(
                        color: widget.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 8),
                Text(
                  widget.answer,
                  style: widget.textTheme.bodySmall?.copyWith(
                    color: widget.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}
