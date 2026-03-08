/// lib/utils/receipt_printer.dart
import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class ReceiptPrinter {
  static final _printer = BlueThermalPrinter.instance;

  /// Build your plain-text ticket (same as before)
  static String buildTicket({
    required String clientName,
    required String date,
    required bool isPaid,
    required double credit,
    required List<Map<String, dynamic>> items, // name, qty, price, total
    required double total,
  }) {
    final sb = StringBuffer();
    sb.writeln('         Bon Pour');
    sb.writeln('-----------------------------');
    sb.writeln('Client: $clientName');
    sb.writeln('Date: $date');
    sb.writeln('Paye: ${isPaid ? 'Oui' : 'Non'}');
    if (!isPaid && credit > 0) {
      sb.writeln('Montant paye: ${(total - credit).toStringAsFixed(2)} DA');
      sb.writeln('Credit restant: ${credit.toStringAsFixed(2)} DA');
    }
    sb.writeln('-----------------------------');
    for (var item in items) {
      sb.writeln('${item['name']} x${item['qty']}  ${item['price']} DA');
      sb.writeln('  Total: ${item['total'].toStringAsFixed(2)} DA');
    }
    sb.writeln('-----------------------------');
    sb.writeln('TOTAL: ${total.toStringAsFixed(2)} DA');
    sb.writeln('-----------------------------');
    sb.writeln('Merci pour votre achat!');
    sb.writeln('\n\n\n'); // feed
    return sb.toString();
  }

  /// Connect to a paired printer and send the ticket
  static Future<void> printTextReceipt(
    String text,
    BluetoothDevice device,
  ) async {
    // Check if already connected
    bool isConnected = await _printer.isConnected ?? false;
    if (!isConnected) {
      await _printer.connect(device);
    }
    // Print line by line
    final lines = text.split('\n');
    for (var line in lines) {
      _printer.printCustom(line, 1, 0);
    }
    _printer.paperCut();
    // Disconnect
    await _printer.disconnect();
  }
}

