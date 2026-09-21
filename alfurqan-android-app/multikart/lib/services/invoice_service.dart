import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../env.dart';

/// INVOICE download — 22/09 (Lalit point 2 — "delivered product ka invoice
/// download karne ka koi button hi nahi").
///
/// SERVER TRUTH (swagger v2 — 22/09 LIVE verify): backend me koi dedicated
/// invoice-download endpoint NAHI hai (Orders ke saare endpoints check kiye).
/// Sirf OrderMst.invoiceUrl field hai — admin jo invoice banata hai uska url
/// GetOrder detail me aata hai.
///
/// Strategy (dono REAL, koi demo nahi):
///  1) `invoiceUrl` non-empty ho to server ki ASLI invoice hi browser me
///     kholo (PDF/HTML jo bhi server ka ho).
///  2) Warna app REAL order data (server se verify hua — items, totals,
///     address, payment method) se HTML invoice file banati hai aur
///     share-sheet deti hai (save/print/PDF — browser Arabic text bhi sahi
///     shape karta hai; isliye HTML hi, PDF nahi).
class InvoiceService {
  InvoiceService._();

  static Future<void> downloadInvoice({
    required String invoiceUrl,
    required String orderNumber,
    required String orderDate,
    required String status,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double shipping,
    required double discount,
    required double tax,
    required double total,
    required String paymentMethod,
    required Map<String, dynamic> address,
    required String currencySymbol,
  }) async {
    // ---- 1) server invoice url ----
    final rawUrl = invoiceUrl.trim();
    if (rawUrl.isNotEmpty) {
      final url = buildMediaUrl(rawUrl);
      final uri = Uri.tryParse(url);
      if (uri != null) {
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        } catch (_) {
          // launch fail — kam se kam link to share kar do (data-loss nahi)
          await Share.share(url);
          return;
        }
      }
    }

    // ---- 2) apna HTML invoice (REAL server data) ----
    final html = _invoiceHtml(
      orderNumber: orderNumber,
      orderDate: orderDate,
      status: status,
      items: items,
      subtotal: subtotal,
      shipping: shipping,
      discount: discount,
      tax: tax,
      total: total,
      paymentMethod: paymentMethod,
      address: address,
      currencySymbol: currencySymbol,
    );
    final dir = await getTemporaryDirectory();
    final safeNo = orderNumber.trim().isEmpty
        ? '${DateTime.now().millisecondsSinceEpoch}'
        : orderNumber.trim().replaceAll(RegExp(r'[^0-9A-Za-z_-]'), '');
    final file = File('${dir.path}/AlFurqan-Invoice-$safeNo.html');
    await file.writeAsString(html, flush: true);
    await Share.shareXFiles([XFile(file.path)],
        text: 'Invoice — Order #$orderNumber');
  }

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  static String _money(double v, String cur) =>
      '$cur ${v.toStringAsFixed(2)}';

  static String _invoiceHtml({
    required String orderNumber,
    required String orderDate,
    required String status,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double shipping,
    required double discount,
    required double tax,
    required double total,
    required String paymentMethod,
    required Map<String, dynamic> address,
    required String currencySymbol,
  }) {
    final cur = currencySymbol.trim().isEmpty ? 'AED' : currencySymbol;
    final rows = StringBuffer();
    for (final it in items) {
      final name = _esc((it['name'] ?? '').toString());
      final qty = (it['qty'] is num) ? (it['qty'] as num).toInt() : 1;
      final price = (it['price'] is num) ? (it['price'] as num).toDouble() : 0.0;
      final line =
          (it['lineTotal'] is num) ? (it['lineTotal'] as num).toDouble() : price * qty;
      rows.write('<tr>'
          '<td dir="auto" class="l">$name</td>'
          '<td>$qty</td>'
          '<td>${_money(price, cur)}</td>'
          '<td>${_money(line, cur)}</td>'
          '</tr>');
    }

    final addrParts = <String>[
      (address['name'] ?? '').toString(),
      (address['title'] ?? '').toString(),
      (address['line1'] ?? '').toString(),
      [
        (address['city'] ?? '').toString(),
        (address['state'] ?? '').toString(),
        (address['pincode'] ?? '').toString(),
      ].where((e) => e.trim().isNotEmpty).join(', '),
      (address['country'] ?? '').toString(),
      (address['phone'] ?? '').toString().isEmpty
          ? ''
          : 'Phone: ${(address['phone'] ?? '').toString()}',
    ].where((e) => e.trim().isNotEmpty).map(_esc).toList();

    final totals = StringBuffer()
      ..write(_totalRow('Subtotal', _money(subtotal, cur)))
      ..write(shipping > 0 ? _totalRow('Delivery', _money(shipping, cur)) : '')
      ..write(discount > 0
          ? _totalRow('Discount', '-${_money(discount, cur)}')
          : '')
      ..write(tax > 0 ? _totalRow('Tax', _money(tax, cur)) : '')
      ..write('<tr class="grand"><td>Total</td><td>${_money(total, cur)}</td></tr>');

    return '<!DOCTYPE html><html><head><meta charset="utf-8">'
        '<meta name="viewport" content="width=device-width, initial-scale=1">'
        '<title>Invoice — Order #${_esc(orderNumber)}</title>'
        '<style>'
        'body{font-family:Arial,Helvetica,sans-serif;color:#111;margin:24px;max-width:720px}'
        '.brand{color:#044015;font-size:22px;font-weight:700}'
        'h1{font-size:16px;margin:24px 0 8px;color:#333}'
        'table{width:100%;border-collapse:collapse;font-size:14px}'
        'th{background:#f4f6f4;text-align:left}'
        'th,td{border:1px solid #ddd;padding:8px}'
        'td.l{max-width:300px}'
        '.tot td{border:none;padding:4px 0}'
        '.tot .grand td{font-weight:700;border-top:2px solid #044015;padding-top:8px}'
        '.muted{color:#555;font-size:13px}'
        '</style></head><body>'
        '<div class="brand">AL FURQAN BOOK SHOP</div>'
        '<div class="muted">https://alfurqan.ae</div>'
        '<h1>Invoice — Order #${_esc(orderNumber)}</h1>'
        '<div class="muted">'
        '${orderDate.trim().isEmpty ? '' : 'Date: ${_esc(orderDate)}<br>'}'
        '${status.trim().isEmpty ? '' : 'Status: ${_esc(status)}<br>'}'
        '${paymentMethod.trim().isEmpty ? '' : 'Payment: ${_esc(paymentMethod.toUpperCase() == 'COD' ? 'Cash on Delivery' : paymentMethod)}'}'
        '</div>'
        '${addrParts.isEmpty ? '' : '<h1>Shipping Address</h1><div class="muted">${addrParts.join('<br>')}</div>'}'
        '<h1>Items</h1>'
        '<table><tr><th class="l">Product</th><th>Qty</th><th>Price</th><th>Amount</th></tr>'
        '$rows</table>'
        '<h1>Price Details</h1>'
        '<table class="tot">$totals</table>'
        '<p class="muted">Generated by AL FURQAN BOOK SHOP app from your order on alfurqan.ae.</p>'
        '</body></html>';
  }

  static String _totalRow(String label, String value) =>
      '<tr><td>$label</td><td>$value</td></tr>';
}
