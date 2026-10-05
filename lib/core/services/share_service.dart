import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class ShareService {
  /// Share alert message via iOS share sheet
  Future<void> shareAlert(String message) async {
    await Share.share(
      message,
      subject: '⚠️ Silent Panic Alert',
    );
  }

  /// Send SMS to specific phone numbers (opens native SMS app)
  Future<void> sendSMS({
    required String message,
    required List<String> recipients,
  }) async {
    try {
      // Filter out empty phone numbers
      final validRecipients = recipients
          .where((phone) => phone.isNotEmpty)
          .toList();

      if (validRecipients.isEmpty) {
        throw Exception('No valid phone numbers provided');
      }

      // Create SMS URL scheme for iOS/Android
      final phoneNumbers = validRecipients.join(',');
      final uri = Uri.parse('sms:$phoneNumbers?body=${Uri.encodeComponent(message)}');
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not open SMS app');
      }
    } catch (e) {
      throw Exception('Failed to send SMS: $e');
    }
  }

  /// Copy message to clipboard
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Open Google Maps with coordinates
  Future<void> openMapsUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not open maps');
    }
  }
}
