import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db.dart';
import '../middleware/auth.dart';
import '../models/validators.dart';

/// Profile routes: GET, POST, PUT, DELETE
class ProfileRoutes {
  late final Router router;

  ProfileRoutes() {
    router = Router()
      ..get('/', _getProfile)
      ..post('/', _createProfile)
      ..put('/', _updateProfile)
      ..delete('/', _deleteProfile);
  }

  /// GET /api/profile — Fetch the authenticated user's profile.
  Response _getProfile(Request request) {
    final uid = requireUid(request);
    final profile = db.getProfile(uid);

    if (profile == null) {
      return Response.notFound(
        jsonEncode({'error': 'Profile not found'}),
        headers: {'content-type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode(profile),
      headers: {'content-type': 'application/json'},
    );
  }

  /// POST /api/profile — Create a new user profile.
  /// Called during registration after Firebase Auth account is created.
  Future<Response> _createProfile(Request request) async {
    final uid = requireUid(request);
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;

    // Prevent creating profile for another user
    if (body['uid'] != null && body['uid'] != uid) {
      return Response.forbidden(
        jsonEncode({'error': 'Cannot create profile for another user'}),
        headers: {'content-type': 'application/json'},
      );
    }

    final errors = Validators.validateProfile(body);
    if (errors.isNotEmpty) {
      return Response.badRequest(
        body: jsonEncode({'errors': errors}),
        headers: {'content-type': 'application/json'},
      );
    }

    if (db.getProfile(uid) != null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Profile already exists. Use PUT to update.'}),
        headers: {'content-type': 'application/json'},
      );
    }

    final now = DateTime.now().toUtc().toIso8601String();
    final profile = {
      'uid': uid,
      'name': (body['name'] as String).trim(),
      'email': (body['email'] as String?)?.trim() ?? '',
      'favoriteStyle': body['favoriteStyle'] ?? 'Casual',
      'favoriteColor': body['favoriteColor'] ?? 'Blue',
      'wardrobeType': body['wardrobeType'] ?? 'female',
      'createdAt': now,
      'updatedAt': now,
    };

    db.createProfile(uid, profile);

    return Response.ok(
      jsonEncode({'success': true, 'uid': uid}),
      headers: {'content-type': 'application/json'},
    );
  }

  /// PUT /api/profile — Update profile fields (partial update).
  Future<Response> _updateProfile(Request request) async {
    final uid = requireUid(request);
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;

    final errors = Validators.validateProfile(body);
    if (errors.isNotEmpty) {
      return Response.badRequest(
        body: jsonEncode({'errors': errors}),
        headers: {'content-type': 'application/json'},
      );
    }

    final existing = db.getProfile(uid);
    if (existing == null) {
      return Response.notFound(
        jsonEncode({'error': 'Profile not found. Create it first.'}),
        headers: {'content-type': 'application/json'},
      );
    }

    final allowedFields = ['name', 'email', 'favoriteStyle', 'favoriteColor', 'wardrobeType'];
    final updatedFields = <String>[];

    final updates = <String, dynamic>{};
    for (final field in allowedFields) {
      if (body.containsKey(field)) {
        final value = body[field];
        updates[field] = value is String ? value.trim() : value;
        updatedFields.add(field);
      }
    }

    if (updatedFields.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'No valid fields to update'}),
        headers: {'content-type': 'application/json'},
      );
    }

    db.updateProfile(uid, updates);

    return Response.ok(
      jsonEncode({'success': true, 'uid': uid, 'updatedFields': updatedFields}),
      headers: {'content-type': 'application/json'},
    );
  }

  /// DELETE /api/profile — Delete user profile and all associated data.
  Response _deleteProfile(Request request) {
    final uid = requireUid(request);
    db.deleteProfile(uid);

    return Response.ok(
      jsonEncode({'success': true}),
      headers: {'content-type': 'application/json'},
    );
  }
}
