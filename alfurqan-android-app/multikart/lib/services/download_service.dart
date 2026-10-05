import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

/// PUBLIC Downloads folder me ASLI file save — 03/10 (Lalit point 2:
/// "vo download ki jgha abhi share ho raha hai — download ka option
/// clear ho"). Android 10+ par MainActivity ka MediaStore channel use
/// hota hai (permission ki zaroorat nahi); usse purane Android ya kisi
/// error par `false` return hota hai — caller phir share/browser par
/// GIRATA hai (data-loss kabhi nahi).
class DownloadService {
  DownloadService._();

  static const MethodChannel _ch = MethodChannel('alfurqan/downloads');

  /// bytes ko Downloads/<fileName> me likho. true = sach me save hua.
  static Future<bool> saveToDownloads({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
  }) async {
    if (bytes.isEmpty || fileName.trim().isEmpty) return false;
    try {
      final r = await _ch.invokeMethod<dynamic>('saveToDownloads', {
        'bytes': Uint8List.fromList(bytes),
        'name': fileName,
        'mime': mimeType,
      });
      return r != null;
    } catch (_) {
      return false;
    }
  }

  /// Remote url ke BYTES lao (server ka invoice ho to — pdf/html).
  /// null = fail; caller external-browser fallback karta hai.
  static Future<List<int>?> fetchBytes(String url) async {
    HttpClient? client;
    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 20);
      final req = await client.getUrl(Uri.parse(url));
      final resp = await req.close().timeout(const Duration(seconds: 45));
      if (resp.statusCode < 200 || resp.statusCode >= 300) return null;
      final builder = BytesBuilder(copy: false);
      await for (final chunk in resp) {
        builder.add(chunk);
      }
      final bytes = builder.takeBytes();
      return bytes.isEmpty ? null : bytes;
    } catch (_) {
      return null;
    } finally {
      client?.close();
    }
  }

  /// naam/url ke end se extension nikalo (".pdf" → pdf).
  static String extOf(String nameOrUrl, {String fallback = 'html'}) {
    final m =
        RegExp(r'\.([0-9A-Za-z]{2,5})(?:[?#].*)?$').firstMatch(nameOrUrl);
    return (m?.group(1) ?? fallback).toLowerCase();
  }

  static String mimeOf(String ext) {
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'html':
      case 'htm':
        return 'text/html';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }
}
