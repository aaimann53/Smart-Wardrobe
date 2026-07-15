import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

import '../middleware/auth.dart';
import '../models/validators.dart';
import '../db.dart';

const _maxClothingItems = 500;

class ClothingRoutes {
  final _uuid = const Uuid();
  late final Router router;

  ClothingRoutes() {
    router = Router()
      ..get('/', _listItems)
      ..post('/', _addItem)
      ..put('/<id>', _updateItem)
      ..delete('/<id>', _deleteItem)
      ..put('/<id>/favorite', _toggleFavorite);
  }

  Response _listItems(Request request) {
    final uid = requireUid(request);
    final items = db.getClothingItems(uid);

    return Response.ok(
      jsonEncode({'items': items, 'count': items.length}),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> _addItem(Request request) async {
    final uid = requireUid(request);
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;

    final errors = Validators.validateClothingItem(body);
    if (errors.isNotEmpty) {
      return Response.badRequest(
        body: jsonEncode({'errors': errors}),
        headers: {'content-type': 'application/json'},
      );
    }

    final currentCount = db.getClothingItemCount(uid);
    if (currentCount >= _maxClothingItems) {
      return Response.forbidden(
        jsonEncode({'error': 'Wardrobe is full. Maximum $_maxClothingItems items allowed.'}),
        headers: {'content-type': 'application/json'},
      );
    }

    final itemId = body['id'] as String? ?? _uuid.v4();
    final now = DateTime.now().toUtc().toIso8601String();

    final item = {
      'id': itemId,
      'name': (body['name'] as String).trim(),
      'category': body['category'],
      'subcategory': (body['subcategory'] as String?) ?? '',
      'color': body['color'],
      'season': body['season'],
      'imageUrl': (body['imageUrl'] as String?) ?? '',
      'isFavorite': body['isFavorite'] ?? false,
      'dressPieces': body['dressPieces'] ?? 0,
      'createdAt': now,
      'updatedAt': now,
    };

    db.addClothingItem(uid, item);

    return Response.ok(
      jsonEncode({'success': true, 'item': item}),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> _updateItem(Request request, String itemId) async {
    final uid = requireUid(request);
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;

    final existing = db.getClothingItem(uid, itemId);
    if (existing == null) {
      return Response.notFound(
        jsonEncode({'error': 'Clothing item not found'}),
        headers: {'content-type': 'application/json'},
      );
    }

    final fieldsToCheck = <String, dynamic>{};
    final allowedFields = [
      'name', 'category', 'subcategory', 'color',
      'season', 'imageUrl', 'isFavorite', 'dressPieces',
    ];

    for (final field in allowedFields) {
      if (body.containsKey(field)) {
        fieldsToCheck[field] = body[field];
      }
    }

    if (fieldsToCheck.containsKey('name') ||
        fieldsToCheck.containsKey('category') ||
        fieldsToCheck.containsKey('color') ||
        fieldsToCheck.containsKey('season')) {
      final errors = Validators.validateClothingItem(fieldsToCheck);
      if (errors.isNotEmpty) {
        return Response.badRequest(
          body: jsonEncode({'errors': errors}),
          headers: {'content-type': 'application/json'},
        );
      }
    }

    fieldsToCheck.remove('uid');
    db.updateClothingItem(uid, itemId, fieldsToCheck);

    return Response.ok(
      jsonEncode({'success': true, 'itemId': itemId}),
      headers: {'content-type': 'application/json'},
    );
  }

  Response _deleteItem(Request request, String itemId) {
    final uid = requireUid(request);
    final deleted = db.deleteClothingItem(uid, itemId);

    if (!deleted) {
      return Response.notFound(
        jsonEncode({'error': 'Clothing item not found'}),
        headers: {'content-type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode({'success': true, 'itemId': itemId}),
      headers: {'content-type': 'application/json'},
    );
  }

  Response _toggleFavorite(Request request, String itemId) {
    final uid = requireUid(request);
    final isFavorite = db.toggleFavorite(uid, itemId);

    return Response.ok(
      jsonEncode({'success': true, 'itemId': itemId, 'isFavorite': isFavorite}),
      headers: {'content-type': 'application/json'},
    );
  }
}
