import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/clothing_item.dart';

/// Backend mode: Cloud Functions (production) or HTTP Shelf server (local).
enum BackendMode { cloudFunctions, http }

/// Centralized service for all backend interactions.
///
/// Supports two modes:
///   [BackendMode.cloudFunctions] — calls Firebase Cloud Functions (default)
///   [BackendMode.http] — calls the local Shelf server at [httpBaseUrl]
///
/// Switch modes by changing [mode] at the top of this file.
class BackendService {
  static final BackendService _instance = BackendService._();
  factory BackendService() => _instance;
  BackendService._();

  // ── Configuration ──────────────────────────────────────────────────
  /// Set to [BackendMode.http] to talk to the local Shelf server instead
  /// of Firebase Cloud Functions. Update [httpBaseUrl] to match your
  /// server address (default: http://localhost:8080).
  static BackendMode mode = BackendMode.cloudFunctions;
  static String httpBaseUrl = 'http://localhost:8080';

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // ── Core request helpers ──────────────────────────────────────────

  Future<String> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw BackendException('auth', 'Not authenticated');
    final token = await user.getIdToken();
    if (token == null) throw BackendException('auth', 'Failed to get ID token');
    return token;
  }

  Future<dynamic> _callCloudFunction(String name, {Map<String, dynamic>? data}) async {
    try {
      final callable = _functions.httpsCallable(name);
      final result = await callable.call(data);
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      throw BackendException(e.code, e.message ?? e.code);
    } catch (e) {
      throw BackendException('unknown', e.toString());
    }
  }

  Future<Map<String, dynamic>> _httpGet(String path) async {
    final token = await _getIdToken();
    final uri = Uri.parse('$httpBaseUrl$path');
    final res = await http.get(uri, headers: _headers(token));
    return _handleHttpResponse(res);
  }

  Future<Map<String, dynamic>> _httpPost(String path, Map<String, dynamic> body) async {
    final token = await _getIdToken();
    final uri = Uri.parse('$httpBaseUrl$path');
    final res = await http.post(uri, headers: _headers(token), body: jsonEncode(body));
    return _handleHttpResponse(res);
  }

  Future<Map<String, dynamic>> _httpPut(String path, Map<String, dynamic> body) async {
    final token = await _getIdToken();
    final uri = Uri.parse('$httpBaseUrl$path');
    final res = await http.put(uri, headers: _headers(token), body: jsonEncode(body));
    return _handleHttpResponse(res);
  }

  Future<Map<String, dynamic>> _httpDelete(String path) async {
    final token = await _getIdToken();
    final uri = Uri.parse('$httpBaseUrl$path');
    final res = await http.delete(uri, headers: _headers(token));
    return _handleHttpResponse(res);
  }

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Map<String, dynamic> _handleHttpResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return {};
      return Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    }
    String msg;
    try {
      final body = jsonDecode(res.body) as Map;
      msg = (body['error'] ?? body['errors']?.toString() ?? res.reasonPhrase) as String;
    } catch (_) {
      msg = res.reasonPhrase ?? 'HTTP ${res.statusCode}';
    }
    throw BackendException('${res.statusCode}', msg);
  }

  // ── Profile Operations ────────────────────────────────────────────

  Future<Map<String, dynamic>> getUserProfile() async {
    if (mode == BackendMode.http) {
      return _httpGet('/api/profile');
    }
    final result = await _callCloudFunction('getUserProfile');
    return Map<String, dynamic>.from(result as Map);
  }

  Future<void> createUserProfile({
    required String name,
    required String email,
    required String favoriteStyle,
    required String favoriteColor,
    required String wardrobeType,
  }) async {
    final data = {
      'name': name,
      'email': email,
      'favoriteStyle': favoriteStyle,
      'favoriteColor': favoriteColor,
      'wardrobeType': wardrobeType,
    };
    if (mode == BackendMode.http) {
      await _httpPost('/api/profile', data);
      return;
    }
    await _callCloudFunction('createUserProfile', data: data);
  }

  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? favoriteStyle,
    String? favoriteColor,
    String? wardrobeType,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (favoriteStyle != null) data['favoriteStyle'] = favoriteStyle;
    if (favoriteColor != null) data['favoriteColor'] = favoriteColor;
    if (wardrobeType != null) data['wardrobeType'] = wardrobeType;

    if (data.isEmpty) return;

    if (mode == BackendMode.http) {
      await _httpPut('/api/profile', data);
      return;
    }
    await _callCloudFunction('updateUserProfile', data: data);
  }

  Future<void> deleteUserAccount() async {
    if (mode == BackendMode.http) {
      await _httpDelete('/api/profile');
      return;
    }
    await _callCloudFunction('deleteUserAccount');
  }

  // ── Clothing Item Operations ──────────────────────────────────────

  Future<List<ClothingItem>> getClothingItems() async {
    List<dynamic> items;
    if (mode == BackendMode.http) {
      final result = await _httpGet('/api/clothing');
      items = result['items'] as List;
    } else {
      final result = await _callCloudFunction('getClothingItems');
      items = (result['items'] as List);
    }
    return items
        .map((item) => ClothingItem.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ClothingItem> addClothingItem(ClothingItem item) async {
    Map<String, dynamic> saved;
    if (mode == BackendMode.http) {
      final result = await _httpPost('/api/clothing', item.toMap());
      saved = Map<String, dynamic>.from(result['item']);
    } else {
      final result = await _callCloudFunction('addClothingItem', data: item.toMap());
      saved = Map<String, dynamic>.from(result['item']);
    }
    return ClothingItem.fromMap(saved);
  }

  Future<void> updateClothingItem(ClothingItem item) async {
    if (mode == BackendMode.http) {
      await _httpPut('/api/clothing/${item.id}', item.toMap());
      return;
    }
    await _callCloudFunction('updateClothingItem', data: item.toMap());
  }

  Future<void> deleteClothingItem(String itemId) async {
    if (mode == BackendMode.http) {
      await _httpDelete('/api/clothing/$itemId');
      return;
    }
    await _callCloudFunction('deleteClothingItem', data: {'itemId': itemId});
  }

  Future<bool> toggleFavorite(String itemId) async {
    Map<String, dynamic> result;
    if (mode == BackendMode.http) {
      result = await _httpPut('/api/clothing/$itemId/favorite', {});
    } else {
      result = await _callCloudFunction('toggleFavorite', data: {'itemId': itemId}) as Map<String, dynamic>;
    }
    return result['isFavorite'] as bool;
  }
}

/// Custom exception for backend errors.
class BackendException implements Exception {
  final String code;
  final String message;
  BackendException(this.code, this.message);

  @override
  String toString() => 'BackendException($code): $message';
}
