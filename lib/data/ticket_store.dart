import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/ticket.dart';
import 'backup.dart';

class TicketStore extends ChangeNotifier {
  final List<Ticket> _tickets = [];
  final _uuid = const Uuid();
  final _rng = Random();
  bool _loaded = false;

  bool get isLoaded => _loaded;

  List<Ticket> get tickets =>
      List.unmodifiable(_tickets..sort((a, b) => b.date.compareTo(a.date)));

  Ticket? byId(String id) {
    for (final t in _tickets) {
      if (t.id == id) return t;
    }
    return null;
  }

  Future<void> load() async {
    try {
      final raw = await _readRawJson();
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        _tickets
          ..clear()
          ..addAll(list.map((e) => Ticket.fromJson(e as Map<String, dynamic>)));
      }
    } catch (e) {
      debugPrint('TicketStore.load failed: $e');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<Ticket> add({
    required String title,
    required TicketCategory category,
    required DateTime date,
    required String venue,
    required String note,
    required int rating,
    String? sourceImagePath,
    double? lat,
    double? lng,
  }) async {
    final id = _uuid.v4();
    final storedImage = (sourceImagePath == null || kIsWeb)
        ? sourceImagePath // on web, keep the original path/URL as-is
        : await _importImage(sourceImagePath, id);
    final ticket = Ticket(
      id: id,
      ticketNumber: '#${(_rng.nextInt(90000) + 10000)}',
      title: title.trim(),
      category: category,
      date: date,
      venue: venue.trim(),
      imagePath: storedImage,
      note: note.trim(),
      rating: rating,
      favorite: false,
      lat: lat,
      lng: lng,
      createdAt: DateTime.now(),
    );
    _tickets.add(ticket);
    await _persist();
    notifyListeners();
    return ticket;
  }

  Future<void> setFavorite(String id, bool value) async {
    final t = byId(id);
    if (t == null || t.favorite == value) return;
    await update(t.copyWith(favorite: value));
  }

  Future<void> setLocation(String id, double? lat, double? lng) async {
    final i = _tickets.indexWhere((t) => t.id == id);
    if (i == -1) return;
    final t = _tickets[i];
    _tickets[i] = Ticket(
      id: t.id,
      ticketNumber: t.ticketNumber,
      title: t.title,
      category: t.category,
      date: t.date,
      venue: t.venue,
      imagePath: t.imagePath,
      note: t.note,
      rating: t.rating,
      favorite: t.favorite,
      lat: lat,
      lng: lng,
      createdAt: t.createdAt,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> update(Ticket updated, {String? newSourceImagePath}) async {
    final i = _tickets.indexWhere((t) => t.id == updated.id);
    if (i == -1) return;
    var next = updated;
    if (newSourceImagePath != null) {
      if (!kIsWeb) await _deleteImage(_tickets[i].imagePath);
      final imgPath = kIsWeb
          ? newSourceImagePath
          : await _importImage(newSourceImagePath, updated.id);
      next = updated.copyWith(imagePath: imgPath);
    }
    _tickets[i] = next;
    await _persist();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    final i = _tickets.indexWhere((t) => t.id == id);
    if (i == -1) return;
    if (!kIsWeb) await _deleteImage(_tickets[i].imagePath);
    _tickets.removeAt(i);
    await _persist();
    notifyListeners();
  }

  Future<int> importBackup(String jsonStr) async {
    final entries = parseBackup(jsonStr);
    var count = 0;
    for (final e in entries) {
      final id = _uuid.v4();
      String? imagePath;
      final b64 = e['imageBytes'] as String?;
      if (b64 != null && !kIsWeb) {
        final dir = await _imagesDir();
        final ext = (e['imageExt'] as String?) ?? '.jpg';
        final f = File('${dir.path}/$id$ext');
        await f.writeAsBytes(base64Decode(b64));
        imagePath = f.path;
      }
      final map = Map<String, dynamic>.from(e)
        ..['id'] = id
        ..['imagePath'] = imagePath
        ..remove('imageBytes')
        ..remove('imageExt');
      map['ticketNumber'] ??= '#${_rng.nextInt(90000) + 10000}';
      map['createdAt'] ??= DateTime.now().toIso8601String();
      _tickets.add(Ticket.fromJson(map));
      count++;
    }
    await _persist();
    notifyListeners();
    return count;
  }

  // ─── Storage helpers ───────────────────────────────────────────────────

  static const _webKey = 'memory_ticket_tickets_v1';

  /// Reads the raw JSON from wherever this platform stores it.
  Future<String?> _readRawJson() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_webKey);
    }
    final file = await _jsonFile();
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  Future<File> _jsonFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tickets.json');
  }

  Future<Directory> _imagesDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final images = Directory('${dir.path}/stub_images');
    if (!await images.exists()) await images.create(recursive: true);
    return images;
  }

  Future<String> _importImage(String source, String id) async {
    final dir = await _imagesDir();
    final dot = source.lastIndexOf('.');
    final ext = dot == -1 ? '.jpg' : source.substring(dot);
    final dest = '${dir.path}/$id$ext';
    await File(source).copy(dest);
    return dest;
  }

  Future<void> _deleteImage(String? path) async {
    if (path == null) return;
    final f = File(path);
    if (await f.exists()) await f.delete();
  }

  Future<void> _persist() async {
    final data = jsonEncode(_tickets.map((t) => t.toJson()).toList());
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_webKey, data);
      return;
    }
    final file = await _jsonFile();
    await file.writeAsString(data, flush: true);
  }
}
