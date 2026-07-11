import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../widgets/common/soft_card.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@expensetracker.com',
      queryParameters: {
        'subject': 'Support Request - Expense Tracker',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final faqs = [
      {
        'q': 'How does SMS detection work?',
        'a':
            'We locally parse bank SMS to track your expenses automatically without sending any data to a cloud.'
      },
      {
        'q': 'Are my transactions safe?',
        'a':
            'Currently, all data is stored locally on your device for maximum privacy.'
      },
      {
        'q': 'How do I change my currency?',
        'a':
            'Expense Tracker uses Indian Rupees (₹) consistently for all transactions and budget tracking per standard local setup.'
      },
    ];

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: TextStyle(
            color: isDark ? AppTheme.textLight : AppTheme.textDark,
            fontWeight: FontWeight.w700,
            fontFamily: 'Outfit',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppTheme.textLight : AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Outfit',
                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              SoftCard(
                borderRadius: 20,
                child: Column(
                  children: faqs
                      .map((faq) =>
                          _FAQTile(question: faq['q']!, answer: faq['a']!))
                      .toList(),
                ),
              ),
              const SizedBox(height: 32),
              _buildContactSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.coralHeroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.heroGradientStart.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.support_agent_rounded,
              color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Need more help?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our local-first support team is always here to help you with any issues.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _launchEmail(),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkAccent : Colors.white,
              foregroundColor:
                  isDark ? Colors.white : AppColors.heroGradientStart,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text(
              'Contact Support',
              style:
                  TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Outfit'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQTile({required this.question, required this.answer});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        ListTile(
          title: Text(
            widget.question,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textLight : AppTheme.textDark,
            ),
          ),
          trailing: Icon(
            _isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: AppColors.heroGradientStart,
          ),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              widget.answer,
              style: TextStyle(
                color: isDark ? AppTheme.textGrayDark : AppTheme.textGrayLight,
                height: 1.5,
              ),
            ),
          ),
        Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.withValues(alpha: 0.15)),
      ],
    );
  }
}
