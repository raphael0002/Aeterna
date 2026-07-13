import 'dart:convert';
import 'dart:io';

import '../models/ticket.dart';

const _backupApp = 'memory_ticket';
const _backupVersion = 1;

Future<String> encodeBackup(List<Ticket> tickets) async {
  final list = <Map<String, dynamic>>[];
  for (final t in tickets) {
    final m = t.toJson()..remove('imagePath');
    final p = t.imagePath;
    if (p != null && File(p).existsSync()) {
      m['imageBytes'] = base64Encode(await File(p).readAsBytes());
      final dot = p.lastIndexOf('.');
      m['imageExt'] = dot == -1 ? '.jpg' : p.substring(dot);
    }
    list.add(m);
  }
  return jsonEncode({
    'app': _backupApp,
    'version': _backupVersion,
    'tickets': list,
  });
}

List<Map<String, dynamic>> parseBackup(String jsonStr) {
  final Object? root = jsonDecode(jsonStr);
  if (root is! Map || root['app'] != _backupApp) {
    throw const FormatException('Not a Aeterna backup');
  }
  final tickets = root['tickets'];
  if (tickets is! List) throw const FormatException('No tickets in backup');
  return tickets.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}
