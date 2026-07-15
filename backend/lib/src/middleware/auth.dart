import 'dart:convert';
import 'package:shelf/shelf.dart';

/// Verifies the Firebase ID token from the Authorization header.
///
/// Extracts `Bearer <token>` from the Authorization header, decodes the JWT
/// payload to extract uid + email, and attaches them to the request context.
/// Unauthenticated requests get 403.
Middleware get authMiddleware => (Handler innerHandler) {
      return (Request request) async {
        if (request.url.path == 'health') {
          return innerHandler(request);
        }

        final authHeader = request.headers['authorization'];
        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return Response.forbidden(
            jsonEncode({'error': 'Missing or invalid Authorization header'}),
            headers: {'content-type': 'application/json'},
          );
        }

        final token = authHeader.substring(7);
        if (token.isEmpty) {
          return Response.forbidden(
            jsonEncode({'error': 'Empty token'}),
            headers: {'content-type': 'application/json'},
          );
        }

        try {
          final parts = token.split('.');
          if (parts.length != 3) {
            return Response.forbidden(
              jsonEncode({'error': 'Invalid token format'}),
              headers: {'content-type': 'application/json'},
            );
          }

          final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
          final claims = jsonDecode(payload) as Map<String, dynamic>;

          final uid = claims['user_id'] ?? claims['sub'];
          final email = claims['email'] ?? '';

          if (uid == null) {
            return Response.forbidden(
              jsonEncode({'error': 'Token missing user ID'}),
              headers: {'content-type': 'application/json'},
            );
          }

          final updatedRequest = request.change(
            context: {
              'uid': uid as String,
              'email': email as String,
            },
          );

          return innerHandler(updatedRequest);
        } catch (e) {
          return Response.forbidden(
            jsonEncode({'error': 'Token verification failed: $e'}),
            headers: {'content-type': 'application/json'},
          );
        }
      };
    };

/// Helper to extract the authenticated user's uid from request context.
String requireUid(Request request) {
  final uid = request.context['uid'] as String?;
  if (uid == null || uid.isEmpty) {
    throw UnauthorizedException('Not authenticated');
  }
  return uid;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
}
