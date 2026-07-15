import 'dart:convert';
import 'package:shelf/shelf.dart';

/// Simple health check endpoint.
Response healthHandler(Request request) {
  return Response.ok(
    jsonEncode({
      'status': 'ok',
      'service': 'smartwardrobe-server',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    }),
    headers: {'content-type': 'application/json'},
  );
}
